import 'dart:ui' as ui;

import 'package:particular/particular.dart';

class ParticularLayer {
  /// The index of the particle system.
  int index = 0;

  /// The rectangles representing particles.
  final List<ParticleRect> rectangles = [];

  /// The particles in the system.
  final List<Particle> particles = [];

  /// The colors of particles.
  final List<ParticleColor> colors = [];

  /// The indices of the dead particles.
  final List<int> deadParticleIndices = [];

  /// The transforms of particles.
  final List<ParticleTransform> transforms = [];

  /// The configs for managing parameters and behavior of a particle system.
  final ParticularConfigs configs;

  /// The texture used for particles.
  ui.Image texture;

  /// A callback function called when particle rendering is finished.
  final Function()? onFinished;

  /// Creates a new instance of the ParticularLayer class.
  ParticularLayer(
      {required this.texture, required this.configs, this.onFinished});

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
  void spawn({int age = 0, double scaleFactor = 1.0}) {
    Particle particle;
    if (deadParticleIndices.isEmpty) {
      particle = Particle();
      colors.add(particle.color);
      transforms.add(particle.transform);
      rectangles.add(ParticleRect.fromLTWH(
          0, 0, texture.width.toDouble(), texture.height.toDouble()));
      particles.add(particle);
    } else {
      particle = particles[deadParticleIndices.removeLast()];
    }
    final position = configs.getEmitterPosition(1);
    particle.initialize(
      age: age,
      emitterType: configs.emitterType,
      emitterX: position.x,
      emitterY: position.y,
      startSize: configs.getStartSize(1),
      finishSize: configs.getFinishSize(1),
      startColor: configs.getStartColor(),
      finishColor: configs.getFinishColor(),
      angle: configs.getAngle(),
      lifespan: configs.getLifespan(),
      speed: configs.getSpeed(scaleFactor),
      gravityX: configs.gravityX * scaleFactor,
      gravityY: configs.gravityY * scaleFactor,
      minRadius: configs.getMinRadius(1),
      maxRadius: configs.getMaxRadius(1),
      rotatePerSecond: configs.getRotatePerSecond(),
      startRotation: configs.getStartRotaion(),
      finishRotation: configs.getFinishRotaion(),
      radialAcceleration: configs.getRadialAcceleration(),
      tangentialAcceleration: configs.getTangentialAcceleration(),
    );
  }
}
