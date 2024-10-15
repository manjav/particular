import 'dart:convert';

import 'package:editor/display/footer_view.dart';
import 'package:editor/display/header_view.dart';
import 'package:editor/display/inspector_view.dart';
import 'package:editor/display/timeline_view.dart';
import 'package:editor/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:particular/particular.dart';

void main() {
  runApp(const EditorApp());
}

class EditorApp extends StatefulWidget {
  const EditorApp({super.key});

  @override
  State<EditorApp> createState() => _EditorAppState();
}

class _EditorAppState extends State<EditorApp> {
  Uint8List? _backgroundImage;
  Map<String, dynamic> _appConfigs = {};
  final ParticularController _particleController = ParticularController();

  @override
  void initState() {
    _loadInitialConfigs();
    super.initState();
  }

  /// Loads the initial configurations for the application.
  ///
  /// This function does not have any parameters and does not return any value.
  void _loadInitialConfigs() async {
    final json = await rootBundle.loadString("assets/app_configs.json");
    _appConfigs = Map.castFrom(jsonDecode(json));
    setState(() {});

    // Add sample emitter
    await _particleController.addLayer();
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      final size = MediaQuery.of(context).size;
      _particleController.selectedLayer!.configs.update(
          emitterX: size.width * 0.5 - _appConfigs["inspector"]["width"] * 0.5,
          emitterY: (size.height +
                  _appConfigs["appBarHeight"] -
                  _appConfigs["timeline"]["height"] -
                  _appConfigs["footerHeight"]) *
              0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_appConfigs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return MaterialApp(
      title: "Particular Editor",
      theme: customTheme,
      home: Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HeaderView(
                    appConfigs: _appConfigs,
                    controller: _particleController,
                    onBackroundImageChanged: (image) {
                      setState(() => _backgroundImage = image);
                    },
                  ),
                  _canvasBuilder(),
                  FooterView(
                    appConfigs: _appConfigs,
                    controller: _particleController,
                  ),
                  TimelineView(
                    appConfigs: _appConfigs,
                    controller: _particleController,
                  ),
                ],
              ),
            ),
            InspectorView(
              appConfigs: _appConfigs,
              controller: _particleController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _canvasBuilder() {
    return Expanded(
      child: GestureDetector(
        onPanUpdate: (details) {
          _particleController.selectedLayer?.configs.updateFromMap({
            "emitterX": details.localPosition.dx,
            "emitterY": details.localPosition.dy
          });
        },
        onTapDown: (details) {
          _particleController.resetTick();
          _particleController.selectedLayer?.configs.updateFromMap({
            "emitterX": details.localPosition.dx,
            "emitterY": details.localPosition.dy
          });
        },
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.black,
              image: _backgroundImage == null
                  ? null
                  : DecorationImage(image: MemoryImage(_backgroundImage!))),
          child: Particular(
            controller: _particleController,
          ),
        ),
      ),
    );
  }
}
