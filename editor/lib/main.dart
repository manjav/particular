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
    await _particleController.addParticleSystem();
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      final size = MediaQuery.of(context).size;
      _particleController.selected!.update(
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
                  TimelineView(
                    appConfigs: _appConfigs,
                    controllers: _particleController,
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
        bottomNavigationBar: FooterView(
          appConfigs: _appConfigs,
          controllers: _particleController,
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
          _particleController.selected?.update(
            emitterX: details.localPosition.dx,
            emitterY: details.localPosition.dy,
          );
        },
        onTapDown: (details) {
          _particleController.resetTick();
          _particleController.selected?.update(
            emitterX: details.localPosition.dx,
            emitterY: details.localPosition.dy,
          );
        },
        child: Container(
          color: Colors.black,
          child: ValueListenableBuilder(
            valueListenable: _particleController,
            builder: (context, value, child) {
              return Stack(
                children: [
                  for (var configs in _particleController.value)
                    // if (configs.isVisible)
                    Particular(
                      configs: configs,
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
