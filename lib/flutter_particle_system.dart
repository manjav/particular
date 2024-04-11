// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:convert';
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
  double _devicePixelRatio = 1;
  ColorData? startColor;
  ColorData? startColorVariance;
  ColorData? finishColor;
  ColorData? finishColorVariance;
  ui.Image? _particleImage;
  Map _configs = {};
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

  @override
  Widget build(BuildContext context) {
    if (_particleImage == null) return const SizedBox();
    return Container(
      color: widget.color,
      width: widget.width,
      height: widget.height,
    );
  }


class ColorData {
  final num a, r, g, b;
  ColorData(this.a, this.r, this.g, this.b);
}
