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

  /// Creates the state for the [Particular] widget.
  ///
  /// Returns a new instance of [_ParticularState].
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
  final List<ParticleRect> _rectangles = [];

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

  /// Initializes the state of the widget.
  ///
  /// This method is called when the widget is first created and when it is rebuilt.
  /// It is responsible for setting up the initial state of the widget.
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
    _ticker = createTicker(_onTick);
    _ticker!.start();
  }

  // Updates the configuration based on the elapsed time, spawns particles, and updates the frame time.
  void _onTick(Duration elapsed) {
    var config = widget.controller!;
    if (config.startTime < 0) {
      config.startTime = elapsed.inMilliseconds - _deltaTime;
      _lastFrameTime = 0;
    }
    final now = elapsed.inMilliseconds - config.startTime;

    // Spawn particles
    if (config.duration < 0 || now < config.duration) {
      var particlesPerTick =
          (_deltaTime * config.maxParticles / config.lifespan).round();
      for (var i = 0; i < particlesPerTick; i++) {
        _spawn((i * _deltaTime / particlesPerTick).round());
      }
    }

    _deltaTime = now - _lastFrameTime;
    _lastFrameTime += _deltaTime;
    setState(() {});
  }

  /// Spawns a particle.
  ///
  /// Spawns a particle object with the given age. If there are no dead particles in the
  /// pool, a new particle object is created and added to the pool. Otherwise, a dead
  /// particle object is resurrected and added to the pool. The particle object is
  /// initialized with the given parameters.
  ///
  /// Parameters:
  ///   - age: The age of the particle. Defaults to 0.
  ///
  /// Returns: None.
  void _spawn([int age = 0]) {
    Particle particle;
    final ParticularController controller = widget.controller!;
    if (_deadParticleIndices.isEmpty) {
      particle = Particle();
      _colors.add(particle.color);
      _transforms.add(particle.transform);
      _rectangles.add(ParticleRect.fromLTWH(
          0,
          0,
          controller.texture!.width.toDouble(),
          controller.texture!.height.toDouble()));
      _particles.add(particle);
    } else {
      particle = _particles[_deadParticleIndices.removeLast()];
    }
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
      startRotation: controller.getStartRotaion(),
      finishRotation: controller.getFinishRotaion(),
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
          renderBlendMode: widget.controller!.renderBlendMode,
          textureBlendMode: widget.controller!.textureBlendMode,
          onFinished: () {},
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

  /// A callback function called when particle rendering is finished.
  final Function() onFinished;

  /// The rectangles representing particles.
  final List<ParticleRect> rectangles;

  /// The indices of particles.
  final List<int> deadParticleIndices;

  /// The particles to be rendered.
  final List<Particle> particles;

  /// The colors of particles.
  final List<ParticleColor> colors;

  /// The transforms of particles.
  final List<ParticleTransform> transforms;

  /// The blend mode for atlas.
  final BlendMode renderBlendMode;

  /// The blend mode for rendering particles.
  final BlendMode textureBlendMode;

  /// The paint object for rendering particles.
  final Paint _paint = Paint();

  /// Creates a [ParticlePainter] with the specified parameters.
  ParticlePainter({
    required this.image,
    required this.colors,
    required this.deltaTime,
    required this.particles,
    required this.transforms,
    required this.rectangles,
    required this.onFinished,
    required this.renderBlendMode,
    required this.textureBlendMode,
    required this.deadParticleIndices,
  }) {
    _paint.blendMode = textureBlendMode;
  }

  /// Draws many parts of an image - the [atlas] - onto the canvas.
  @override
  void paint(Canvas canvas, Size size) {
    var allParticlesDead = true;
    for (var i = 0; i < particles.length; i++) {
      var particle = particles[i];
      rectangles[i].update(image.width, image.height);
      particle.update(deltaTime);
      particle.transform.update(
        rotation: particle.rotation,
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
        image, transforms, rectangles, colors, renderBlendMode, null, _paint);

    if (allParticlesDead) {
      onFinished();
    }
  }

  /// If the method returns false, then the [paint] call might be optimized
  /// away.
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
