import 'package:flutter/material.dart';
import 'package:particular/particular.dart';

class ParticularEditorController extends ParticularController {
  int index = 0;
  bool isVisible = true;
  final Map<String, ChangeNotifier> _notifiers = {};

  ChangeNotifier getNotifier(String key) =>
      _notifiers[key] ??= ChangeNotifier();

  void updateFromMap(Map<String, dynamic> args) {
    update(
      configName: args["configName"],
      emitterType: args["emitterType"],
      renderBlendMode: args["renderBlendMode"],
      textureBlendMode: args["textureBlendMode"],
      blendFunctionSource: args["blendFunctionSource"],
      blendFunctionDestination: args["blendFunctionDestination"],
      duration: args["duration"],
      lifespan: args["lifespan"],
      lifespanVariance: args["lifespanVariance"],
      maxParticles: args["maxParticles"],
      startColor: args["startColor"],
      startColorVariance: args["startColorVariance"],
      finishColor: args["finishColor"],
      finishColorVariance: args["finishColorVariance"],
      sourcePositionVarianceX: args["sourcePositionVarianceX"],
      sourcePositionVarianceY: args["sourcePositionVarianceY"],
      startSize: args["startSize"],
      startSizeVariance: args["startSizeVariance"],
      angle: _loopClamp(args["angle"], -180, 180),
      angleVariance: _clamp(args["angleVariance"], 0, 360),
      finishSize: args["finishSize"],
      finishSizeVariance: args["finishSizeVariance"],
      speed: args["speed"],
      speedVariance: args["speedVariance"],
      emitterX: args["emitterX"],
      emitterY: args["emitterY"],
      gravityX: args["gravityX"],
      gravityY: args["gravityY"],
      minRadius: args["minRadius"],
      minRadiusVariance: args["minRadiusVariance"],
      maxRadius: args["maxRadius"],
      maxRadiusVariance: args["maxRadiusVariance"],
      rotatePerSecond: args["rotatePerSecond"],
      rotatePerSecondVariance: args["rotatePerSecondVariance"],
      startRotation: args["startRotation"],
      startRotationVariance: args["startRotationVariance"],
      finishRotation: args["finishRotation"],
      finishRotationVariance: args["finishRotationVariance"],
      radialAcceleration: args["radialAcceleration"],
      radialAccelerationVariance: args["radialAccelerationVariance"],
      tangentialAcceleration: args["tangentialAcceleration"],
      tangentialAccelerationVariance: args["tangentialAccelerationVariance"],
      texture: args["texture"],
    );
    for (var key in args.keys) {
      getNotifier(key).notifyListeners();
    }
  }

  dynamic getParam(String key) {
    return switch (key) {
      "emitterType" => emitterType,
      "renderBlendMode" => renderBlendMode,
      "textureBlendMode" => textureBlendMode,
      "blendFunctionSource" => blendFunctionSource,
      "blendFunctionDestination" => blendFunctionDestination,
      "duration" => duration,
      "lifespan" => lifespan,
      "lifespanVariance" => lifespanVariance,
      "maxParticles" => maxParticles,
      "startColor" => startColor,
      "startColorVariance" => startColorVariance,
      "finishColor" => finishColor,
      "finishColorVariance" => finishColorVariance,
      "sourcePositionVarianceX" => sourcePositionVarianceX,
      "sourcePositionVarianceY" => sourcePositionVarianceY,
      "startSize" => startSize,
      "startSizeVariance" => startSizeVariance,
      "angle" => angle,
      "finishSize" => finishSize,
      "finishSizeVariance" => finishSizeVariance,
      "speed" => speed,
      "speedVariance" => speedVariance,
      "angleVariance" => angleVariance,
      "emitterX" => emitterX,
      "emitterY" => emitterY,
      "gravityX" => gravityX,
      "gravityY" => gravityY,
      "minRadius" => minRadius,
      "minRadiusVariance" => minRadiusVariance,
      "maxRadius" => maxRadius,
      "maxRadiusVariance" => maxRadiusVariance,
      "rotatePerSecond" => rotatePerSecond,
      "rotatePerSecondVariance" => rotatePerSecondVariance,
      "startRotation" => startRotation,
      "startRotationVariance" => startRotationVariance,
      "finishRotation" => finishRotation,
      "finishRotationVariance" => finishRotationVariance,
      "radialAcceleration" => radialAcceleration,
      "radialAccelerationVariance" => radialAccelerationVariance,
      "tangentialAcceleration" => tangentialAcceleration,
      "tangentialAccelerationVariance" => tangentialAccelerationVariance,
      _ => texture,
    };
  }

  num? _loopClamp(num? value, int min, int max) {
    if (value == null) return null;
    var diff = max - min;
    // var half = (diff * 0.5).round();
    while (value! < min) {
      value += diff;
    }
    while (value! > max) {
      value -= diff;
    }
    return value;
  }

  num? _clamp(num? value, int min, int max) {
    if (value == null) return null;
    return value.clamp(min, max);
  }
}
