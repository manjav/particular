import 'dart:convert';

import 'package:editor/data/controllers.dart';
import 'package:editor/display/footer_view.dart';
import 'package:editor/display/inspector_view.dart';
import 'package:editor/display/timeline_view.dart';
import 'package:editor/services/io.dart';
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
  late final ui.Image _defaultTexture;
  final ParticularControllers _particleControllers = ParticularControllers();

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

    /// Load default particle texture
    final bytes = await rootBundle.load("assets/texture.png");
    _defaultTexture = await loadUIImage(bytes.buffer.asUint8List());
    setState(() {});

    // Add sample emitter
    _addParticleSystem();
  }

  @override
  Widget build(BuildContext context) {
    if (_appConfigs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return MaterialApp(
      title: "Particular Editor",
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        appBar: _appBarBuilder(),
        bottomNavigationBar: _footerBuilder(),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _canvasBuilder(),
                  TimelineView(
                    configs: _appConfigs,
                    controllers: _particleControllers,
                  ),
                ],
              ),
            ),
            InspactorView(
              configs: _appConfigs,
              controllers: _particleControllers,
            ),
          ],
        ),
        bottomNavigationBar: FooterView(
          appConfigs: _appConfigs,
          controllers: _particleControllers,
        ),
      ),
    );
  }

  AppBar _appBarBuilder() {
    return AppBar(
      toolbarHeight: _appConfigs["appBarHeight"] * 1.0,
      title: Text("Particular Editor",
          style: Theme.of(context).primaryTextTheme.bodyMedium),
      backgroundColor: Theme.of(context).tabBarTheme.indicatorColor,
    );
  }

  Widget _canvasBuilder() {
    return Expanded(
      child: GestureDetector(
        onPanUpdate: (details) {
          _particleControllers.selected?.update(
            emitterX: details.localPosition.dx,
            emitterY: details.localPosition.dy,
          );
        },
        onTapDown: (details) {
          _particleControllers.selected?.update(
            emitterX: details.localPosition.dx,
            emitterY: details.localPosition.dy,
            startTime: -1,
          );
        },
        child: Container(
          color: Colors.black,
          child: ValueListenableBuilder(
            valueListenable: _particleControllers,
            builder: (context, value, child) {
              return Stack(
                children: [
                  for (var c in _particleControllers.value)
                    if (c.isVisible)
                      Particular(key: Key("${c.index}"), controller: c),
                ],
              );
            },
          ),
        ),
      ),
    );
  }


  /// Adds a particle system to the application.
  ///
  /// The [configs] parameter is an optional map of configurations for the particle system.
  Future<void> _addParticleSystem({Map<dynamic, dynamic>? configs}) async {
    final controller = ParticularEditorController();
    controller.initialize(texture: _defaultTexture, configs: configs);
    _particleControllers.add(controller);
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      final size = MediaQuery.of(context).size;
      controller.update(
        emitterX: size.width * 0.5 - _appConfigs["inspector"]["width"] * 0.5,
        emitterY: (size.height +
                _appConfigs["appBarHeight"] -
                _appConfigs["timeline"]["height"] -
                _appConfigs["footerHeight"]) *
            0.5,
      );
    }
  }
}
