import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pixel_things/plugins/plugin_interface.dart';
import 'package:pixel_things/core/models/pixel_matrix.dart';

class PlasmaPlugin implements Plugin {
  @override
  final String id = 'plasma';

  @override
  final String name = 'Plasma';

  double _time = 0;
  int _width = 0;
  int _height = 0;

  @override
  void onActivate() {}

  @override
  void onDeactivate() {}

  @override
  void reset() {
    _time = 0;
  }

  @override
  void update(PixelMatrix matrix, int deltaTime) {
    _width = matrix.width;
    _height = matrix.height;
    _time += deltaTime / 1000.0;

    for (int y = 0; y < _height; y++) {
      for (int x = 0; x < _width; x++) {
        // 多个正弦波组合产生等离子效果
        final v1 = sin(x * 0.2 + _time);
        final v2 = sin((y * 0.2 + _time) * 0.5);
        final v3 = sin((x * 0.1 + y * 0.1 + _time) * 0.7);
        final v4 = sin(sqrt((x - _width / 2) * (x - _width / 2) + 
                           (y - _height / 2) * (y - _height / 2)) * 0.3 - _time);

        final value = (v1 + v2 + v3 + v4) / 4.0;
        
        // 将值映射到色相
        final hue = ((value + 1) * 180 + _time * 30) % 360;
        final color = HSVColor.fromAHSV(1.0, hue, 0.8, 0.9).toColor();
        
        matrix.setPixel(x, y, color);
      }
    }
  }
}
