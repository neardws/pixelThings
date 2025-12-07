import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pixel_things/plugins/plugin_interface.dart';
import 'package:pixel_things/core/models/pixel_matrix.dart';

class Ball {
  double x, y;
  double vx, vy;
  double radius;
  Color color;
  double hue;

  Ball({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.color,
    required this.hue,
  });
}

class BouncingBallPlugin implements Plugin {
  @override
  final String id = 'bouncing_ball';

  @override
  final String name = 'Bouncing Ball';

  final Random _random = Random();
  final List<Ball> _balls = [];
  int _width = 0;
  int _height = 0;
  bool _initialized = false;
  static const int _numBalls = 5;
  static const double _gravity = 0.0003;
  static const double _friction = 0.999;
  static const double _bounceFactor = 0.9;

  void _ensureInitialized(int width, int height) {
    if (!_initialized || _width != width || _height != height) {
      _width = width;
      _height = height;
      _initialized = true;
      _initBalls();
    }
  }

  void _initBalls() {
    _balls.clear();
    for (int i = 0; i < _numBalls; i++) {
      final hue = (i * 360.0 / _numBalls) + _random.nextDouble() * 30;
      _balls.add(Ball(
        x: _random.nextDouble() * _width,
        y: _random.nextDouble() * _height / 2,
        vx: (_random.nextDouble() - 0.5) * 0.1,
        vy: _random.nextDouble() * 0.05,
        radius: 1.5 + _random.nextDouble(),
        color: HSVColor.fromAHSV(1, hue % 360, 1, 1).toColor(),
        hue: hue,
      ));
    }
  }

  @override
  void onActivate() {
    _initialized = false;
  }

  @override
  void onDeactivate() {
    _balls.clear();
  }

  @override
  void reset() {
    _initBalls();
  }

  @override
  void update(PixelMatrix matrix, int deltaTime) {
    _ensureInitialized(matrix.width, matrix.height);

    for (final ball in _balls) {
      // 应用重力
      ball.vy += _gravity * deltaTime;

      // 应用摩擦
      ball.vx *= _friction;
      ball.vy *= _friction;

      // 更新位置
      ball.x += ball.vx * deltaTime;
      ball.y += ball.vy * deltaTime;

      // 边界碰撞检测
      if (ball.x - ball.radius < 0) {
        ball.x = ball.radius;
        ball.vx = -ball.vx * _bounceFactor;
      } else if (ball.x + ball.radius >= _width) {
        ball.x = _width - ball.radius - 0.1;
        ball.vx = -ball.vx * _bounceFactor;
      }

      if (ball.y - ball.radius < 0) {
        ball.y = ball.radius;
        ball.vy = -ball.vy * _bounceFactor;
      } else if (ball.y + ball.radius >= _height) {
        ball.y = _height - ball.radius - 0.1;
        ball.vy = -ball.vy * _bounceFactor;
        
        // 给一点随机水平速度
        if (ball.vy.abs() < 0.01) {
          ball.vx += (_random.nextDouble() - 0.5) * 0.02;
          ball.vy = -0.08 - _random.nextDouble() * 0.04;
        }
      }

      // 更新颜色
      ball.hue = (ball.hue + deltaTime * 0.01) % 360;
      ball.color = HSVColor.fromAHSV(1, ball.hue, 1, 1).toColor();
    }

    // 球之间碰撞检测
    for (int i = 0; i < _balls.length; i++) {
      for (int j = i + 1; j < _balls.length; j++) {
        _checkBallCollision(_balls[i], _balls[j]);
      }
    }

    // 渲染
    _render(matrix);
  }

  void _checkBallCollision(Ball a, Ball b) {
    final dx = b.x - a.x;
    final dy = b.y - a.y;
    final dist = sqrt(dx * dx + dy * dy);
    final minDist = a.radius + b.radius;

    if (dist < minDist && dist > 0) {
      // 碰撞响应
      final nx = dx / dist;
      final ny = dy / dist;

      // 相对速度
      final dvx = a.vx - b.vx;
      final dvy = a.vy - b.vy;
      final dvn = dvx * nx + dvy * ny;

      if (dvn > 0) return; // 已经分离

      // 更新速度
      a.vx -= dvn * nx;
      a.vy -= dvn * ny;
      b.vx += dvn * nx;
      b.vy += dvn * ny;

      // 分离重叠
      final overlap = (minDist - dist) / 2;
      a.x -= overlap * nx;
      a.y -= overlap * ny;
      b.x += overlap * nx;
      b.y += overlap * ny;
    }
  }

  void _render(PixelMatrix matrix) {
    for (final ball in _balls) {
      final ix = ball.x.round();
      final iy = ball.y.round();
      final r = ball.radius.ceil();

      // 绘制球（带抗锯齿效果）
      for (int dy = -r; dy <= r; dy++) {
        for (int dx = -r; dx <= r; dx++) {
          final px = ix + dx;
          final py = iy + dy;
          if (px >= 0 && px < _width && py >= 0 && py < _height) {
            final dist = sqrt(dx * dx + dy * dy);
            if (dist <= ball.radius) {
              // 中心亮，边缘暗
              final intensity = 1.0 - (dist / ball.radius) * 0.5;
              final color = Color.fromRGBO(
                (ball.color.red * intensity).round(),
                (ball.color.green * intensity).round(),
                (ball.color.blue * intensity).round(),
                1,
              );
              matrix.setPixel(px, py, color);
            }
          }
        }
      }

      // 绘制轨迹光晕
      final trailX = (ball.x - ball.vx * 50).round();
      final trailY = (ball.y - ball.vy * 50).round();
      if (trailX >= 0 && trailX < _width && trailY >= 0 && trailY < _height) {
        final trailColor = Color.fromRGBO(
          ball.color.red ~/ 4,
          ball.color.green ~/ 4,
          ball.color.blue ~/ 4,
          1,
        );
        matrix.setPixel(trailX, trailY, trailColor);
      }
    }
  }
}
