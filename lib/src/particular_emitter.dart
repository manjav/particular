import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:particular/particular.dart';

/// A widget that represents a particle system.
class Particular extends StatefulWidget {
  /// The configurations for the particle system.
  final ParticularConfigs configs;

  /// The controller for the particle system.
  final ParticularController controller;

  /// Creates a [Particular] widget.
  const Particular({
    super.key,
    required this.configs,
    required this.controller,
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

  /// Initializes the state of the widget.
  ///
  /// This method is called when the widget is first created and when it is rebuilt.
  /// It is responsible for setting up the initial state of the widget.
  @override
  void initState() {
    super.initState();
    _devicePixelRatio = 1;
//        MediaQuery.of(context).devicePixelRatio; //2.65, 411.4, 867.4
    widget.controller
        .getNotifier(NotifierType.time)
        .addListener(_onControllerTick);
  }

  void _onControllerTick() {
    var configs = widget.configs;
    var controller = widget.controller;

    // Spawn particles
    if (configs.duration < 0 ||
        (controller.elapsedTime >= configs.startTime &&
            controller.elapsedTime < configs.duration)) {
      var particlesPerTick =
          (controller.deltaTime * configs.maxParticles / configs.lifespan)
              .round();
      for (var i = 0; i < particlesPerTick; i++) {
        _spawn((i * controller.deltaTime / particlesPerTick).round());
      }
    }
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
    final configs = widget.configs;
    Particle particle;
    if (_deadParticleIndices.isEmpty) {
      particle = Particle();
      _colors.add(particle.color);
      _transforms.add(particle.transform);
      _rectangles.add(ParticleRect.fromLTWH(
          0,
          0,
          configs.texture!.width.toDouble(),
          configs.texture!.height.toDouble()));
      _particles.add(particle);
    } else {
      particle = _particles[_deadParticleIndices.removeLast()];
    }
    particle.initialize(
      age: age,
      emitterType: configs.emitterType,
      emitterX: configs.getEmitterX(1),
      emitterY: configs.getEmitterY(1),
      startSize: configs.getStartSize(1),
      finishSize: configs.getFinishSize(1),
      startColor: configs.getStartColor(),
      finishColor: configs.getFinishColor(),
      angle: configs.getAngle(),
      lifespan: configs.getLifespan(),
      speed: configs.getSpeed(_devicePixelRatio),
      gravityX: configs.gravityX * _devicePixelRatio,
      gravityY: configs.gravityY * _devicePixelRatio,
      minRadius: configs.getMinRadius(1),
      maxRadius: configs.getMaxRadius(1),
      rotatePerSecond: configs.getRotatePerSecond(),
      startRotation: configs.getStartRotaion(),
      finishRotation: configs.getFinishRotaion(),
      radialAcceleration: configs.getRadialAcceleration(),
      tangentialAcceleration: configs.getTangentialAcceleration(),
    );
  }

  /// This method can potentially be called in every frame and should not have
  /// any side effects beyond building a widget.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: CustomPaint(
        painter: ParticlePainter(
          colors: _colors,
          particles: _particles,
          rectangles: _rectangles,
          transforms: _transforms,
          image: widget.configs.texture!,
          deltaTime: widget.controller.deltaTime,
          deadParticleIndices: _deadParticleIndices,
          renderBlendMode: widget.configs.renderBlendMode,
          textureBlendMode: widget.configs.textureBlendMode,
          onFinished: () {},
        ),
      ),
    );
  }

  /// Was called on the mixin, that Ticker was still active. The Ticker must be disposed.
  @override
  void dispose() {
    widget.controller
        .getNotifier(NotifierType.time)
        .removeListener(_onControllerTick);
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
