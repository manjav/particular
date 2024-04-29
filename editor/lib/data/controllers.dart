import 'dart:ui' as ui;

import 'package:editor/data/particular_editor_controller.dart';
import 'package:editor/services/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ParticularControllers
    extends ValueNotifier<List<ParticularEditorController>> {
  ParticularControllers() : super([]);

  ui.Image? _defaultTexture;

  int selectedIndex = 0;
  ParticularEditorController? get selected =>
      value.isEmpty ? null : value[selectedIndex];

  bool get isEmpty => value.isEmpty;

  /// Adds a particle system to the application.
  ///
  /// The [configs] parameter is an optional map of configurations for the particle system.
  Future<void> addParticleSystem({Map<dynamic, dynamic>? configs}) async {
    if (_defaultTexture == null) {
      /// Load default particle texture
      final bytes = await rootBundle.load("assets/texture.png");
      _defaultTexture = await loadUIImage(bytes.buffer.asUint8List());
    }

    final controller = ParticularEditorController();
    controller.initialize(texture: _defaultTexture, configs: configs);

    add(controller);
  }

  void add(ParticularEditorController? controller) {
    controller ??= ParticularEditorController();
    controller.index = value.length;
    selectedIndex = controller.index;
    value.add(controller);
    notifyListeners();
  }

  void selectAt(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void removeAt(int index) {
    value.removeAt(index);
    if (index >= value.length) {
      selectedIndex = value.length - 1;
    }
    notifyListeners();
  }

  void reOrder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = value.removeAt(oldIndex);
    value.insert(newIndex, item);
    notifyListeners();
  }

  void toggleVisible(int index) {
    value[index].isVisible = !value[index].isVisible;
    notifyListeners();
  }
}
