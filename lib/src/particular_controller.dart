import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:particular/particular.dart';

/// A controller for managing parameters and behavior of a particle system.
class ParticularController extends ChangeNotifier {
  /// Gets the start color of particles.
  Color getStartColor() => _getColor(startColor, startColorVariance);

  /// Gets the finish color of particles.
  Color getFinishColor() => _getColor(finishColor, finishColorVariance);

  /// Gets the lifespan of particles.
  int getLifespan() => _getValue(lifespan, lifespanVariance).round();

  /// Gets the x-coordinate of the emitter position.
  double getEmitterX(double d) =>
      _getDouble(emitterX, sourcePositionVarianceX * d);

  /// Gets the y-coordinate of the emitter position.
  double getEmitterY(double d) =>
      _getDouble(emitterY, sourcePositionVarianceY * d);

  /// Gets the start size of particles.
  double getStartSize(double d) => _getDouble(startSize, startSizeVariance, d);

  /// Gets the finish size of particles.
  double getFinishSize(double d) =>
      _getDouble(finishSize, finishSizeVariance, d);

  /// Gets the speed of particles.
  double getSpeed(double d) => _getDouble(speed, speedVariance, d);

  /// Gets the emission angle of particles.
  double getAngle() => _getDouble(angle, angleVariance);

  /// Gets the minimum radius of particles.
  double getMinRadius(double d) => _getDouble(minRadius, minRadiusVariance, d);

  /// Gets the maximum radius of particles.
  double getMaxRadius(double d) => _getDouble(maxRadius, maxRadiusVariance, d);

  /// Gets the rotation rate of particles per second.
  double getRotatePerSecond() =>
      _getDouble(rotatePerSecond, rotatePerSecondVariance);

  /// Gets the radial acceleration of particles.
  double getRadialAcceleration() =>
      _getDouble(radialAcceleration, radialAccelerationVariance);

  /// Gets the tangential acceleration of particles.
  double getTangentialAcceleration() =>
      _getDouble(tangentialAcceleration, tangentialAccelerationVariance);

  /// Gets the value with variance.
  num _getValue(num base, num variance, [num coef = 1]) {
    if (variance == 0) {
      return (base * coef);
    }
    return (base + variance * (math.Random().nextDouble() * 2.0 - 1.0)) * coef;
  }

  /// Gets the double value with variance.
  double _getDouble(num base, num variance, [num coef = 1]) =>
      _getValue(base, variance, coef).toDouble();

  /// Gets the color with variance.
  Color _getColor(ARGB base, ARGB variance) {
    var alpha = _getValue(base.a, variance.a, 255).clamp(0, 255).round();
    var red = _getValue(base.r, variance.r, 255).clamp(0, 255).round();
    var green = _getValue(base.g, variance.g, 255).clamp(0, 255).round();
    var blue = _getValue(base.b, variance.b, 255).clamp(0, 255).round();
    return Color.fromARGB(alpha, red, green, blue);
  }

  /// Gets the blend mode for particle rendering.
  BlendMode getBlendMode() {
    int s = blendFunctionSource;
    int d = blendFunctionDestination;
    if (d == 0) return BlendMode.clear;
    if (s == 0) {
      return switch (d) {
        0x301 => BlendMode.screen, //erase
        0x302 => BlendMode.srcIn, //mask
        _ => BlendMode.srcOver,
      };
    }
    if (s == 1) {
      return switch (d) {
        1 => BlendMode.plus,
        0x301 => BlendMode.screen,
        _ => BlendMode.srcOver,
      };
    }
    if (s == 0x306 && d == 0x303) {
      return ui.BlendMode.multiply;
    }
    if (s == 0x305 && d == 0x304) {
      return BlendMode.dst;
    }
    // 0=>      BlendMode.zero,
    // 1=>      BlendMode.color,
    // 0x300=>  BlendMode.SOURCE_COLOR,
    // 0x301=>  BlendMode.ONE_MINUS_SOURCE_COLOR,
    // 0x302=>  BlendMode.SOURCE_ALPHA,
    // 0x303=>  BlendMode.ONE_MINUS_SOURCE_ALPHA,
    // 0x304=>  BlendMode.DESTINATION_ALPHA,
    // 0x305=>  BlendMode.ONE_MINUS_DESTINATION_ALPHA,
    // 0x306=>  BlendMode.DESTINATION_COLOR,
    // 0x307=>  BlendMode.ONE_MINUS_DESTINATION_COLOR,

    // "none":,ONE, ZERO
    // "normal": ONE, ONE_MINUS_SOURCE_ALPHA
    // "add": ONE, ONE
    // "screen": ONE, ONE_MINUS_SOURCE_COLOR
    // "erase": ZERO, ONE_MINUS_SOURCE_ALPHA
    // "mask": ZERO, SOURCE_ALPHA
    // "multiply": DESTINATION_COLOR, ONE_MINUS_SOURCE_ALPHA
    // "below": ONE_MINUS_DESTINATION_ALPHA, DESTINATION_ALPHA
    return BlendMode.srcOver;
  }

  /// The duration of the particle system.
  int duration = -1;

  /// The lifespan of particles.
  int lifespan = 1000;

  /// The lifespan variance of particles.
  int lifespanVariance = 0;

  /// The maximum number of particles.
  int maxParticles = 100;

  /// The source blend mode function.
  int blendFunctionSource = 0;

  /// The destination blend mode function.
  int blendFunctionDestination = 0;

  /// The texture used for particles.
  ui.Image? texture;

  /// The start color of particles.
  ARGB startColor = ARGB(1, 1, 1, 1);

  /// The start color variance of particles.
  ARGB startColorVariance = ARGB(0, 0, 0, 0);

  /// The finish color of particles.
  ARGB finishColor = ARGB(0, 1, 1, 1);

  /// The finish color variance of particles.
  ARGB finishColorVariance = ARGB(0, 0, 0, 0);

  /// The x-coordinate of the emitter position.
  num emitterX = 200;

  /// The y-coordinate of the emitter position.
  num emitterY = 200;

  /// The variance of the source position along the x-axis.
  num sourcePositionVarianceX = 0;

  /// The variance of the source position along the y-axis.
  num sourcePositionVarianceY = 0;

  /// The start size of particles.
  num startSize = 30;

  /// The start size variance of particles.
  num startSizeVariance = 0;

  /// The finish size of particles.
  num finishSize = 0;

  /// The finish size variance of particles.
  num finishSizeVariance = 0;

  /// The speed of particles.
  num speed = 200;

  /// The variance of the speed of particles.
  num speedVariance = 0;

  /// The gravity along the x-axis.
  num gravityX = 0;

  /// The gravity along the y-axis.
  num gravityY = 0;

  /// The initial angle of particle emission.
  num angle = 0;

  /// The variance of the initial angle of particle emission.
  num angleVariance = 360;

  /// The minimum radius of particle emission.
  num minRadius = 0;

  /// The variance of the minimum radius of particle emission.
  num minRadiusVariance = 0;

  /// The maximum radius of particle emission.
  num maxRadius = 0;

  /// The variance of the maximum radius of particle emission.
  num maxRadiusVariance = 0;

  /// The rotation rate of particles per second.
  num rotatePerSecond = 0;

  /// The variance of the rotation rate of particles per second.
  num rotatePerSecondVariance = 0;

  /// The radial acceleration of particles.
  num radialAcceleration = 0;

  /// The variance of the radial acceleration of particles.
  num radialAccelerationVariance = 0;

  /// The tangential acceleration of particles.
  num tangentialAcceleration = 0;

  /// The variance of the tangential acceleration of particles.
  num tangentialAccelerationVariance = 0;

  /// The type of emitter (gravity or radius).
  EmitterType emitterType = EmitterType.gravity;

  /// First time initialize controller
  void initialize({
    required ui.Image texture,
    Map? configs,
  }) async {
    update(texture: texture);
    if (configs == null) return;
    update(
      startColor: ARGB.fromMap(configs, "startColor"),
      startColorVariance: ARGB.fromMap(configs, "startColorVariance"),
      finishColor: ARGB.fromMap(configs, "finishColor"),
      finishColorVariance: ARGB.fromMap(configs, "finishColorVariance"),
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
    );
  }

  /// particle system updater method
  void update({
    EmitterType? emitterType,
    int? duration,
    int? lifespan,
    int? lifespanVariance,
    int? maxParticles,
    int? blendFunctionSource,
    int? blendFunctionDestination,
    ARGB? startColor,
    ARGB? startColorVariance,
    ARGB? finishColor,
    ARGB? finishColorVariance,
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
    ui.Image? texture,
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
    if (texture != null) {
      this.texture = texture;
    }
    notifyListeners();
  }
}

/// The wrapper class for colors
class ARGB {
  /// Represents Alpha channel
  num a;

  /// Represents Red channel
  num r;

  /// Represents Green channel
  num g;

  /// Represents Blue channel
  num b;
  ARGB(this.a, this.r, this.g, this.b);

  /// Create ARGB class and assign members with data
  static ARGB fromMap(Map map, String name) {
    var color = ARGB(1, 1, 1, 1);
    color.a = map["${name}Alpha"];
    color.r = map["${name}Red"];
    color.g = map["${name}Green"];
    color.b = map["${name}Blue"];
    return color;
  }
}
