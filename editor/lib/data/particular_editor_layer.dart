import 'dart:typed_data';

import 'package:particular/particular.dart';

/// The layer for the particle system.
/// It contains the texture and the configs for the layer.
class ParticularEditorLayer extends ParticularLayer {
  /// The bytes of the texture used for particles.
  Uint8List? textureBytes;

  /// Initializes a new instance of the `ParticularEditorLayer` class.
  ParticularEditorLayer({required super.texture, required super.configs});
}
