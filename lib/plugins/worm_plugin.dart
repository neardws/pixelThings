import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pixel_things/plugins/plugin_interface.dart';
import 'package:pixel_things/core/models/pixel_matrix.dart';

class WormSegment {
  int x;
  int y;

  WormSegment(this.x, this.y);

  WormSegment copy() => WormSegment(x, y);
}

class Food {
  int x;
  int y;
  Color color;
  int pulse = 0;

  Food(this.x, this.y, this.color);
}

class WormPlugin implements Plugin {
  @override
  final String id = 'worm';

  @override
  final String name = 'Worm';

  final Random _random = Random();

  List<WormSegment> _worm = [];
  Food? _food;
  int _directionX = 1;
  int _directionY = 0;
  int _moveTimer = 0;
  static const int _moveInterval = 100; // ms
  int _width = 0;
  int _height = 0;
  double _hue = 0;

  final List<Color> _wormColors = [];
  static const int _maxLength = 30;
  bool _initialized = false;

  void _ensureInitialized(int width, int height) {
    if (!_initialized || _width != width || _height != height) {
      _width = width;
      _height = height;
      _initialized = true;
      _resetWorm();
    }
  }

  @override
  void reset() {
    _resetWorm();
  }

  @override
  void onActivate() {
    _initialized = false;
  }

  @override
  void onDeactivate() {
    _worm.clear();
    _wormColors.clear();
  }

  void _resetWorm() {
    if (_width == 0 || _height == 0) return;
    _worm = [WormSegment(_width ~/ 2, _height ~/ 2)];
    _wormColors.clear();
    _wormColors.add(_getNextColor());
    _directionX = _random.nextBool() ? 1 : -1;
    _directionY = 0;
    _spawnFood();
    _hue = _random.nextDouble() * 360;
  }

  Color _getNextColor() {
    _hue = (_hue + 15) % 360;
    return HSVColor.fromAHSV(1.0, _hue, 0.8, 1.0).toColor();
  }

  void _spawnFood() {
    int x, y;
    int attempts = 0;
    do {
      x = _random.nextInt(_width);
      y = _random.nextInt(_height);
      attempts++;
    } while (_isWormAt(x, y) && attempts < 100);

    final foodHue = _random.nextDouble() * 360;
    _food = Food(x, y, HSVColor.fromAHSV(1.0, foodHue, 1.0, 1.0).toColor());
  }

  bool _isWormAt(int x, int y) {
    for (final seg in _worm) {
      if (seg.x == x && seg.y == y) return true;
    }
    return false;
  }

  @override
  void update(PixelMatrix matrix, int deltaTime) {
    _ensureInitialized(matrix.width, matrix.height);
    
    _moveTimer += deltaTime;

    // 更新食物脉冲动画
    if (_food != null) {
      _food!.pulse = (_food!.pulse + deltaTime) % 500;
    }

    if (_moveTimer >= _moveInterval) {
      _moveTimer = 0;
      _moveWorm(matrix);
    }

    _render(matrix);
  }

  void _moveWorm(PixelMatrix matrix) {
    if (_worm.isEmpty) return;

    final head = _worm.first;

    // AI: 朝食物方向移动
    if (_food != null) {
      _updateDirection(head.x, head.y, _food!.x, _food!.y);
    }

    // 计算新头部位置
    int newX = (head.x + _directionX + _width) % _width;
    int newY = (head.y + _directionY + _height) % _height;

    // 避免撞到自己 - 简单检查
    if (_isWormAt(newX, newY) && _worm.length > 1) {
      // 尝试其他方向
      final alternatives = [
        [1, 0], [-1, 0], [0, 1], [0, -1]
      ];
      for (final alt in alternatives) {
        final testX = (head.x + alt[0] + _width) % _width;
        final testY = (head.y + alt[1] + _height) % _height;
        if (!_isWormAt(testX, testY)) {
          _directionX = alt[0];
          _directionY = alt[1];
          newX = testX;
          newY = testY;
          break;
        }
      }
    }

    // 移动蠕虫：添加新头部
    _worm.insert(0, WormSegment(newX, newY));
    _wormColors.insert(0, _getNextColor());

    // 检查是否吃到食物
    if (_food != null && newX == _food!.x && newY == _food!.y) {
      // 吃到食物 - 不移除尾部，蠕虫变长
      _spawnFood();

      // 如果太长，重置
      if (_worm.length >= _maxLength) {
        _resetWorm();
      }
    } else {
      // 没吃到食物 - 移除尾部
      _worm.removeLast();
      _wormColors.removeLast();
    }
  }

  void _updateDirection(int fromX, int fromY, int toX, int toY) {
    int dx = toX - fromX;
    int dy = toY - fromY;

    // 考虑环绕
    if (dx.abs() > _width / 2) {
      dx = dx > 0 ? dx - _width : dx + _width;
    }
    if (dy.abs() > _height / 2) {
      dy = dy > 0 ? dy - _height : dy + _height;
    }

    // 随机选择方向（避免总是直线移动）
    if (_random.nextDouble() < 0.7) {
      // 70% 概率朝食物移动
      if (dx.abs() > dy.abs()) {
        _directionX = dx > 0 ? 1 : -1;
        _directionY = 0;
      } else if (dy != 0) {
        _directionX = 0;
        _directionY = dy > 0 ? 1 : -1;
      }
    } else {
      // 30% 概率随机转向
      if (_directionX != 0) {
        _directionX = 0;
        _directionY = _random.nextBool() ? 1 : -1;
      } else {
        _directionY = 0;
        _directionX = _random.nextBool() ? 1 : -1;
      }
    }
  }

  void _render(PixelMatrix matrix) {
    // 渲染蠕虫
    for (var i = 0; i < _worm.length; i++) {
      final seg = _worm[i];
      if (seg.x >= 0 && seg.x < _width && seg.y >= 0 && seg.y < _height) {
        // 尾部渐暗
        final brightness = 1.0 - (i / _worm.length) * 0.6;
        final color = _wormColors[i];
        final fadedColor = Color.fromRGBO(
          (color.red * brightness).round(),
          (color.green * brightness).round(),
          (color.blue * brightness).round(),
          1.0,
        );
        matrix.setPixel(seg.x, seg.y, fadedColor);
      }
    }

    // 渲染食物（带脉冲效果）
    if (_food != null) {
      final pulseIntensity = 0.7 + 0.3 * sin(_food!.pulse / 500 * 2 * pi);
      final foodColor = Color.fromRGBO(
        (_food!.color.red * pulseIntensity).round(),
        (_food!.color.green * pulseIntensity).round(),
        (_food!.color.blue * pulseIntensity).round(),
        1.0,
      );
      matrix.setPixel(_food!.x, _food!.y, foodColor);
    }
  }

}
