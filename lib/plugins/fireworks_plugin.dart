import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pixel_things/plugins/plugin_interface.dart';
import 'package:pixel_things/core/models/pixel_matrix.dart';

class Particle {
  double x, y;
  double vx, vy;
  double life;
  double maxLife;
  Color color;
  bool isRocket;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.maxLife,
    required this.color,
    this.isRocket = false,
  });

  double get lifeRatio => life / maxLife;
}

class FireworksPlugin implements Plugin {
  @override
  final String id = 'fireworks';

  @override
  final String name = 'Fireworks';

  final Random _random = Random();
  final List<Particle> _particles = [];
  int _width = 0;
  int _height = 0;
  bool _initialized = false;
  int _launchTimer = 0;
  static const int _launchInterval = 1500; // ms
  static const double _gravity = 0.00015;

  void _ensureInitialized(int width, int height) {
    if (!_initialized || _width != width || _height != height) {
      _width = width;
      _height = height;
      _initialized = true;
      _particles.clear();
    }
  }

  @override
  void onActivate() {
    _initialized = false;
    _launchTimer = 0;
  }

  @override
  void onDeactivate() {
    _particles.clear();
  }

  @override
  void reset() {
    _particles.clear();
    _launchTimer = 0;
  }

  void _launchRocket() {
    final x = _random.nextDouble() * _width;
    final hue = _random.nextDouble() * 360;
    
    _particles.add(Particle(
      x: x,
      y: _height.toDouble(),
      vx: (_random.nextDouble() - 0.5) * 0.02,
      vy: -0.08 - _random.nextDouble() * 0.03,
      life: 1000 + _random.nextDouble() * 500,
      maxLife: 1500,
      color: HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
      isRocket: true,
    ));
  }

  void _explode(Particle rocket) {
    final numParticles = 20 + _random.nextInt(15);
    final hue = HSVColor.fromColor(rocket.color).hue;

    for (int i = 0; i < numParticles; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 0.02 + _random.nextDouble() * 0.04;
      final particleHue = (hue + _random.nextDouble() * 60 - 30) % 360;

      _particles.add(Particle(
        x: rocket.x,
        y: rocket.y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        life: 500 + _random.nextDouble() * 500,
        maxLife: 1000,
        color: HSVColor.fromAHSV(1, particleHue, 1, 1).toColor(),
        isRocket: false,
      ));
    }
  }

  @override
  void update(PixelMatrix matrix, int deltaTime) {
    _ensureInitialized(matrix.width, matrix.height);

    // 发射新烟花
    _launchTimer += deltaTime;
    if (_launchTimer >= _launchInterval) {
      _launchTimer = 0;
      _launchRocket();
      
      // 有时同时发射多个
      if (_random.nextDouble() < 0.3) {
        _launchRocket();
      }
    }

    // 更新粒子
    final toRemove = <Particle>[];
    final toExplode = <Particle>[];

    for (final p in _particles) {
      // 应用重力
      p.vy += _gravity * deltaTime;

      // 更新位置
      p.x += p.vx * deltaTime;
      p.y += p.vy * deltaTime;

      // 更新生命
      p.life -= deltaTime;

      if (p.life <= 0) {
        toRemove.add(p);
      } else if (p.isRocket && p.vy >= 0) {
        // 火箭到达顶点，爆炸
        toExplode.add(p);
        toRemove.add(p);
      }
    }

    for (final p in toExplode) {
      _explode(p);
    }

    _particles.removeWhere((p) => toRemove.contains(p));

    // 渲染
    _render(matrix);
  }

  void _render(PixelMatrix matrix) {
    for (final p in _particles) {
      final ix = p.x.round();
      final iy = p.y.round();

      if (ix >= 0 && ix < _width && iy >= 0 && iy < _height) {
        final alpha = p.lifeRatio;
        final color = Color.fromRGBO(
          (p.color.red * alpha).round(),
          (p.color.green * alpha).round(),
          (p.color.blue * alpha).round(),
          1,
        );
        matrix.setPixel(ix, iy, color);

        // 火箭绘制尾迹
        if (p.isRocket) {
          for (int i = 1; i <= 3; i++) {
            final ty = iy + i;
            if (ty < _height) {
              final trailAlpha = alpha * (1 - i / 4);
              final trailColor = Color.fromRGBO(
                (255 * trailAlpha).round(),
                (200 * trailAlpha).round(),
                (100 * trailAlpha).round(),
                1,
              );
              matrix.setPixel(ix, ty, trailColor);
            }
          }
        }
      }
    }
  }
}
