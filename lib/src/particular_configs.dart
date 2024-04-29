import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:particular/particular.dart';

/// Configs for managing parameters and behavior of a particle system.
class ParticularConfigs {
  /// The index of the particle system.
  int index = 0;

  /// Gets the start color of particles.
  Color getStartColor() => _getVariantColor(startColor, startColorVariance);

  /// Gets the finish color of particles.
  Color getFinishColor() => _getVariantColor(finishColor, finishColorVariance);

  /// Gets the lifespan of particles.
  int getLifespan() => _computeVariance(lifespan, lifespanVariance).round();

  /// Gets the x-coordinate of the emitter position.
  double getEmitterX(double scaleFactor) =>
      _getVariantDouble(emitterX, sourcePositionVarianceX * scaleFactor);

  /// Gets the y-coordinate of the emitter position.
  double getEmitterY(double scaleFactor) =>
      _getVariantDouble(emitterY, sourcePositionVarianceY * scaleFactor);

  /// Gets the start size of particles.
  double getStartSize(double scaleFactor) =>
      _getVariantDouble(startSize, startSizeVariance, scaleFactor);

  /// Gets the finish size of particles.
  double getFinishSize(double scaleFactor) =>
      _getVariantDouble(finishSize, finishSizeVariance, scaleFactor);

  /// Gets the speed of particles.
  double getSpeed(double scaleFactor) =>
      _getVariantDouble(speed, speedVariance, scaleFactor);

  /// Gets the emission angle of particles.
  double getAngle() => _getVariantDouble(angle, angleVariance);

  /// Gets the minimum radius of particles.
  double getMinRadius(double scaleFactor) =>
      _getVariantDouble(minRadius, minRadiusVariance, scaleFactor);

  /// Gets the maximum radius of particles.
  double getMaxRadius(double scaleFactor) =>
      _getVariantDouble(maxRadius, maxRadiusVariance, scaleFactor);

  /// Gets the rotation rate of particles per second.
  double getRotatePerSecond() =>
      _getVariantDouble(rotatePerSecond, rotatePerSecondVariance);

  /// Gets the start rotation of particles.
  double getStartRotaion() =>
      _getVariantDouble(startRotation, startRotationVariance);

  /// Gets the end rotation of particles.
  double getFinishRotaion() =>
      _getVariantDouble(finishRotation, finishRotationVariance);

  /// Gets the radial acceleration of particles.
  double getRadialAcceleration() =>
      _getVariantDouble(radialAcceleration, radialAccelerationVariance);

  /// Gets the tangential acceleration of particles.
  double getTangentialAcceleration() =>
      _getVariantDouble(tangentialAcceleration, tangentialAccelerationVariance);

  /// Computes a value with a random variance.
  num _computeVariance(num base, num variance, [num coef = 1]) {
    if (variance == 0) {
      return base * coef;
    }
    final randomFactor = math.Random().nextDouble() * 2.0 - 1.0;
    return (base + variance * randomFactor) * coef;
  }

  /// Compounnd base double with a random variance double.
  double _getVariantDouble(num base, num variance, [num coef = 1]) =>
      _computeVariance(base, variance, coef).toDouble();

  /// Compounnd base color with a random variance color.
  Color _getVariantColor(ARGB base, ARGB variance) {
    var alpha = _computeVariance(base.a, variance.a, 255).clamp(0, 255).round();
    var red = _computeVariance(base.r, variance.r, 255).clamp(0, 255).round();
    var green = _computeVariance(base.g, variance.g, 255).clamp(0, 255).round();
    var blue = _computeVariance(base.b, variance.b, 255).clamp(0, 255).round();
    return Color.fromARGB(alpha, red, green, blue);
  }

  /// The name of the config.
  String configName = "";

  /// The duration of the particle system in milliseconds, -1 for infinite.
  int duration = -1;

  /// The start time of the particle system in milliseconds.
  int startTime = 0;

  /// The lifespan of particles in milliseconds.
  int lifespan = 1000;

  /// The variance of the lifespan of particles in milliseconds.
  int lifespanVariance = 0;

  /// The maximum number of particles.
  int maxParticles = 100;

  /// The blend mode value of textures.
  BlendMode textureBlendMode = BlendMode.srcOver;

  /// The blend mode value for rendering.
  BlendMode renderBlendMode = BlendMode.srcIn;

  /// The source blend mode function.
  BlendFunction blendFunctionSource = BlendFunction.one;

  /// The destination blend mode function.
  BlendFunction blendFunctionDestination = BlendFunction.oneMinusSourceAlpha;

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

  /// The emitter position along the x-axis.
  num emitterX = 200;

  /// The emitter position along the y-axis.
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

  /// The initial angle of particle emission in degrees.
  num angle = 0;

  /// The variance of the initial angle of particle emission in degrees.
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

  /// The start rotation of particles.
  num startRotation = 0;

  /// The start rotation variance of particles.
  num startRotationVariance = 0;

  /// The final rotation of particles.
  num finishRotation = 0;

  /// The final rotation variance of particles.
  num finishRotationVariance = 0;

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

  /// The map of notifiers
  final Map<String, ChangeNotifier> _notifiers = {};

  /// Get notifier
  ChangeNotifier getNotifier(String key) =>
      _notifiers[key] ??= ChangeNotifier();

  /// First time initialize controller
  void initialize({
    Map<dynamic, dynamic>? configs,
    ui.Image? texture,
  }) async {
    if (texture != null) {
      this.texture = texture;
    }
    if (configs == null) return;
    update(
      configName: configs["configName"],
      emitterType: EmitterType.values[configs["emitterType"]],
      blendFunctionSource:
          BlendFunction.fromValue(configs["blendFuncSource"] ?? 0),
      blendFunctionDestination:
          BlendFunction.fromValue(configs["blendFuncDestination"] ?? 0),
      renderBlendMode: BlendMode.values[configs["renderBlendMode"] ?? 0],
      textureBlendMode: BlendMode.values[configs["textureBlendMode"] ?? 0],
      startColor: ARGB.fromMap(configs, "startColor"),
      startColorVariance: ARGB.fromMap(configs, "startColorVariance"),
      finishColor: ARGB.fromMap(configs, "finishColor"),
      finishColorVariance: ARGB.fromMap(configs, "finishColorVariance"),
      lifespan: (configs["particleLifespan"] * 1000).round(),
      lifespanVariance: (configs["particleLifespanVariance"] * 1000).round(),
      duration:
          (configs["duration"] * (configs["duration"] > -1 ? 1000 : 1)).round(),
      maxParticles: configs["maxParticles"],
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
      startRotation: configs["rotationStart"],
      startRotationVariance: configs["rotationStartVariance"],
      finishRotation: configs["rotationEnd"],
      finishRotationVariance: configs["rotationEndVariance"],
      radialAcceleration: configs["radialAcceleration"],
      radialAccelerationVariance: configs["radialAccelVariance"],
      tangentialAcceleration: configs["tangentialAcceleration"],
      tangentialAccelerationVariance: configs["tangentialAccelVariance"],
    );
  }

  /// particle system updater method
  void update({
    String? configName,
    EmitterType? emitterType,
    BlendMode? renderBlendMode,
    BlendMode? textureBlendMode,
    BlendFunction? blendFunctionSource,
    BlendFunction? blendFunctionDestination,
    int? duration,
    int? startTime,
    int? lifespan,
    int? lifespanVariance,
    int? maxParticles,
    ARGB? startColor,
    ARGB? startColorVariance,
    ARGB? finishColor,
    ARGB? finishColorVariance,
    num? sourcePositionVarianceX,
    num? sourcePositionVarianceY,
    num? startSize,
    num? startSizeVariance,
    num? angle,
    num? angleVariance,
    num? finishSize,
    num? finishSizeVariance,
    num? speed,
    num? speedVariance,
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
    num? startRotation,
    num? startRotationVariance,
    num? finishRotation,
    num? finishRotationVariance,
    num? radialAcceleration,
    num? radialAccelerationVariance,
    num? tangentialAcceleration,
    num? tangentialAccelerationVariance,
    ui.Image? texture,
  }) {
    if (configName != null) {
      this.configName = configName;
    }
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
    if (startTime != null) {
      this.startTime = startTime;
    }
    if (maxParticles != null) {
      this.maxParticles = maxParticles;
    }

    if (textureBlendMode != null) {
      this.textureBlendMode = textureBlendMode;
    }
    if (renderBlendMode != null) {
      this.renderBlendMode = renderBlendMode;
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
    if (startRotation != null) {
      this.startRotation = startRotation;
    }
    if (startRotationVariance != null) {
      this.startRotationVariance = startRotationVariance;
    }
    if (finishRotation != null) {
      this.finishRotation = finishRotation;
    }
    if (finishRotationVariance != null) {
      this.finishRotationVariance = finishRotationVariance;
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
  }

  /// Updates the controller from a map
  void updateFromMap(Map<String, dynamic> args) {
    update(
      configName: args["configName"],
      emitterType: args["emitterType"],
      renderBlendMode: args["renderBlendMode"],
      textureBlendMode: args["textureBlendMode"],
      blendFunctionSource: args["blendFunctionSource"],
      blendFunctionDestination: args["blendFunctionDestination"],
      startTime: args["startTime"],
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
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      getNotifier(key).notifyListeners();
    }
  }

  /// Circulate the given [value] between the specified [min] and [max]
  /// boundaries.
  ///
  /// Parameters:
  ///   - [value]: The value to be clamped.
  ///   - [min]: The lower boundary of the range.
  ///   - [max]: The upper boundary of the range.
  ///
  /// Returns:
  ///   - The clamped value.
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

  /// Clamp value between min and max
  num? _clamp(num? value, int min, int max) {
    if (value == null) return null;
    return value.clamp(min, max);
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

  // Returns a Color object with ARGB values calculated from the current ARGB instance.
  Color getColor() => Color.fromARGB((a * 255).toInt(), (r * 255).toInt(),
      (g * 255).toInt(), (b * 255).toInt());

  Map toMap(String name) {
    return {
      "${name}Alpha": a,
      "${name}Red": r,
      "${name}Green": g,
      "${name}Blue": b
    };
  }
}
