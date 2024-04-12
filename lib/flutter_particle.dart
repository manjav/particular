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
  Color color = Colors.white;
  double radius = 0, radiusDelta = 0;
  double emitterX = 0, emitterY = 0;
  double velocityX = 0, velocityY = 0;
  double gravityX = 0, gravityY = 0;
  double startSize = 0, finishSize = 0;
  double minRadius = 0, maxRadius = 0, rotatePerSecond = 0;
  double radialAcceleration = 0, tangentialAcceleration = 0;
  Color startColor = Colors.white, finishColor = Colors.white;

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

    color = Color.lerp(startColor, finishColor, ratio)!;
    size = startSize + (finishSize - startSize) * ratio;
  }

  bool isDead() {
    return age >= lifespan;
  }

  void initialize({
    EmitterType emitterType = EmitterType.gravity,
    int age = 0,
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
    color = startColor;
    radius = maxRadius;
    radiusDelta = (minRadius - maxRadius);
    velocityX = speed * math.cos(angle / 180.0 * math.pi);
    velocityY = speed * math.sin(angle / 180.0 * math.pi);
  }
}
