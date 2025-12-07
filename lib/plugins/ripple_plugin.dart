import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pixel_things/plugins/plugin_interface.dart';
import 'package:pixel_things/core/models/pixel_matrix.dart';

class Ripple {
  double x, y;
  double radius;
  double maxRadius;
  double speed;
  Color color;
  double life;

  Ripple({
    required this.x,
    required this.y,
    required this.maxRadius,
    required this.speed,
    required this.color,
  }) : radius = 0, life = 1.0;

  bool get isDead => radius >= maxRadius;
}

class RipplePlugin implements Plugin {
  @override
  final String id = 'ripple';

  @override
  final String name = 'Ripple';

  final Random _random = Random();
  final List<Ripple> _ripples = [];
  int _width = 0;
  int _height = 0;
  bool _initialized = false;
  int _spawnTimer = 0;
  static const int _spawnInterval = 800; // ms

  void _ensureInitialized(int width, int height) {
    if (!_initialized || _width != width || _height != height) {
      _width = width;
      _height = height;
      _initialized = true;
      _ripples.clear();
    }
  }

  @override
  void onActivate() {
    _initialized = false;
    _spawnTimer = 0;
  }

  @override
  void onDeactivate() {
    _ripples.clear();
  }

  @override
  void reset() {
    _ripples.clear();
    _spawnTimer = 0;
  }

  void _spawnRipple() {
    final x = _random.nextDouble() * _width;
    final y = _random.nextDouble() * _height;
    final hue = _random.nextDouble() * 360;
    final maxRadius = 5 + _random.nextDouble() * 10;

    _ripples.add(Ripple(
      x: x,
      y: y,
      maxRadius: maxRadius,
      speed: 0.01 + _random.nextDouble() * 0.01,
      color: HSVColor.fromAHSV(1, hue, 0.8, 1).toColor(),
    ));
  }

  @override
  void update(PixelMatrix matrix, int deltaTime) {
    _ensureInitialized(matrix.width, matrix.height);

    // 生成新水波
    _spawnTimer += deltaTime;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnRipple();
      
      // 有时同时生成多个
      if (_random.nextDouble() < 0.4) {
        _spawnRipple();
      }
    }

    // 更新水波
    for (final ripple in _ripples) {
      ripple.radius += ripple.speed * deltaTime;
      ripple.life = 1.0 - (ripple.radius / ripple.maxRadius);
    }

    _ripples.removeWhere((r) => r.isDead);

    // 渲染
    _render(matrix);
  }

  void _render(PixelMatrix matrix) {
    // 背景渐变
    for (int y = 0; y < _height; y++) {
      for (int x = 0; x < _width; x++) {
        // 深蓝色背景
        final bgColor = Color.fromRGBO(0, 0, 20, 1);
        matrix.setPixel(x, y, bgColor);
      }
    }

    // 绘制水波
    for (final ripple in _ripples) {
      _drawRipple(matrix, ripple);
    }
  }

  void _drawRipple(PixelMatrix matrix, Ripple ripple) {
    final cx = ripple.x.round();
    final cy = ripple.y.round();
    final r = ripple.radius;
    final thickness = 1.5;

    for (int y = 0; y < _height; y++) {
      for (int x = 0; x < _width; x++) {
        final dx = x - cx;
        final dy = y - cy;
        final dist = sqrt(dx * dx + dy * dy);

        // 在环形区域内
        if ((dist - r).abs() < thickness) {
          final intensity = ripple.life * (1 - (dist - r).abs() / thickness);
          if (intensity > 0) {
            final color = Color.fromRGBO(
              (ripple.color.red * intensity).round(),
              (ripple.color.green * intensity).round(),
              (ripple.color.blue * intensity).round(),
              1,
            );
            
            // 与现有颜色混合
            final existing = matrix.getPixel(x, y);
            final blended = Color.fromRGBO(
              min(255, existing.red + color.red),
              min(255, existing.green + color.green),
              min(255, existing.blue + color.blue),
              1,
            );
            matrix.setPixel(x, y, blended);
          }
        }
      }
    }
  }
}
