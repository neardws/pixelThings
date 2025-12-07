import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pixel_things/plugins/plugin_interface.dart';
import 'package:pixel_things/core/models/pixel_matrix.dart';

class Snowflake {
  double x, y;
  double speed;
  double drift;
  double driftPhase;
  int brightness;

  Snowflake(this.x, this.y, this.speed, this.drift, this.driftPhase, this.brightness);
}

class SnowPlugin implements Plugin {
  @override
  final String id = 'snow';

  @override
  final String name = 'Snow';

  final Random _random = Random();
  final List<Snowflake> _snowflakes = [];
  int _width = 0;
  int _height = 0;
  static const int _numSnowflakes = 30;
  bool _initialized = false;
  double _time = 0;

  // 地面积雪
  List<int> _groundSnow = [];

  void _ensureInitialized(int width, int height) {
    if (!_initialized || _width != width || _height != height) {
      _width = width;
      _height = height;
      _initialized = true;
      _initSnow();
    }
  }

  void _initSnow() {
    _snowflakes.clear();
    _groundSnow = List.filled(_width, 0);
    
    for (int i = 0; i < _numSnowflakes; i++) {
      _snowflakes.add(_createSnowflake(randomY: true));
    }
  }

  Snowflake _createSnowflake({bool randomY = false}) {
    return Snowflake(
      _random.nextDouble() * _width,
      randomY ? _random.nextDouble() * _height : -1,
      _random.nextDouble() * 0.02 + 0.01,
      _random.nextDouble() * 0.5 + 0.2,
      _random.nextDouble() * pi * 2,
      _random.nextInt(100) + 155,
    );
  }

  @override
  void onActivate() {
    _initialized = false;
  }

  @override
  void onDeactivate() {
    _snowflakes.clear();
    _groundSnow.clear();
  }

  @override
  void reset() {
    _initSnow();
    _time = 0;
  }

  @override
  void update(PixelMatrix matrix, int deltaTime) {
    _ensureInitialized(matrix.width, matrix.height);
    _time += deltaTime / 1000.0;

    // 更新雪花
    for (final flake in _snowflakes) {
      // 垂直下落
      flake.y += flake.speed * deltaTime;
      
      // 水平漂移（正弦波动）
      flake.driftPhase += deltaTime * 0.002;
      flake.x += sin(flake.driftPhase) * flake.drift * 0.5;

      // 检查是否到达地面或积雪
      final groundLevel = _height - 1 - _groundSnow[flake.x.round().clamp(0, _width - 1)];
      
      if (flake.y >= groundLevel) {
        // 积雪
        final ix = flake.x.round().clamp(0, _width - 1);
        if (_groundSnow[ix] < _height - 2) {
          _groundSnow[ix]++;
        }
        
        // 重置雪花
        flake.x = _random.nextDouble() * _width;
        flake.y = -1;
        flake.speed = _random.nextDouble() * 0.02 + 0.01;
      }

      // 边界检查（水平方向环绕）
      if (flake.x < 0) flake.x += _width;
      if (flake.x >= _width) flake.x -= _width;
    }

    // 渲染积雪
    for (int x = 0; x < _width; x++) {
      final snowHeight = _groundSnow[x];
      for (int h = 0; h < snowHeight; h++) {
        final y = _height - 1 - h;
        // 越高的积雪越亮
        final brightness = 200 + (h * 5).clamp(0, 55);
        matrix.setPixel(x, y, Color.fromRGBO(brightness, brightness, brightness, 1.0));
      }
    }

    // 渲染飘落的雪花
    for (final flake in _snowflakes) {
      final ix = flake.x.round();
      final iy = flake.y.round();
      if (ix >= 0 && ix < _width && iy >= 0 && iy < _height) {
        final b = flake.brightness;
        matrix.setPixel(ix, iy, Color.fromRGBO(b, b, b, 1.0));
      }
    }

    // 缓慢融化积雪（每隔一段时间）
    if (_random.nextDouble() < 0.001 * deltaTime) {
      final meltX = _random.nextInt(_width);
      if (_groundSnow[meltX] > 0) {
        _groundSnow[meltX]--;
      }
    }
  }
}
