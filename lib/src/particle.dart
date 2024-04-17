import 'dart:math' as math;

import 'package:flutter/material.dart';

enum EmitterType { gravity, radius }

class Particle {
  EmitterType emitterType = EmitterType.gravity;
  int age = 0;
  double speed = 0;
  int lifespan = 0;
  double size = 100;
  double x = 0, y = 0, angle = 0;
  double radius = 0, radiusDelta = 0;
  double emitterX = 0, emitterY = 0;
  double velocityX = 0, velocityY = 0;
  double gravityX = 0, gravityY = 0;
  double startSize = 0, finishSize = 0;
  double minRadius = 0, maxRadius = 0, rotatePerSecond = 0;
  double radialAcceleration = 0, tangentialAcceleration = 0;
  ParticleColor color = ParticleColor(0);
  ParticleTransform transform = ParticleTransform(0, 0, 0, 0);
  Color startColor = Colors.white, finishColor = Colors.white;

  void initialize({
    EmitterType emitterType = EmitterType.gravity,
    required int age,
    required int lifespan,
    required double speed,
    required double angle,
    required double emitterX,
    required double emitterY,
    required double startSize,
    required double finishSize,
    required Color startColor,
    required Color finishColor,
    double rotatePerSecond = 0,
    double radialAcceleration = 0,
    double tangentialAcceleration = 0,
    double minRadius = 0,
    double maxRadius = 0,
    double gravityX = 0,
    double gravityY = 0,
  }) {
    this.emitterType = emitterType;
    this.age = age;
    this.lifespan = lifespan;
    this.speed = speed;
    this.angle = angle;
    this.emitterX = emitterX;
    this.emitterY = emitterY;
    this.startSize = startSize;
    this.finishSize = finishSize;
    this.startColor = startColor;
    this.finishColor = finishColor;
    this.rotatePerSecond = rotatePerSecond;
    this.radialAcceleration = radialAcceleration;
    this.tangentialAcceleration = tangentialAcceleration;
    this.minRadius = minRadius;
    this.maxRadius = maxRadius;
    this.gravityX = gravityX;
    this.gravityY = gravityY;

    age = 0;
    x = emitterX;
    y = emitterY;
    size = startSize;
    color.update(
        startColor.alpha, startColor.red, startColor.green, startColor.blue);
    radius = maxRadius;
    radiusDelta = (minRadius - maxRadius);
    velocityX = speed * math.cos(angle / 180.0 * math.pi);
    velocityY = speed * math.sin(angle / 180.0 * math.pi);
  }

  void update(int deltaTime) {
    if (isDead()) return;
    age += deltaTime;
    var ratio = age / lifespan;
    var rate = deltaTime / lifespan;

    angle -= rotatePerSecond * rate;
    if (emitterType == EmitterType.radius) {
      radius += radiusDelta * rate;
      x = emitterX - math.cos(angle / 180.0 * math.pi) * radius;
      y = emitterY - math.sin(angle / 180.0 * math.pi) * radius;
    } else {
      var distanceX = x - emitterX;
      var distanceY = y - emitterY;
      var distanceScalar =
          math.sqrt(distanceX * distanceX + distanceY * distanceY);
      if (distanceScalar < 0.01) distanceScalar = 0.01;

      var radialX = distanceX / distanceScalar;
      var radialY = distanceY / distanceScalar;
      var tangentialX = radialX;
      var tangentialY = radialY;

      radialX *= radialAcceleration;
      radialY *= radialAcceleration;

      var newY = tangentialX;
      tangentialX = -tangentialY * tangentialAcceleration;
      tangentialY = newY * tangentialAcceleration;

      velocityX += rate * (gravityX + radialX + tangentialX);
      velocityY += rate * (gravityY + radialY + tangentialY);
      x += velocityX * rate;
      y += velocityY * rate;
    }

    color.lerp(startColor, finishColor, ratio);
    size = startSize + (finishSize - startSize) * ratio;
  }

  bool isDead() {
    return age > lifespan;
  }
}

class ParticleTransform extends RSTransform {
  double _scos = 0, _ssin = 0, _tx = 0, _ty = 0;
  ParticleTransform(super.scos, super.ssin, super.tx, super.ty);

  void update({
    required double rotation,
    required double scale,
    required double anchorX,
    required double anchorY,
    required double translateX,
    required double translateY,
  }) {
    _scos = math.cos(rotation) * scale;
    _ssin = math.sin(rotation) * scale;
    _tx = translateX + -scos * anchorX + ssin * anchorY;
    _ty = translateY + -ssin * anchorX - scos * anchorY;
  }

  /// The cosine of the rotation multiplied by the scale factor.
  @override
  double get scos => _scos;

  /// The sine of the rotation multiplied by that same scale factor.
  @override
  double get ssin => _ssin;

  /// The x coordinate of the translation, minus [scos] multiplied by the
  /// x-coordinate of the rotation point, plus [ssin] multiplied by the
  /// y-coordinate of the rotation point.
  @override
  double get tx => _tx;

  /// The y coordinate of the translation, minus [ssin] multiplied by the
  /// x-coordinate of the rotation point, minus [scos] multiplied by the
  /// y-coordinate of the rotation point.
  @override
  double get ty => _ty;
}

class ParticleColor extends Color {
  @override
  // ignore: overridden_fields
  int value = 0;

  ParticleColor(super.value);

  void update(int a, int r, int g, int b) {
    value = (((a & 0xff) << 24) |
            ((r & 0xff) << 16) |
            ((g & 0xff) << 8) |
            ((b & 0xff) << 0)) &
        0xFFFFFFFF;
  }

  void lerp(Color a, Color b, double t) {
    update(
      _clampInt(_lerpInt(a.alpha, b.alpha, t).toInt(), 0, 255),
      _clampInt(_lerpInt(a.red, b.red, t).toInt(), 0, 255),
      _clampInt(_lerpInt(a.green, b.green, t).toInt(), 0, 255),
      _clampInt(_lerpInt(a.blue, b.blue, t).toInt(), 0, 255),
    );
  }

  /// Linearly interpolate between two integers.
  double _lerpInt(int a, int b, double t) {
    return a + (b - a) * t;
  }

  /// Same as [num.clamp] but specialized for non-null [int].
  int _clampInt(int value, int min, int max) {
    if (value < min) {
      return min;
    }
    if (value > max) {
      return max;
    }
    return value;
  }

  /// The alpha channel of this color in an 8 bit value.
  ///
  /// A value of 0 means this color is fully transparent. A value of 255 means
  /// this color is fully opaque.
  @override
  int get alpha => (0xff000000 & value) >> 24;

  /// The red channel of this color in an 8 bit value.
  @override
  int get red => (0x00ff0000 & value) >> 16;

  /// The green channel of this color in an 8 bit value.
  @override
  int get green => (0x0000ff00 & value) >> 8;

  /// The blue channel of this color in an 8 bit value.
  @override
  int get blue => (0x000000ff & value) >> 0;
}
