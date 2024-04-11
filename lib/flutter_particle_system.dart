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
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;

import 'flutter_particle_system_platform_interface.dart';

class FlutterParticleSystem extends StatefulWidget {
  Future<String?> getPlatformVersion() {
    return FlutterParticleSystemPlatform.instance.getPlatformVersion();
  }

  final Color? color;
  final String configs;
  final double width, height;

  const FlutterParticleSystem({
    super.key,
    this.color,
    this.width = 300,
    this.height = 300,
    required this.configs,
  });

  @override
  State<FlutterParticleSystem> createState() => _FlutterParticleSystemState();
}

class _FlutterParticleSystemState extends State<FlutterParticleSystem>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _devicePixelRatio = 1;
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


    var duration = _configs["duration"] * 1000;
    _ticker = createTicker((elapsed) {

      _deltaTime = elapsed.inMilliseconds - _lastFrameTime;
      _lastFrameTime += _deltaTime;
      setState(() {});
    });

    _ticker.start();
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
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}

enum EmitterType { gravity, radius }

class Particle {
  final EmitterType emitterType;
  final int lifespan;
  final double speed;
  final double startSize, finishSize;
  final Color startColor, finishColor;

  double size = 100;
  Color color = Colors.white;

  double x = 0, y = 0, angle = 0, radius = 0, radiusDelta = 0;
  double emitterX = 0, emitterY = 0;
  double velocityX = 0, velocityY = 0;

  int _age = 0;
  final double minRadius, maxRadius, rotatePerSecond;
  final double radialAcceleration, tangentialAcceleration, gravityX, gravityY;

  Particle({
    this.emitterType = EmitterType.gravity,
    required this.speed,
    required this.angle,
    required this.emitterX,
    required this.emitterY,
    required this.lifespan,
    required this.startSize,
    required this.finishSize,
    required this.startColor,
    required this.finishColor,
    this.minRadius = 0,
    this.maxRadius = 0,
    this.rotatePerSecond = 0,
    this.radialAcceleration = 0,
    this.tangentialAcceleration = 0,
    this.gravityX = 0,
    this.gravityY = 0,
  }) {
    x = emitterX;
    y = emitterY;
    size = startSize;
    velocityX = speed * math.cos(angle / 180.0 * math.pi);
    velocityY = speed * math.sin(angle / 180.0 * math.pi);
    radius = maxRadius;
    radiusDelta = (minRadius - maxRadius);
    color = startColor;
  }

  void update(int deltaTime) {
    _age += deltaTime;
    var ratio = _age / lifespan;
    var rate = deltaTime / lifespan;

    angle -= rotatePerSecond * rate;
    if (emitterType == EmitterType.radius) {
      radius += radiusDelta * rate;
      x = emitterX - math.cos(angle / 180.0 * math.pi) * radius;
      y = emitterY - math.sin(angle / 180.0 * math.pi) * radius;
    } else {
      var distanceX = x - emitterX;
      var distanceY = y - emitterY;
      var distanceScalar =
          math.sqrt(distanceX * distanceX + distanceY * distanceY);
      if (distanceScalar < 0.01) distanceScalar = 0.01;

      var radialX = distanceX / distanceScalar;
      var radialY = distanceY / distanceScalar;
      var tangentialX = radialX;
      var tangentialY = radialY;

      radialX *= radialAcceleration;
      radialY *= radialAcceleration;

      var newY = tangentialX;
      tangentialX = -tangentialY * tangentialAcceleration;
      tangentialY = newY * tangentialAcceleration;

      velocityX += rate * (gravityX + radialX + tangentialX);
      velocityY += rate * (gravityY + radialY + tangentialY);
      x += velocityX * rate;
      y += velocityY * rate;
    }

    color = Color.lerp(startColor, finishColor, ratio)!;
    size = startSize + (finishSize - startSize) * ratio;
  }

  bool isDead() {
    return _age >= lifespan;
  }

  static double doubleInRange(double min, double max) =>
      math.Random().nextDouble() * (max - min) + min;
}

class ColorData {
  final num a, r, g, b;
  ColorData(this.a, this.r, this.g, this.b);
}
