import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:particular/particular.dart';

/// A widget that represents a particle system.
class Particular extends StatefulWidget {
  /// The controller for the particle system.
  final ParticularController? controller;

  /// Creates a [Particular] widget.
  const Particular({
    super.key,
    this.controller,
  });

  @override
  State<Particular> createState() => _ParticularState();
}

/// The state for the [Particular] widget.
class _ParticularState extends State<Particular>
    with SingleTickerProviderStateMixin {
  /// The ticker for animation.
  Ticker? _ticker;

  /// The device pixel ratio.
  double _devicePixelRatio = 1;

  /// The rectangles representing particles.
  final List<Rect> _rectangles = [];

  /// The particles in the system.
  final List<Particle> _particles = [];

  /// The colors of particles.
  final List<ParticleColor> _colors = [];

  /// The indices of the dead particles.
  final List<int> _deadParticleIndices = [];

  /// The transforms of particles.
  final List<ParticleTransform> _transforms = [];

  /// The time difference between frames.
  int _deltaTime = 0;

  /// The time reserved of the last frame.
  int _lastFrameTime = 0;

  @override
  void initState() {
    super.initState();
    widget.controller!.addListener(() {
      if (widget.controller!.texture == null) return;
      _devicePixelRatio =
          MediaQuery.of(context).devicePixelRatio; //2.65, 411.4, 867.4
      _spawn(0);
      _iterate();
    });
  }

  /// Iterates over frames.
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

  /// Spawns a particle.
  void _spawn([int age = 0]) {
    Particle particle;
    if (_deadParticleIndices.isEmpty) {
      particle = Particle();
      _colors.add(particle.color);
      _transforms.add(particle.transform);
      _rectangles.add(const Rect.fromLTWH(0, 0, 36, 36));
      _particles.add(particle);
    } else {
      particle = _particles[_deadParticleIndices.removeLast()];
    }
    final ParticularController controller = widget.controller!;
    particle.initialize(
      age: age,
      emitterType: controller.emitterType,
      emitterX: controller.getEmitterX(1),
      emitterY: controller.getEmitterY(1),
      startSize: controller.getStartSize(1),
      finishSize: controller.getFinishSize(1),
      startColor: controller.getStartColor(),
      finishColor: controller.getFinishColor(),
      angle: controller.getAngle(),
      lifespan: controller.getLifespan(),
      speed: controller.getSpeed(_devicePixelRatio),
      gravityX: controller.gravityX * _devicePixelRatio,
      gravityY: controller.gravityY * _devicePixelRatio,
      minRadius: controller.getMinRadius(1),
      maxRadius: controller.getMaxRadius(1),
      rotatePerSecond: controller.getRotatePerSecond(),
      radialAcceleration: controller.getRadialAcceleration(),
      tangentialAcceleration: controller.getTangentialAcceleration(),
    );
  }

  /// This method can potentially be called in every frame and should not have
  /// any side effects beyond building a widget.
  @override
  Widget build(BuildContext context) {
    if (widget.controller!.texture == null) {
      return const SizedBox();
    }
    return SizedBox(
      child: CustomPaint(
        painter: ParticlePainter(
          colors: _colors,
          deltaTime: _deltaTime,
          particles: _particles,
          rectangles: _rectangles,
          transforms: _transforms,
          deadParticleIndices: _deadParticleIndices,
          image: widget.controller!.texture!,
          blendMode: widget.controller!.blendMode,
          onFinished: () => _ticker?.stop(),
        ),
      ),
    );
  }

  /// Was called on the mixin, that Ticker was still active. The Ticker must be disposed.
  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }
}

/// A custom painter for rendering particles.
class ParticlePainter extends CustomPainter {
  /// The time difference between frames.
  final int deltaTime;

  /// The image to be used for particles.
  final ui.Image image;

  /// The blend mode for rendering particles.
  final BlendMode blendMode;

  /// A callback function called when particle rendering is finished.
  final Function() onFinished;

  /// The rectangles representing particles.
  final List<Rect> rectangles;

  /// The indices of particles.
  final List<int> deadParticleIndices;

  /// The particles to be rendered.
  final List<Particle> particles;

  /// The colors of particles.
  final List<ParticleColor> colors;

  /// The transforms of particles.
  final List<ParticleTransform> transforms;

  /// The paint object for rendering particles.
  final Paint _paint = Paint();

  /// Creates a [ParticlePainter] with the specified parameters.
  ParticlePainter({
    required this.image,
    required this.colors,
    required this.blendMode,
    required this.deltaTime,
    required this.particles,
    required this.transforms,
    required this.rectangles,
    required this.onFinished,
    required this.deadParticleIndices,
  }) {
    _paint.blendMode = blendMode;
  }

  /// Draws many parts of an image - the [atlas] - onto the canvas.
  @override
  void paint(Canvas canvas, Size size) {
    var allParticlesDead = true;
    for (var i = 0; i < particles.length; i++) {
      var particle = particles[i];
      particle.update(deltaTime);
      particle.transform.update(
        rotation: 0,
        translateX: particle.x,
        translateY: particle.y,
        anchorX: image.width * 0.5,
        anchorY: image.height * 0.5,
        scale: particle.size / image.width,
      );

      if (particle.isDead()) {
        deadParticleIndices.add(i);
        particle.color.update(
            0, particle.color.red, particle.color.green, particle.color.blue);
      } else {
        allParticlesDead = false;
      }
    }
    canvas.drawAtlas(
        image, transforms, rectangles, colors, BlendMode.dstIn, null, _paint);

    if (allParticlesDead) {
      onFinished();
    }
  }

  /// If the method returns false, then the [paint] call might be optimized
  /// away.
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
