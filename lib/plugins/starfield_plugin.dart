import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pixel_things/plugins/plugin_interface.dart';
import 'package:pixel_things/core/models/pixel_matrix.dart';

class Star {
  double x, y, z;
  double speed;

  Star(this.x, this.y, this.z, this.speed);
}

class StarfieldPlugin implements Plugin {
  @override
  final String id = 'starfield';

  @override
  final String name = 'Starfield';

  final Random _random = Random();
  final List<Star> _stars = [];
  int _width = 0;
  int _height = 0;
  static const int _numStars = 50;
  bool _initialized = false;

  void _ensureInitialized(int width, int height) {
    if (!_initialized || _width != width || _height != height) {
      _width = width;
      _height = height;
      _initialized = true;
      _initStars();
    }
  }

  void _initStars() {
    _stars.clear();
    for (int i = 0; i < _numStars; i++) {
      _stars.add(_createStar());
    }
  }

  Star _createStar() {
    return Star(
      _random.nextDouble() * _width - _width / 2,
      _random.nextDouble() * _height - _height / 2,
      _random.nextDouble() * 10 + 1,
      _random.nextDouble() * 0.05 + 0.02,
    );
  }

  @override
  void onActivate() {
    _initialized = false;
  }

  @override
  void onDeactivate() {
    _stars.clear();
  }

  @override
  void reset() {
    _initStars();
  }

  @override
  void update(PixelMatrix matrix, int deltaTime) {
    _ensureInitialized(matrix.width, matrix.height);

    final centerX = _width / 2;
    final centerY = _height / 2;

    for (final star in _stars) {
      // 移动星星（向观察者靠近）
      star.z -= star.speed * deltaTime;

      // 如果星星太近，重置到远处
      if (star.z <= 0.1) {
        star.x = _random.nextDouble() * _width - _width / 2;
        star.y = _random.nextDouble() * _height - _height / 2;
        star.z = 10;
      }

      // 投影到2D
      final screenX = (star.x / star.z * 5 + centerX).round();
      final screenY = (star.y / star.z * 5 + centerY).round();

      if (screenX >= 0 && screenX < _width && screenY >= 0 && screenY < _height) {
        // 亮度随距离变化
        final brightness = (1 - star.z / 10).clamp(0.3, 1.0);
        final gray = (brightness * 255).round();
        matrix.setPixel(screenX, screenY, Color.fromRGBO(gray, gray, gray, 1.0));
      }
    }
  }
}
