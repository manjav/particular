import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:particular/particular.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Add controller to change particle
  final _particleController = ParticularController();

  @override
  void initState() {
    _createParticles();
    super.initState();
  }

  // Load configs and texture of particle
  Future<void> _createParticles() async {

    // Load particle configs file
    final fireworkJson = await rootBundle.loadString("assets/firework.json");
    final fireworkConfigs = jsonDecode(fireworkJson);
    _particleController.addConfigLayer(configsData: fireworkConfigs);

    // Or add (Flame) particle layer programmatically
    final bytes = await rootBundle.load("assets/texture.png");
    ui.Image? flameTexture = await loadUIImage(bytes.buffer.asUint8List());

    final flameConfigs = ParticularConfigs();
    flameConfigs.update(
      startSize: 100,
      startSizeVariance: 20,
      finishSize: 40,
      emitterX: 200,
      emitterY: 500,
      gravityY: -800,
      speed: 200,
      speedVariance: 5,
      sourcePositionVarianceX: 60,
      startColor: ARGB(1, 1, 0.2, 0),
      renderBlendMode: ui.BlendMode.dstIn,
      textureBlendMode: ui.BlendMode.plus,
    );

    final layer = ParticularLayer(texture: flameTexture, configs: flameConfigs);
    _particleController.addParticularLayer(layer);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Particular(
          controller: _particleController,
        ),
      ),
    );
  }
}
