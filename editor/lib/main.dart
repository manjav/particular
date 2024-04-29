import 'dart:convert';

import 'package:editor/data/particular_editor_controller.dart';
import 'package:editor/display/inspector_view.dart';
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
  Map _appConfigs = {};
  late final ui.Image _defaultTexture;
  final _particleController = ParticularEditorController();

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

    // // Add sample emitter
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      var size = MediaQuery.of(context).size;
      _particleController.update(
        emitterX: size.width * 0.5 - _appConfigs["inspector"]["width"] * 0.5,
        emitterY: size.height * 0.5 + _appConfigs["appBarHeight"] * 0.5,
      );
    }
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
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _canvasBuilder(),
            InspactorView(
              configs: _appConfigs,
              controller: _particleController,
            ),
          ],
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
      actions: [
        IconButton(
            onPressed: () async {
              final configs = await browseConfigs(["json"]);
              _particleController.initialize(configs: configs);
            },
            icon: const Icon(Icons.file_open_outlined)),
        const SizedBox(width: 8),
        IconButton(
            onPressed: () => saveConfigs(_particleController.getConfigs()),
            icon: const Icon(Icons.save)),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _canvasBuilder() {
    return Expanded(
      child: GestureDetector(
        onPanUpdate: (details) {
          _particleController.update(
            emitterX: details.localPosition.dx,
            emitterY: details.localPosition.dy,
          );
        },
        onTapDown: (details) {
          _particleController.update(
            emitterX: details.localPosition.dx,
            emitterY: details.localPosition.dy,
            startTime: -1,
          );
        },
        child: Container(
          color: Colors.black,
          child: Particular(
            controller: _particleController,
          ),
        ),
      ),
    );
  }

  Future<void> _addParticleSystem() async {
    final controller = ParticularEditorController();
    controller.initialize(texture: _defaultTexture);
    _particleControllers.add(controller);
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      final size = MediaQuery.of(context).size;
      controller.update(
        emitterX: size.width * 0.5 - _appConfigs["inspector"]["width"] * 0.5,
        emitterY: (size.height - _appConfigs["appBarHeight"]) * 0.5,
      );
    }
  }
}
