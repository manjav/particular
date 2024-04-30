import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../particular.dart';

enum NotifierType { time, layer }

/// The controller for the particle system.
class ParticularController {
  /// The map of notifiers
  final Map<NotifierType, ChangeNotifier> _notifiers = {};

  ChangeNotifier getNotifier(NotifierType key) =>
      _notifiers[key] ??= ChangeNotifier();

  /// Notifies listeners that the duration of the particle system has changed.
  void notify(NotifierType key) =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      getNotifier(key).notifyListeners();

  /// The ticker for the particle system.
  Ticker? _ticker;

  /// The index of the selected layer.
  int selectedLayerIndex = 0;

  /// The default texture for the particle system.
  ui.Image? _defaultTexture;

  /// The duration of the particle system in milliseconds.
  int timelineDuration = 1000;

  /// The delta time of the particle system in milliseconds.
  int deltaTime = 0;

  /// The elapsed time of the particle system in milliseconds.
  int elapsedTime = 0;

  final List<ParticularConfigs> layers = [];

  /// The ticker for the particle system.
  ParticularConfigs? get selectedLayer =>
      layers.isEmpty ? null : layers[selectedLayerIndex];

  /// Whether the particle system is empty.
  bool get isEmpty => layers.isEmpty;

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
    notify(NotifierType.time);
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
          .updateFromMap({"configName": "Layer ${layers.length + 1}"});
    }
    _add(particleConfigs);
  }

  /// Notifies listeners that the duration of the particle system has changed.
  void _onDurationChange() => notify(NotifierType.time);

  /// Adds a new particle system to the application.
  void _add(ParticularConfigs? particleConfigs) {
    particleConfigs ??= ParticularConfigs();
    particleConfigs.index = layers.length;
    particleConfigs.getNotifier("duration").addListener(_onDurationChange);
    particleConfigs.getNotifier("startTime").addListener(_onDurationChange);
    selectedLayerIndex = particleConfigs.index;
    layers.add(particleConfigs);
    notify(NotifierType.layer);
  }

  /// Selects the particle system at the given index.
  void selectAt(int index) {
    selectedLayerIndex = index;
    notify(NotifierType.layer);
  }

  /// Removes the particle system at the given index.
  void removeAt(int index) {
    layers[index].getNotifier("duration").removeListener(_onDurationChange);
    layers[index].getNotifier("startTime").removeListener(_onDurationChange);
    layers.removeAt(index);
    if (index >= layers.length) {
      selectedLayerIndex = layers.length - 1;
    }
    notify(NotifierType.layer);
  }

  /// Reorders the particle system's items based on the new index.
  void reOrder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = layers.removeAt(oldIndex);
    layers.insert(newIndex, item);
    notify(NotifierType.layer);
  }

  /// Toggles the visibility of the particle system.
  void toggleVisible(int index) {
    // _layers[index].isVisible = !_layers[index].isVisible;
    notify(NotifierType.layer);
  }
}
