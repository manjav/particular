// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_particle_system/flutter_particle.dart';
import 'package:image/image.dart' as image;

import 'flutter_particle_system_platform_interface.dart';

class FlutterParticleSystem extends StatefulWidget {
  Future<String?> getPlatformVersion() {
    return FlutterParticleSystemPlatform.instance.getPlatformVersion();
  }

  final Color? color;
  final String configs;
  final double width, height;
  double emitterX = 0, emitterY = 0;

  FlutterParticleSystem({
    super.key,
    this.color,
    this.width = 300,
    this.height = 300,
    this.emitterX = 150,
    this.emitterY = 150,
    required this.configs,
  });

  @override
  State<FlutterParticleSystem> createState() => _FlutterParticleSystemState();
}

class _FlutterParticleSystemState extends State<FlutterParticleSystem>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _devicePixelRatio = 1;
  final List<Particle> _pool = [];

  ColorData? startColor;
  ColorData? startColorVariance;
  ColorData? finishColor;
  ColorData? finishColorVariance;
  ui.Image? _particleImage;

  Map _configs = {};
  int _particleLifespan = 0;
  int _deltaTime = 0, _lastFrameTime = 0;

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    var json = await DefaultAssetBundle.of(context).loadString(widget.configs);
    _configs = jsonDecode(json);

    startColor = ColorData(
      _configs["startColorAlpha"],
      _configs["startColorRed"],
      _configs["startColorGreen"],
      _configs["startColorBlue"],
    );
    startColorVariance = ColorData(
      _configs["startColorVarianceAlpha"],
      _configs["startColorVarianceRed"],
      _configs["startColorVarianceGreen"],
      _configs["startColorVarianceBlue"],
    );

    finishColor = ColorData(
      _configs["finishColorAlpha"],
      _configs["finishColorRed"],
      _configs["finishColorGreen"],
      _configs["finishColorBlue"],
    );
    finishColorVariance = ColorData(
      _configs["finishColorVarianceAlpha"],
      _configs["finishColorVarianceRed"],
      _configs["finishColorVarianceGreen"],
      _configs["finishColorVarianceBlue"],
    );
    if (!mounted) {
      return;
    }

    _devicePixelRatio = 1 / MediaQuery.of(context).devicePixelRatio;

    _particleImage =
        await _getImage("assets/${_configs["textureFileName"]}", 32, 32);
    _particleLifespan = _getDouble("particleLifespan", 1000).round();

    _spawn();

    var duration = _configs["duration"] * 1000;
    _ticker = createTicker((elapsed) {
      // Spawn particles
      if (duration < 0 || elapsed.inMilliseconds < duration) {
        var particlesPerTick =
            (_deltaTime * _configs["maxParticles"] / _particleLifespan).round();
        for (var i = 0; i < particlesPerTick; i++) {
          _spawn((i * _deltaTime / particlesPerTick).round());
        }
      }

      _deltaTime = elapsed.inMilliseconds - _lastFrameTime;
      _lastFrameTime += _deltaTime;
      setState(() {});
    });

    _ticker.start();
  }

  Particle _spawn([int age = 0]) {
    var particle = _pool.firstWhere(
      (p) => p.isDead(),
      orElse: () {
        var p = Particle();
        _pool.add(p);
        return p;
      },
    );

    return particle
      ..initialize(
        age: age,
        emitterType: EmitterType.values[_configs["emitterType"]],
        emitterX: _getValue(widget.emitterX,
                _configs["sourcePositionVariancex"] * _devicePixelRatio)
            .toDouble(),
        emitterY: _getValue(widget.emitterY,
                _configs["sourcePositionVariancey"] * _devicePixelRatio)
            .toDouble(),
        startSize: _getDouble("startParticleSize", _devicePixelRatio),
        finishSize: _getDouble("finishParticleSize", _devicePixelRatio),
        speed: _getDouble("speed", _devicePixelRatio),
        angle: _getDouble("angle"),
        lifespan: _particleLifespan,
        gravityX: _configs["gravityx"].toDouble() * _devicePixelRatio,
        gravityY: _configs["gravityy"].toDouble() * _devicePixelRatio,
        minRadius: _getDouble("minRadius", _devicePixelRatio),
        maxRadius: _getDouble("maxRadius", _devicePixelRatio),
        rotatePerSecond: _getDouble("rotatePerSecond"),
        radialAcceleration: _getValue(
                _configs["radialAcceleration"], _configs["radialAccelVariance"])
            .toDouble(),
        tangentialAcceleration: _getValue(_configs["tangentialAcceleration"],
                _configs["tangentialAccelVariance"])
            .toDouble(),
        startColor: _getColor(startColor!, startColorVariance!),
        finishColor: _getColor(finishColor!, finishColorVariance!),
      );
  }

  Color _getColor(ColorData base, ColorData variance) {
    var alpha = _getValue(base.a, variance.a, 255).clamp(0, 255).round();
    var red = _getValue(base.r, variance.r, 255).clamp(0, 255).round();
    var green = _getValue(base.g, variance.g, 255).clamp(0, 255).round();
    var blue = _getValue(base.b, variance.b, 255).clamp(0, 255).round();
    return Color.fromARGB(alpha, red, green, blue);
  }

  num _getValue(num base, num variance, [num coef = 1]) {
    if (variance == 0) {
      return (base * coef);
    }
    return (base + variance * (math.Random().nextDouble() * 2.0 - 1.0)) * coef;
  }

  double _getDouble(String name, [num coef = 1]) =>
      _getValue(_configs[name], _configs["${name}Variance"], coef).toDouble();

  Future<ui.Image> _getImage(
      String imageAssetPath, int height, int width) async {
    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    image.Image? baseSizeImage =
        image.decodeImage(assetImageByteData.buffer.asUint8List());
    image.Image resizeImage =
        image.copyResize(baseSizeImage!, height: height, width: width);
    ui.Codec codec =
        await ui.instantiateImageCodec(image.encodePng(resizeImage));
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  BlendMode _getBlendMode() {
    int s = _configs["blendFuncSource"];
    int d = _configs["blendFuncDestination"];
    if (d == 0) return BlendMode.clear;
    if (s == 0) {
      return switch (d) {
        0x301 => BlendMode.screen, //erase
        0x302 => BlendMode.srcIn, //mask
        _ => BlendMode.srcOver,
      };
    }
    if (s == 1) {
      return switch (d) {
        1 => BlendMode.plus,
        0x301 => BlendMode.screen,
        _ => BlendMode.srcOver,
      };
    }
    if (s == 0x306 && d == 0x303) {
      return ui.BlendMode.multiply;
    }
    if (s == 0x305 && d == 0x304) {
      return BlendMode.dst;
    }
    // 0=>      BlendMode.zero,
    // 1=>      BlendMode.color,
    // 0x300=>  BlendMode.SOURCE_COLOR,
    // 0x301=>  BlendMode.ONE_MINUS_SOURCE_COLOR,
    // 0x302=>  BlendMode.SOURCE_ALPHA,
    // 0x303=>  BlendMode.ONE_MINUS_SOURCE_ALPHA,
    // 0x304=>  BlendMode.DESTINATION_ALPHA,
    // 0x305=>  BlendMode.ONE_MINUS_DESTINATION_ALPHA,
    // 0x306=>  BlendMode.DESTINATION_COLOR,
    // 0x307=>  BlendMode.ONE_MINUS_DESTINATION_COLOR,

    // "none":,ONE, ZERO
    // "normal": ONE, ONE_MINUS_SOURCE_ALPHA
    // "add": ONE, ONE
    // "screen": ONE, ONE_MINUS_SOURCE_COLOR
    // "erase": ZERO, ONE_MINUS_SOURCE_ALPHA
    // "mask": ZERO, SOURCE_ALPHA
    // "multiply": DESTINATION_COLOR, ONE_MINUS_SOURCE_ALPHA
    // "below": ONE_MINUS_DESTINATION_ALPHA, DESTINATION_ALPHA
    return BlendMode.srcOver;
  }

  @override
  Widget build(BuildContext context) {
    if (_particleImage == null) return const SizedBox();
    return Container(
      color: widget.color,
      width: widget.width,
      height: widget.height,
      child: CustomPaint(
        painter: ParticlePainter(
          particles: _pool,
          deltaTime: _deltaTime,
          image: _particleImage!,
          blendMode: _getBlendMode(),
          onFinished: () => _ticker.stop(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}

class ParticlePainter extends CustomPainter {
  final int deltaTime;
  final ui.Image image;
  final BlendMode blendMode;
  final Function() onFinished;
  final List<Particle> particles;
  final Paint _paint = Paint()..blendMode = BlendMode.plus;

  ParticlePainter({
    required this.image,
    required this.blendMode,
    required this.deltaTime,
    required this.particles,
    required this.onFinished,
  });
  @override
  void paint(Canvas canvas, Size size) {
    var skipped = true;
    for (var particle in particles) {
      particle.update(deltaTime);
      if (particle.isDead()) {
        continue;
      }
      skipped = false;

      // canvas.saveLayer(
      //     Rect.fromCircle(center: Offset(size.width, size.height), radius: 100),
      //     paint);

      canvas.drawAtlas(
          image,
          [
            RSTransform.fromComponents(
                rotation: particle.angle,
                scale: particle.size / image.width,
                anchorX: image.width * 0.5,
                anchorY: image.height * 0.5,
                translateX: particle.x,
                translateY: particle.y)
          ],
          [
            /* The size of gray image is 60 x 60  */
            const Rect.fromLTWH(0, 0, 36, 36)
          ],
          [particle.color],
          BlendMode.dstATop,
          null,
          _paint);
      // canvas.restore();
    }
    if (skipped) onFinished();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
