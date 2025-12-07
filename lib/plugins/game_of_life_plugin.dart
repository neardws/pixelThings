import 'dart:math';
import 'dart:ui';
import 'package:pixel_things/plugins/plugin_interface.dart';
import 'package:pixel_things/core/models/pixel_matrix.dart';
import 'package:pixel_things/core/utils/color_utils.dart';

class GameOfLifePlugin implements Plugin {
  @override
  String get name => 'Game of Life';
  
  @override
  String get id => 'game_of_life';

  List<List<bool>>? _cells;
  int _generation = 0;
  int _stagnantCount = 0;
  int _lastHash = 0;
  final _random = Random();

  @override
  void reset() {
    _cells = null;
    _generation = 0;
    _stagnantCount = 0;
    _lastHash = 0;
  }

  @override
  void update(PixelMatrix matrix, int deltaTime) {
    if (_cells == null || 
        _cells!.length != matrix.height || 
        _cells![0].length != matrix.width) {
      _initializeCells(matrix.width, matrix.height);
    }

    final current = _cells!;
    final newCells = List.generate(
      matrix.height,
      (_) => List.generate(matrix.width, (_) => false),
    );

    for (var y = 0; y < matrix.height; y++) {
      for (var x = 0; x < matrix.width; x++) {
        final neighbors = _countNeighbors(current, x, y, matrix.width, matrix.height);
        final alive = current[y][x];

        if (alive && (neighbors == 2 || neighbors == 3)) {
          newCells[y][x] = true;
        } else if (!alive && neighbors == 3) {
          newCells[y][x] = true;
        }

        final color = newCells[y][x] 
            ? _getColorByGeneration(_generation) 
            : const Color(0xFF000000);
        matrix.setPixel(x, y, color);
      }
    }

    final currentHash = newCells.map((row) => row.hashCode).reduce((a, b) => a ^ b);
    if (currentHash == _lastHash) {
      _stagnantCount++;
      if (_stagnantCount > 10) {
        _initializeCells(matrix.width, matrix.height);
        _stagnantCount = 0;
      }
    } else {
      _stagnantCount = 0;
    }
    _lastHash = currentHash;

    _cells = newCells;
    _generation++;
  }

  void _initializeCells(int width, int height) {
    _cells = List.generate(
      height,
      (_) => List.generate(width, (_) => _random.nextDouble() < 0.3),
    );
    _generation = 0;
  }

  int _countNeighbors(List<List<bool>> cells, int x, int y, int width, int height) {
    var count = 0;
    for (var dy = -1; dy <= 1; dy++) {
      for (var dx = -1; dx <= 1; dx++) {
        if (dx == 0 && dy == 0) continue;
        final nx = (x + dx + width) % width;
        final ny = (y + dy + height) % height;
        if (cells[ny][nx]) count++;
      }
    }
    return count;
  }

  Color _getColorByGeneration(int gen) {
    final hue = (gen * 0.01) % 1.0;
    return PixelColors.hsvToColor(hue, 0.8, 1.0);
  }

  @override
  void onActivate() {}

  @override
  void onDeactivate() {}
}
