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
import 'package:particular/particle.dart';
import 'package:particular/particular_controller.dart';
import 'package:particular/particular_platform_interface.dart';

class Particular extends StatefulWidget {
  Future<String?> getPlatformVersion() =>
      ParticularPlatform.instance.getPlatformVersion();

  final Color? color;
  final double width, height;
  final ParticularController? controller;

  const Particular({
    super.key,
    this.color,
    this.width = 300,
    this.height = 300,
    this.controller,
  });

  @override
  State<Particular> createState() => _ParticularState();
}

class _ParticularState extends State<Particular>
    with SingleTickerProviderStateMixin {
  Ticker? _ticker;
  double _devicePixelRatio = 1;
  final List<Rect> _rects = [];
  final List<int> _indices = [];
  final List<Particle> _particles = [];
  final List<ParticleColor> _colors = [];
  final List<ParticleTransform> _transforms = [];
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
    Particle particle;
    if (_indices.isEmpty) {
      particle = Particle();
      _colors.add(particle.color);
      _transforms.add(particle.transform);
      _rects.add(const Rect.fromLTWH(0, 0, 36, 36));
      _particles.add(particle);
    } else {
      particle = _particles[_indices.removeLast()];
    }
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
          rects: _rects,
          colors: _colors,
          indices: _indices,
          particles: _particles,
          transforms: _transforms,
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
  final List<Rect> rects;
  final List<int> indices;
  final List<Particle> particles;
  final List<ParticleColor> colors;
  final List<ParticleTransform> transforms;
  final Paint _paint = Paint()..blendMode = BlendMode.plus;

  ParticlePainter({
    required this.image,
    required this.blendMode,
    required this.deltaTime,
    required this.rects,
    required this.colors,
    required this.indices,
    required this.particles,
    required this.transforms,
    required this.onFinished,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var skipped = true;
    for (var i = 0; i < particles.length; i++) {
      var particle = particles[i];
      particle.update(deltaTime);
      particle.transform.update(
        rotation: 0,
        scale: particle.size / image.width,
        anchorX: image.width * 0.5,
        anchorY: image.height * 0.5,
        translateX: particle.x,
        translateY: particle.y,
      );

      if (particle.isDead()) {
        indices.add(i);
      } else {
        skipped = false;
      }
      // canvas.saveLayer(
      //     Rect.fromCircle(center: Offset(size.width, size.height), radius: 100),
      //     paint);

      // canvas.restore();
    }
    canvas.drawAtlas(
        image, transforms, rects, colors, BlendMode.dstATop, null, _paint);

    if (skipped) onFinished();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
