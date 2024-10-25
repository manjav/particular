import 'dart:ui' as ui;

import 'package:editor/data/particular_editor_layer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:particular/particular.dart';

/// Extension methods for `ParticularConfigs` class
class ParticularEditorController extends ParticularController {
  /// The default texture bytes for the particle system.
  Uint8List? defaultTextureBytes;

  /// The default texture for the particle system.
  ui.Image? defaultTexture;

  /// The default texture for the particle system.
  Future<ui.Image> getDefaultTexture() async {
    if (defaultTexture == null) {
      ByteData bytes = await rootBundle.load("assets/texture.png");
      defaultTextureBytes = bytes.buffer.asUint8List();
      defaultTexture = await loadUIImage(defaultTextureBytes!);
    }
    return defaultTexture!;
  }

  /// Adds a new particle system to the application.
  @override
  Future<void> addConfigs({Map<String, dynamic>? configsData}) async {
    ByteData bytes;

    /// Load particle texture
    ui.Image? texture;
    try {
      if (configsData != null && configsData.containsKey("textureFileName")) {
        bytes =
            await rootBundle.load("assets/${configsData["textureFileName"]}");
        texture = await loadUIImage(bytes.buffer.asUint8List());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    final configs = ParticularConfigs()..initialize(configs: configsData);

    final layer = ParticularEditorLayer(
      texture: texture ?? await getDefaultTexture(),
      textureBytes: defaultTextureBytes,
      configs: configs,
    );

    if (configsData == null || !configsData.containsKey("configName")) {
      configs.updateWith({"configName": "Layer ${layers.length + 1}"});
    }
    addParticularLayer(layer);
  }
}
