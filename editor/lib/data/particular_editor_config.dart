import 'package:particular/particular.dart';

/// Extension methods for `ParticularConfigs` class
extension ParticularEditorConfig on ParticularConfigs {
  /// Gets the value of the given parameter.
  dynamic getParam(String key) {
    return switch (key) {
      "configName" => configName,
      "textureFileName" => textureFileName,
      "emitterType" => emitterType,
      "renderBlendMode" => renderBlendMode,
      "textureBlendMode" => textureBlendMode,
      "blendFunctionSource" => blendFunctionSource,
      "blendFunctionDestination" => blendFunctionDestination,
      "startTime" => startTime,
      "endTime" => endTime,
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
      _ => null,
    };
  }

  /// Convert to Map for export
  Map toMap() {
    final startColorMap = startColor.toMap("startColor");
    final startColorVarianceMap =
        startColorVariance.toMap("startColorVariance");
    final finishColorMap = finishColor.toMap("finishColor");
    final finishColorVarianceMap =
        finishColorVariance.toMap("finishColorVariance");
    return {
      "configName": configName,
      "textureFileName": textureFileName,
      "emitterType": emitterType.index,
      "renderBlendMode": renderBlendMode.index,
      "textureBlendMode": textureBlendMode.index,
      "particleLifespan": (lifespan * 0.001),
      "particleLifespanVariance": lifespanVariance * 0.001,
      "startTime": startTime * 0.001,
      "duration": endTime * (endTime > -1 ? 0.001 : 1),
      "maxParticles": maxParticles,
      "sourcePositionVariancex": sourcePositionVarianceX,
      "sourcePositionVariancey": sourcePositionVarianceY,
      "startParticleSize": startSize,
      "startParticleSizeVariance": startSizeVariance,
      "finishParticleSize": finishSize,
      "finishParticleSizeVariance": finishSizeVariance,
      "speed": speed,
      "speedVariance": speedVariance,
      "emitterX": emitterX,
      "emitterY": emitterY,
      "gravityx": gravityX,
      "gravityy": gravityY,
      "minRadius": minRadius,
      "minRadiusVariance": minRadiusVariance,
      "maxRadius": maxRadius,
      "maxRadiusVariance": maxRadiusVariance,
      "angle": angle,
      "angleVariance": angleVariance,
      "rotatePerSecond": rotatePerSecond,
      "rotatePerSecondVariance": rotatePerSecondVariance,
      "rotationStart": startRotation,
      "rotationStartVariance": startRotationVariance,
      "rotationEnd": finishRotation,
      "rotationEndVariance": finishRotationVariance,
      "radialAcceleration": radialAcceleration,
      "radialAccelVariance": radialAccelerationVariance,
      "tangentialAcceleration": tangentialAcceleration,
      "tangentialAccelVariance": tangentialAccelerationVariance,
    }
      ..addAll(startColorMap)
      ..addAll(startColorVarianceMap)
      ..addAll(finishColorMap)
      ..addAll(finishColorVarianceMap);
  }
}

/// Extension methods for `ARGB` class
extension ARGBExtension on ARGB {
  /// Convert to Map for export
  Map toMap(String name) {
    return {
      "${name}Alpha": a,
      "${name}Red": r,
      "${name}Green": g,
      "${name}Blue": b
    };
  }
}
