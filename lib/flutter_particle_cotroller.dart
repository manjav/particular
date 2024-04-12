import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_particle_system/flutter_particle.dart';

class FlutterParticleController extends ChangeNotifier {
  int duration = 0;
  int lifespan = 0;
  int lifespanVariance = 0;
  int maxParticles = 0;
  int blendFunctionSource = 0;
  int blendFunctionDestination = 0;
  ui.Image? image;
  ColorData? startColor;
  ColorData? startColorVariance;
  ColorData? finishColor;
  ColorData? finishColorVariance;
  num emitterX = 200;
  num emitterY = 200;
  num sourcePositionVarianceX = 0;
  num sourcePositionVarianceY = 0;
  num startSize = 0;
  num startSizeVariance = 0;
  num finishSize = 0;
  num finishSizeVariance = 0;
  num speed = 0;
  num speedVariance = 0;
  num gravityX = 0;
  num gravityY = 0;
  num angle = 0;
  num angleVariance = 0;
  num minRadius = 0;
  num minRadiusVariance = 0;
  num maxRadius = 0;
  num maxRadiusVariance = 0;
  num rotatePerSecond = 0;
  num rotatePerSecondVariance = 0;
  num radialAcceleration = 0;
  num radialAccelerationVariance = 0;
  num tangentialAcceleration = 0;
  num tangentialAccelerationVariance = 0;
  EmitterType emitterType = EmitterType.gravity;

  void initialize(Map configs, ui.Image image) async {
    update(
      startColor: ColorData(configs, "startColor"),
      startColorVariance: ColorData(configs, "startColorVariance"),
      finishColor: ColorData(configs, "finishColor"),
      finishColorVariance: ColorData(configs, "finishColorVariance"),
      emitterType: EmitterType.values[configs["emitterType"]],
      lifespan: (configs["particleLifespan"] * 1000).round(),
      lifespanVariance: (configs["particleLifespanVariance"] * 1000).round(),
      duration: (configs["duration"] * 1000).round(),
      maxParticles: configs["maxParticles"],
      blendFunctionSource: configs["blendFuncSource"],
      blendFunctionDestination: configs["blendFuncDestination"],
      sourcePositionVarianceX: configs["sourcePositionVariancex"],
      sourcePositionVarianceY: configs["sourcePositionVariancey"],
      startSize: configs["startParticleSize"],
      startSizeVariance: configs["startParticleSizeVariance"],
      finishSize: configs["finishParticleSize"],
      finishSizeVariance: configs["finishParticleSizeVariance"],
      speed: configs["speed"],
      speedVariance: configs["speedVariance"],
      gravityX: configs["gravityx"],
      gravityY: configs["gravityy"],
      angle: configs["angle"],
      angleVariance: configs["angleVariance"],
      minRadius: configs["minRadius"],
      minRadiusVariance: configs["minRadiusVariance"],
      maxRadius: configs["maxRadius"],
      maxRadiusVariance: configs["maxRadiusVariance"],
      rotatePerSecond: configs["rotatePerSecond"],
      rotatePerSecondVariance: configs["rotatePerSecondVariance"],
      radialAcceleration: configs["radialAcceleration"],
      radialAccelerationVariance: configs["radialAccelVariance"],
      tangentialAcceleration: configs["tangentialAcceleration"],
      tangentialAccelerationVariance: configs["tangentialAccelVariance"],
      image: image,
    );
  }

  void update({
    EmitterType? emitterType,
    int? duration,
    int? lifespan,
    int? lifespanVariance,
    int? maxParticles,
    int? blendFunctionSource,
    int? blendFunctionDestination,
    ColorData? startColor,
    ColorData? startColorVariance,
    ColorData? finishColor,
    ColorData? finishColorVariance,
    num? sourcePositionVarianceX,
    num? sourcePositionVarianceY,
    num? startSize,
    num? startSizeVariance,
    num? angle,
    num? finishSize,
    num? finishSizeVariance,
    num? speed,
    num? speedVariance,
    num? angleVariance,
    num? emitterX,
    num? emitterY,
    num? gravityX,
    num? gravityY,
    num? minRadius,
    num? minRadiusVariance,
    num? maxRadius,
    num? maxRadiusVariance,
    num? rotatePerSecond,
    num? rotatePerSecondVariance,
    num? radialAcceleration,
    num? radialAccelerationVariance,
    num? tangentialAcceleration,
    num? tangentialAccelerationVariance,
    ui.Image? image,
  }) {
    if (emitterType != null) {
      this.emitterType = emitterType;
    }
    if (lifespan != null) {
      this.lifespan = lifespan;
    }
    if (lifespanVariance != null) {
      this.lifespanVariance = lifespanVariance;
    }
    if (duration != null) {
      this.duration = duration;
    }
    if (maxParticles != null) {
      this.maxParticles = maxParticles;
    }
    if (blendFunctionSource != null) {
      this.blendFunctionSource = blendFunctionSource;
    }
    if (blendFunctionDestination != null) {
      this.blendFunctionDestination = blendFunctionDestination;
    }
    if (startColor != null) {
      this.startColor = startColor;
    }
    if (startColorVariance != null) {
      this.startColorVariance = startColorVariance;
    }
    if (finishColor != null) {
      this.finishColor = finishColor;
    }
    if (finishColorVariance != null) {
      this.finishColorVariance = finishColorVariance;
    }
    if (sourcePositionVarianceX != null) {
      this.sourcePositionVarianceX = sourcePositionVarianceX;
    }
    if (sourcePositionVarianceY != null) {
      this.sourcePositionVarianceY = sourcePositionVarianceY;
    }
    if (startSize != null) {
      this.startSize = startSize;
    }
    if (startSizeVariance != null) {
      this.startSizeVariance = startSizeVariance;
    }
    if (finishSize != null) {
      this.finishSize = finishSize;
    }
    if (finishSizeVariance != null) {
      this.finishSizeVariance = finishSizeVariance;
    }
    if (speed != null) {
      this.speed = speed;
    }
    if (speedVariance != null) {
      this.speedVariance = speedVariance;
    }
    if (angle != null) {
      this.angle = angle;
    }
    if (angleVariance != null) {
      this.angleVariance = angleVariance;
    }
    if (emitterX != null) {
      this.emitterX = emitterX;
    }
    if (emitterY != null) {
      this.emitterY = emitterY;
    }
    if (gravityX != null) {
      this.gravityX = gravityX;
    }
    if (gravityY != null) {
      this.gravityY = gravityY;
    }
    if (minRadius != null) {
      this.minRadius = minRadius;
    }
    if (minRadiusVariance != null) {
      this.minRadiusVariance = minRadiusVariance;
    }
    if (maxRadius != null) {
      this.maxRadius = maxRadius;
    }
    if (maxRadiusVariance != null) {
      this.maxRadiusVariance = maxRadiusVariance;
    }
    if (rotatePerSecond != null) {
      this.rotatePerSecond = rotatePerSecond;
    }
    if (rotatePerSecondVariance != null) {
      this.rotatePerSecondVariance = rotatePerSecondVariance;
    }
    if (radialAcceleration != null) {
      this.radialAcceleration = radialAcceleration;
    }
    if (radialAccelerationVariance != null) {
      this.radialAccelerationVariance = radialAccelerationVariance;
    }
    if (tangentialAcceleration != null) {
      this.tangentialAcceleration = tangentialAcceleration;
    }
    if (tangentialAccelerationVariance != null) {
      this.tangentialAccelerationVariance = tangentialAccelerationVariance;
    }
    if (image != null) {
      this.image = image;
    }
    notifyListeners();
  }
}

class ColorData {
  late num a, r, g, b;
  ColorData(Map map, String name) {
    a = map["${name}Alpha"];
    r = map["${name}Red"];
    g = map["${name}Green"];
    b = map["${name}Blue"];
  }
}
