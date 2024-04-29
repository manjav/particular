import 'package:particular/particular.dart';

extension ParticularEditorController on ParticularConfigs {
  // bool isVisible = true;

  dynamic getParam(String key) {
    return switch (key) {
      "configName" => configName,
      "emitterType" => emitterType,
      "renderBlendMode" => renderBlendMode,
      "textureBlendMode" => textureBlendMode,
      "blendFunctionSource" => blendFunctionSource,
      "blendFunctionDestination" => blendFunctionDestination,
      "startTime" => startTime,
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

  Map getConfigs() {
    final startColorMap = startColor.toMap("startColor");
    final startColorVarianceMap =
        startColorVariance.toMap("startColorVariance");
    final finishColorMap = finishColor.toMap("finishColor");
    final finishColorVarianceMap =
        finishColorVariance.toMap("finishColorVariance");
    return {
      "configName": configName,
      "emitterType": emitterType.index,
      "renderBlendMode": renderBlendMode.index,
      "textureBlendMode": textureBlendMode.index,
      "particleLifespan": (lifespan * 0.001),
      "particleLifespanVariance": lifespanVariance * 0.001,
      "duration": duration * (duration > -1 ? 0.001 : 1),
      "startTime": startTime * 0.001,
      "maxParticles": maxParticles,
      "sourcePositionVariancex": sourcePositionVarianceX,
      "sourcePositionVariancey": sourcePositionVarianceY,
      "startParticleSize": startSize,
      "startParticleSizeVariance": startSizeVariance,
      "finishParticleSize": finishSize,
      "finishParticleSizeVariance": finishSizeVariance,
      "speed": speed,
      "speedVariance": speedVariance,
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
