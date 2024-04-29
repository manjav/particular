import 'dart:convert';

import 'package:editor/data/controllers.dart';
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
    setState(() {});

    // Add sample emitter
    await _particleControllers.addParticleSystem();
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      final size = MediaQuery.of(context).size;
      _particleControllers.selected!.update(
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
                    controllers: _particleControllers,
                  ),
                ],
              ),
            ),
            InspactorView(
              appConfigs: _appConfigs,
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
}
