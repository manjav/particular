// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_particle_system/flutter_particle.dart';
import 'package:flutter_particle_system/flutter_particle_cotroller.dart';

import 'flutter_particle_system_platform_interface.dart';

class FlutterParticleSystem extends StatefulWidget {
  Future<String?> getPlatformVersion() =>
      FlutterParticleSystemPlatform.instance.getPlatformVersion();

  final Color? color;
  final double width, height;
  final FlutterParticleController? controller;

  const FlutterParticleSystem({
    super.key,
    this.color,
    this.width = 300,
    this.height = 300,
    this.controller,
  });

  @override
  State<FlutterParticleSystem> createState() => _FlutterParticleSystemState();
}

class _FlutterParticleSystemState extends State<FlutterParticleSystem>
    with SingleTickerProviderStateMixin {
  Ticker? _ticker;
  double _devicePixelRatio = 1;
  final List<Particle> _pool = [];
  int _deltaTime = 0, _lastFrameTime = 0;

  @override
  void initState() {
    super.initState();
    widget.controller!.addListener(() {
      if (widget.controller!.image == null) return;
      _devicePixelRatio = 1 / MediaQuery.of(context).devicePixelRatio;
      _spawn(0);
      _iterate();
    });
  }

  Future<void> _iterate() async {
    if (_ticker != null) return;
    _ticker = createTicker((elapsed) {
      var config = widget.controller!;

      // Spawn particles
      if (config.duration < 0 || elapsed.inMilliseconds < config.duration) {
        var particlesPerTick =
            (_deltaTime * config.maxParticles / config.lifespan).round();
        for (var i = 0; i < particlesPerTick; i++) {
          _spawn((i * _deltaTime / particlesPerTick).round());
        }
      }

      _deltaTime = elapsed.inMilliseconds - _lastFrameTime;
      _lastFrameTime += _deltaTime;
      setState(() {});
    });

    _ticker!.start();
  }

  void _spawn([int age = 0]) {
    var particle = _pool.firstWhere(
      (p) => p.isDead(),
      orElse: () {
        var p = Particle();
        _pool.add(p);
        return p;
      },
    );
    var c = widget.controller!;
    particle.initialize(
      age: age,
      emitterType: c.emitterType,
      emitterX: c.getEmitterX(_devicePixelRatio),
      emitterY: c.getEmitterY(_devicePixelRatio),
      startSize: c.getStartSize(_devicePixelRatio),
      finishSize: c.getFinishSize(_devicePixelRatio),
      speed: c.getSpeed(_devicePixelRatio),
      angle: c.getAngle(),
      lifespan: c.getLifespan(),
      gravityX: c.gravityX * _devicePixelRatio,
      gravityY: c.gravityY * _devicePixelRatio,
      minRadius: c.getMinRadius(_devicePixelRatio),
      maxRadius: c.getMaxRadius(_devicePixelRatio),
      rotatePerSecond: c.getRotatePerSecond(),
      radialAcceleration: c.getradialAcceleration(),
      tangentialAcceleration: c.getTangentialAcceleration(),
      startColor: c.getStartColor(),
      finishColor: c.getFinishColor(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller!.image == null) {
      return const SizedBox();
    }
    return Container(
      color: widget.color,
      width: widget.width,
      height: widget.height,
      child: CustomPaint(
        painter: ParticlePainter(
          particles: _pool,
          deltaTime: _deltaTime,
          image: widget.controller!.image!,
          blendMode: widget.controller!.getBlendMode(),
          onFinished: () => _ticker?.stop(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ticker?.dispose();
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
    // print("$deltaTime, ${particles.length}");
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
