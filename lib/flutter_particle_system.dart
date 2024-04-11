// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  Map _configs = {};
  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    var json = await DefaultAssetBundle.of(context).loadString(widget.configs);
    _configs = jsonDecode(json);
  @override
  Widget build(BuildContext context) {
    if (_particleImage == null) return const SizedBox();
    return Container(
      color: widget.color,
      width: widget.width,
      height: widget.height,
    );
  }

}
