import 'package:flutter/material.dart';
import 'package:particular/particular.dart';

/// A widget that represents a particle system.
class Particular extends StatefulWidget {
  /// The controller for the particle system.
  final ParticularController controller;

  /// Creates a [Particular] widget.
  const Particular({
    super.key,
    required this.controller,
  });

  /// Creates the state for the [Particular] widget.
  ///
  /// Returns a new instance of [_ParticularState].
  @override
  State<Particular> createState() => _ParticularState();
}

/// The state for the [Particular] widget.
class _ParticularState extends State<Particular> {
  /// This method can potentially be called in every frame and should not have
  /// any side effects beyond building a widget.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller.getNotifier(NotifierType.time),
      builder: (context, _) {
        return SizedBox(
          child: CustomPaint(
            painter: ParticlePainter(
              controller: widget.controller,
              deltaTime: widget.controller.deltaTime,
            ),
          ),
        );
      },
    );
  }
}

/// A custom painter for rendering particles.
class ParticlePainter extends CustomPainter {
  /// The time difference between frames.
  final int deltaTime;

  /// The paint object for rendering particles.
  final Paint _paint = Paint();

  final ParticularController controller;

  /// Creates a [ParticlePainter] with the specified parameters.
  ParticlePainter({
    required this.deltaTime,
    required this.controller,
  });

  /// Draws many parts of an image - the [atlas] - onto the canvas.
  @override
  void paint(Canvas canvas, Size size) {
    var allParticlesDead = true;
    for (var layer in controller.layers) {
      _paint.blendMode = layer.configs.textureBlendMode;
      for (var i = 0; i < layer.particles.length; i++) {
        var particle = layer.particles[i];
        layer.rectangles[i].update(layer.texture.width, layer.texture.height);
        particle.update(deltaTime);
        particle.transform.update(
          rotation: particle.rotation,
          translateX: particle.x,
          translateY: particle.y,
          anchorX: layer.texture.width * 0.5,
          anchorY: layer.texture.height * 0.5,
          scale: particle.size / layer.texture.width,
        );

        if (particle.isAlive && particle.isDyingTime()) {
          layer.deadParticleIndices.add(i);
          particle.isAlive = false;
          particle.color
              .update(0, particle.color.r, particle.color.g, particle.color.b);
        } else {
          allParticlesDead = false;
        }
      }
      canvas.drawAtlas(layer.texture, layer.transforms, layer.rectangles,
          layer.colors, layer.configs.renderBlendMode, null, _paint);

      if (allParticlesDead) {
        layer.onFinished?.call();
      }
    }
  }

  /// If the method returns false, then the [paint] call might be optimized
  /// away.
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
