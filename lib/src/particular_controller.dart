import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:particular/particular.dart';

/// The type of notifiers
enum NotifierType { time, layer }

/// The controller for the particle system.
class ParticularController {
  /// The list of layers in the particle system.
  final List<ParticularLayer> _layers = [];

  /// Get layers
  List<ParticularLayer> get layers => _layers;

  /// The index of the selected layer.
  int selectedLayerIndex = 0;

  /// The ticker for the particle system.
  ParticularLayer? get selectedLayer =>
      _layers.isEmpty ? null : _layers[selectedLayerIndex];

  /// Whether the particle system is empty.
  bool get isEmpty => _layers.isEmpty;

  /// The map of notifiers
  final Map<NotifierType, ChangeNotifier> _notifiers = {};

  /// Get notifier
  ChangeNotifier getNotifier(NotifierType key) =>
      _notifiers[key] ??= ChangeNotifier();

  /// Notifies listeners that the duration of the particle system has changed.
  void notify(NotifierType key) =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      getNotifier(key).notifyListeners();

  /// The delta time of the particle system in milliseconds.
  int deltaTime = 0;

  /// The elapsed time of the particle system in milliseconds.
  int elapsedTime = 0;

  /// The duration of the particle system in milliseconds.
  int get timelineDuration {
    if (_layers.isEmpty) return ParticularConfigs.defaultDuration;
    var max = _layers
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

  bool _isLooping = false;

  bool get isLooping => _isLooping;

  bool get _hasInfiniteLayer =>
      _layers.any((layer) => layer.configs.endTime < 0);

  // Finds the farthest end time of the layers
  int get farthestEndTime {
    int lastEndAt = 0;
    for (var layer in _layers) {
      if (layer.configs.endTime > lastEndAt) {
        lastEndAt = layer.configs.endTime;
      }
    }
    return lastEndAt;
  }

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
    for (var layer in _layers) {
      var configs = layer.configs;
      var duration =
          configs.endTime > 0 ? configs.endTime - configs.startTime : 1000;
      if (elapsedTime >= configs.startTime &&
          (configs.endTime < 0 || elapsedTime < configs.endTime)) {
        _particlesPerTick += (deltaTime * configs.maxParticles / duration);
        var floor = _particlesPerTick.floor();
        for (var i = 0; i < floor; i++) {
          layer.spawn(age: (i * deltaTime / _particlesPerTick).round());
        }
        _particlesPerTick -= floor;
      }
    }

    // Let's loop
    _tryToLoop();

    notify(NotifierType.time);
  }

  /// Here we try to loop the particle system
  void _tryToLoop() {
    if (!_isLooping) {
      return;
    }

    int loopAt = timelineDuration;

    if (!_hasInfiniteLayer && elapsedTime > farthestEndTime) {
      loopAt = min(
        farthestEndTime + ParticularConfigs.endLoopPadding,
        timelineDuration,
      );
    }
    if (elapsedTime > loopAt) {
      resetTick();
    }
  }

  /// Notifies listeners that the duration of the particle system has changed.
  void _onDurationChange() => notify(NotifierType.time);

  /// Resets the tick of the particle system.
  void resetTick() {
    _ticker?.stop();
    elapsedTime = 0;
    _ticker?.start();
  }

  /// Adds a new particle system to the application.
  @Deprecated('Use [addConfigLayer]')
  Future<void> addLayer({
    dynamic configsData,
  }) async {
    await addConfigLayer(configsData: configsData);
  }

  /// Adds one or more particle systems to the application.
  ///
  /// The [configs] parameter can be either a single configuration map or a
  /// list of configuration maps. If [configs] is a list, each configuration
  /// map in the list will be added as a separate particle system.
  Future<void> addConfigLayer({
    dynamic configsData,
  }) async {
    // If the configs parameter is a list, iterate over each configuration
    // map and add it as a separate particle system.
    if (configsData is List) {
      for (var i = 0; i < configsData.length; i++) {
        await addConfigs(configsData: configsData[i]);
      }
    } else {
      await addConfigs(configsData: configsData);
    }
  }

  /// Adds a new particle system to the application.
  @protected
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
    final configs = ParticularConfigs.initialize(configs: configsData);
    final layer = ParticularLayer(texture: texture!, configs: configs);
    addParticularLayer(layer);
  }

  /// Adds a new particle system to the application.
  ///
  /// The [configs] parameter can be either a single configuration map or a
  /// list of configuration maps. If [configs] is a list, each configuration
  /// map in the list will be added as a separate particle system.
  void addParticularLayer(ParticularLayer layer) {
    layer.configs.getNotifier("duration").addListener(_onDurationChange);
    layer.configs.getNotifier("startTime").addListener(_onDurationChange);
    layer.index = _layers.length;
    selectedLayerIndex = layer.index;

    if (_ticker == null) {
      _ticker = Ticker(_onTick);
      _ticker!.start();
    }

    _layers.add(layer);
    notify(NotifierType.layer);
  }

  /// Selects the particle system at the given index.
  void selectLayerAt(int index) {
    selectedLayerIndex = index;
    notify(NotifierType.layer);
  }

  /// Removes the particle system at the given index.
  void removeLayerAt(int index) {
    _layers[index]
        .configs
        .getNotifier("duration")
        .removeListener(_onDurationChange);
    _layers[index]
        .configs
        .getNotifier("startTime")
        .removeListener(_onDurationChange);
    _layers.removeAt(index);
    if (selectedLayerIndex >= _layers.length) {
      selectedLayerIndex = _layers.length - 1;
    }
    notify(NotifierType.layer);
  }

  /// Reorders the particle system's items based on the new index.
  void reOrderLayer(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _layers.removeAt(oldIndex);
    _layers.insert(newIndex, item);
    selectedLayerIndex = newIndex;
    notify(NotifierType.layer);
  }

  /// Toggles the visibility of the particle system.
  void toggleVisibleLayer(int index) {
    // _layers[index].isVisible = !_layers[index].isVisible;
    notify(NotifierType.layer);
  }

  /// Toggles the looping state of the particle system.
  void setIsLooping(bool isLooping) {
    _isLooping = isLooping;
    notify(NotifierType.layer);
  }

  /// Disposes the controllers, notifiers and stops the ticker.
  /// If you are  using frequently of layers or particulars,
  /// Its a good practice to dispose unused of them
  void dispose() {
    _ticker?.stop();

    for (var layer in _layers) {
      layer.configs.dispose();
      layer.texture.dispose();
    }

    for (var notifier in _notifiers.values) {
      notifier.dispose();
    }
    _notifiers.clear();
  }
}
