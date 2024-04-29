import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../particular.dart';

class ParticularController extends ValueNotifier<List<ParticularConfigs>> {
  Ticker? _ticker;
  int selectedIndex = 0;
  ui.Image? _defaultTexture;
  int timelineDuration = 1000;
  /// Adds a particle system to the application.
  ///
  /// The [configs] parameter is an optional map of configurations for the particle system.
  Future<void> addParticleSystem({
    Map<dynamic, dynamic>? configs,
    ui.Image? texture,
  }) async {
    if (_defaultTexture == null) {
      /// Load default particle texture
      final bytes = await rootBundle.load("assets/texture.png");
      _defaultTexture = await loadUIImage(bytes.buffer.asUint8List());

      _ticker = Ticker(_onTick);
      _ticker!.start();
    }

    final particleConfigs = ParticularConfigs();
    particleConfigs.initialize(texture: _defaultTexture, configs: configs);

    if (configs == null || !configs.containsKey("configName")) {
      particleConfigs
          .updateFromMap({"configName": "Layer ${value.length + 1}"});
    }
    _add(particleConfigs);
  }

  void _onDurationChange() => notifyListeners();

  /// Adds a new particle system to the application.
  void _add(ParticularConfigs? particleConfigs) {
    particleConfigs ??= ParticularConfigs();
    particleConfigs.index = value.length;
    particleConfigs.getNotifier("duration").addListener(_onDurationChange);
    particleConfigs.getNotifier("startTime").addListener(_onDurationChange);
    selectedIndex = particleConfigs.index;
    value.add(particleConfigs);
    notifyListeners();
  }

  void selectAt(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void removeAt(int index) {
    value[index].getNotifier("duration").removeListener(_onDurationChange);
    value[index].getNotifier("startTime").removeListener(_onDurationChange);
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
    // value[index].isVisible = !value[index].isVisible;
    notifyListeners();
  }
}
