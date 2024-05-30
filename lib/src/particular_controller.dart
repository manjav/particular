import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:particular/particular.dart';

/// The type of notifiers
enum NotifierType { time, layer }

/// The controller for the particle system.
class ParticularController {
  /// The map of notifiers
  final Map<NotifierType, ChangeNotifier> _notifiers = {};

  /// Get notifier
  ChangeNotifier getNotifier(NotifierType key) =>
      _notifiers[key] ??= ChangeNotifier();

  /// Notifies listeners that the duration of the particle system has changed.
  void notify(NotifierType key) =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      getNotifier(key).notifyListeners();

  /// The list of layers in the particle system.
  final List<ParticularLayer> layers = [];

  /// The index of the selected layer.
  int selectedLayerIndex = 0;

  /// The ticker for the particle system.
  ParticularLayer? get selectedLayer =>
      layers.isEmpty ? null : layers[selectedLayerIndex];

  /// Whether the particle system is empty.
  bool get isEmpty => layers.isEmpty;

  /// The default texture for the particle system.
  ui.Image? _defaultTexture;

  /// The default texture for the particle system.
  Future<ui.Image> _getDefaultTexture() async {
    if (_defaultTexture == null) {
      ByteData bytes = await rootBundle.load("assets/texture.png");
      _defaultTexture = await loadUIImage(bytes.buffer.asUint8List());
    }
    return _defaultTexture!;
  }

  /// The delta time of the particle system in milliseconds.
  int deltaTime = 0;

  /// The elapsed time of the particle system in milliseconds.
  int elapsedTime = 0;

  /// The duration of the particle system in milliseconds.
  int get timelineDuration {
    if (layers.isEmpty) return ParticularConfigs.defaultDuration;
    var max = layers
        .reduce((l, r) => l.configs.endTime > r.configs.endTime ? l : r)
        .configs
        .endTime;
    if (max < ParticularConfigs.defaultDuration) {
      return ParticularConfigs.defaultDuration;
    }
    return max + 100;
  }

  double _particlesPerTick = 0;

  /// The ticker for the particle system.
  Ticker? _ticker;

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

    // Spawn particles
    for (var layer in layers) {
      var configs = layer.configs;
      if (elapsedTime >= configs.startTime &&
          (configs.endTime < 0 || elapsedTime < configs.endTime)) {
        _particlesPerTick += (deltaTime * configs.maxParticles / 1000);
        for (var i = 0; i < _particlesPerTick; i++) {
          layer.spawn(age: (i * deltaTime / _particlesPerTick).round());
        }
        _particlesPerTick -= _particlesPerTick.floor();
      }
    }

    notify(NotifierType.time);
  }

  /// Notifies listeners that the duration of the particle system has changed.
  void _onDurationChange() => notify(NotifierType.time);

  /// Resets the tick of the particle system.
  void resetTick() {
    _ticker?.stop();
    elapsedTime = 0;
    _ticker?.start();
  }

  /// Adds one or more particle systems to the application.
  ///
  /// The [configs] parameter can be either a single configuration map or a
  /// list of configuration maps. If [configs] is a list, each configuration
  /// map in the list will be added as a separate particle system.
  Future<void> addLayer({
    dynamic configsData,
  }) async {
    // If the configs parameter is a list, iterate over each configuration
    // map and add it as a separate particle system.
    if (configsData is List) {
      for (var i = 0; i < configsData.length; i++) {
        await _add(configsData: configsData[i]);
      }
    } else {
      await _add(configsData: configsData);
    }
  }

  /// Adds a new particle system to the application.
  Future<void> _add({Map<String, dynamic>? configsData}) async {
    ByteData bytes;

    if (_ticker == null) {
      _ticker = Ticker(_onTick);
      _ticker!.start();
    }

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

    final layer = ParticularLayer(
        texture: texture ?? await _getDefaultTexture(), configs: configs);
    configs.getNotifier("duration").addListener(_onDurationChange);
    configs.getNotifier("startTime").addListener(_onDurationChange);
    layer.index = layers.length;
    selectedLayerIndex = layer.index;

    if (configsData == null || !configsData.containsKey("configName")) {
      configs.updateFromMap({"configName": "Layer ${layers.length + 1}"});
    }

    layers.add(layer);
    notify(NotifierType.layer);
  }

  /// Selects the particle system at the given index.
  void selectLayerAt(int index) {
    selectedLayerIndex = index;
    notify(NotifierType.layer);
  }

  /// Removes the particle system at the given index.
  void removeLayerAt(int index) {
    layers[index]
        .configs
        .getNotifier("duration")
        .removeListener(_onDurationChange);
    layers[index]
        .configs
        .getNotifier("startTime")
        .removeListener(_onDurationChange);
    layers.removeAt(index);
    if (selectedLayerIndex >= layers.length) {
      selectedLayerIndex = layers.length - 1;
    }
    notify(NotifierType.layer);
  }

  /// Reorders the particle system's items based on the new index.
  void reOrderLayer(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = layers.removeAt(oldIndex);
    layers.insert(newIndex, item);
    selectedLayerIndex = newIndex;
    notify(NotifierType.layer);
  }

  /// Toggles the visibility of the particle system.
  void toggleVisibleLayer(int index) {
    // _layers[index].isVisible = !_layers[index].isVisible;
    notify(NotifierType.layer);
  }
}
