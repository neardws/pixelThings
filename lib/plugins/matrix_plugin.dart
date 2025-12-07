import 'dart:math';
import 'dart:ui';
import 'package:pixel_things/plugins/plugin_interface.dart';
import 'package:pixel_things/core/models/pixel_matrix.dart';
import 'package:pixel_things/core/utils/color_utils.dart';

class _Drop {
  int x;
  double y;
  double speed;
  int length;

  _Drop({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
  });
}

class MatrixPlugin implements Plugin {
  @override
  String get name => 'Matrix';
  
  @override
  String get id => 'matrix_effect';

  final List<_Drop> _drops = [];
  bool _initialized = false;
  int _matrixWidth = 0;
  int _matrixHeight = 0;
  final _random = Random();

  @override
  void reset() {
    _drops.clear();
    _initialized = false;
  }

  @override
  void update(PixelMatrix matrix, int deltaTime) {
    if (!_initialized || _matrixWidth != matrix.width || _matrixHeight != matrix.height) {
      _initialize(matrix.width, matrix.height);
    }

    matrix.clear(const Color(0xFF000000));

    _drops.removeWhere((drop) {
      drop.y += drop.speed;
      return drop.y - drop.length > matrix.height;
    });

    for (final drop in _drops) {
      for (var i = 0; i < drop.length; i++) {
        final py = (drop.y - i).toInt();
        if (py >= 0 && py < matrix.height) {
          final brightness = 1.0 - (i / drop.length);
          final color = _getMatrixColor(brightness);
          matrix.setPixel(drop.x, py, color);
        }
      }
    }

    if (_random.nextDouble() < 0.3) {
      _addNewDrop();
    }
  }

  void _initialize(int width, int height) {
    _matrixWidth = width;
    _matrixHeight = height;
    _drops.clear();

    for (var i = 0; i < width ~/ 3; i++) {
      _addNewDrop();
    }
    _initialized = true;
  }

  void _addNewDrop() {
    if (_matrixWidth <= 0) return;

    _drops.add(_Drop(
      x: _random.nextInt(_matrixWidth),
      y: _random.nextDouble() * -10,
      speed: _random.nextDouble() * 0.3 + 0.2,
      length: _random.nextInt(8) + 4,
    ));
  }

  Color _getMatrixColor(double brightness) {
    final colors = PixelColors.matrixColors;
    final index = ((colors.length - 1) * brightness).clamp(0, colors.length - 1).toInt();
    return colors[index];
  }

  @override
  void onActivate() {}

  @override
  void onDeactivate() {}
}
