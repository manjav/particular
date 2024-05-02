import 'dart:convert';

import 'package:editor/display/footer_view.dart';
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
    await _particleController.addParticle();
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
        appBar: _appBarBuilder(),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
            InspactorView(
              appConfigs: _appConfigs,
              controller: _particleController,
            ),
          ],
        ),
      ),
    );
  }

  AppBar _appBarBuilder() {
    return AppBar(
      centerTitle: false,
      title: const Text("Particular Editor"),
      toolbarHeight: _appConfigs["appBarHeight"],
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
          decoration: const BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.black,
          ),
          child: ListenableBuilder(
            listenable: _particleController.getNotifier(NotifierType.layer),
            builder: (context, child) {
              return Stack(
                children: [
                  for (var layerConfigs in _particleController.layers)
                    // if (configs.isVisible)
                    Particular(
                      configs: layerConfigs,
                      controller: _particleController,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
