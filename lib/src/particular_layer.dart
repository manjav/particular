import 'dart:ui' as ui;

import 'package:particular/particular.dart';

class ParticularLayer {
  /// The index of the particle system.
  int index = 0;


  /// The configs for managing parameters and behavior of a particle system.
  final ParticularConfigs configs;

  /// The texture used for particles.
  ui.Image texture;

  /// A callback function called when particle rendering is finished.
  final Function()? onFinished;

  /// Creates a new instance of the ParticularLayer class.
  ParticularLayer(
      {required this.texture, required this.configs, this.onFinished});

}
