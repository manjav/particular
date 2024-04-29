import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../particular.dart';

class ParticularController extends ValueNotifier<List<ParticularConfigs>> {
  /// The ticker for the particle system.
  Ticker? _ticker;

  /// The ticker for the particle system.
  int selectedIndex = 0;

  /// The ticker for the particle system.
  ui.Image? _defaultTexture;

  /// The ticker for the particle system.
  int timelineDuration = 1000;

  /// The delta time of the particle system in milliseconds.
  int deltaTime = 0;

  /// The elapsed time of the particle system in milliseconds.
  int elapsedTime = 0;

  /// The ticker for the particle system.
  ParticularController() : super([]);

  /// The ticker for the particle system.
  ParticularConfigs? get selected =>
      value.isEmpty ? null : value[selectedIndex];

  /// Whether the particle system is empty.
  bool get isEmpty => value.isEmpty;

  /// Updates the particle system's delta time and elapsed time based on the given [elapsed] duration.
  ///
  /// This function is called periodically to update the particle system's state. It calculates the
  /// delta time and current elapsed time.
  ///
  /// Parameters:
  ///   - elapsed: The duration since the last update.
  void _onTick(Duration elapsed) {
    deltaTime = elapsed.inMilliseconds - elapsedTime;
    elapsedTime = elapsed.inMilliseconds;
    notifyListeners();
  }

  /// Resets the tick of the particle system.
  void resetTick() {
    _ticker?.stop();
    elapsedTime = 0;
    _ticker?.start();
  }

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
