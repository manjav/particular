import 'package:flutter/material.dart';
import 'package:particular/particular.dart';

class ParticularEditorController extends ParticularController {
  final Map<String, ChangeNotifier> _notifiers = {};
  ChangeNotifier getNotifier(String key) =>
      _notifiers[key] ??= ChangeNotifier();

  void updateFromMap(Map<String, dynamic> args) {
    update(
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
      angle: args["angle"],
      finishSize: args["finishSize"],
      finishSizeVariance: args["finishSizeVariance"],
      speed: args["speed"],
      speedVariance: args["speedVariance"],
      angleVariance: args["angleVariance"],
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
      radialAcceleration: args["radialAcceleration"],
      radialAccelerationVariance: args["radialAccelerationVariance"],
      tangentialAcceleration: args["tangentialAcceleration"],
      tangentialAccelerationVariance: args["tangentialAccelerationVariance"],
      texture: args["tangentialAccelerationVariance"],
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
      "radialAcceleration" => radialAcceleration,
      "radialAccelerationVariance" => radialAccelerationVariance,
      "tangentialAcceleration" => tangentialAcceleration,
      "tangentialAccelerationVariance" => tangentialAccelerationVariance,
      _ => texture,
    };
  }
}
