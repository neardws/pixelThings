import 'dart:math';
import 'dart:ui';
import 'package:pixel_things/plugins/plugin_interface.dart';
import 'package:pixel_things/core/models/pixel_matrix.dart';
import 'package:pixel_things/core/utils/color_utils.dart';

class FirePlugin implements Plugin {
  @override
  String get name => 'Fire';
  
  @override
  String get id => 'fire_effect';

  List<List<int>>? _heatMap;
  final _random = Random();

  @override
  void reset() {
    _heatMap = null;
  }

  @override
  void update(PixelMatrix matrix, int deltaTime) {
    if (_heatMap == null || 
        _heatMap!.length != matrix.height || 
        _heatMap![0].length != matrix.width) {
      _heatMap = List.generate(
        matrix.height,
        (_) => List.generate(matrix.width, (_) => 0),
      );
    }

    final heat = _heatMap!;
    final width = matrix.width;
    final height = matrix.height;

    // Generate heat at the bottom
    for (var x = 0; x < width; x++) {
      heat[height - 1][x] = 160 + _random.nextInt(96);
    }

    // Propagate heat upward
    for (var y = 0; y < height - 1; y++) {
      for (var x = 0; x < width; x++) {
        final left = x > 0 ? heat[y + 1][x - 1] : heat[y + 1][x];
        final center = heat[y + 1][x];
        final right = x < width - 1 ? heat[y + 1][x + 1] : heat[y + 1][x];
        final below = y < height - 2 ? heat[y + 2][x] : center;

        final newHeat = ((left + center + right + below) / 4.0 - _random.nextInt(3)).toInt();
        heat[y][x] = newHeat.clamp(0, 255);
      }
    }

    // Render to matrix
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final heatValue = heat[y][x];
        matrix.setPixel(x, y, _heatToColor(heatValue));
      }
    }
  }

  Color _heatToColor(int heat) {
    final colors = PixelColors.fireColors;
    final index = (heat * (colors.length - 1) / 255).clamp(0, colors.length - 1).toInt();
    
    final lowerIndex = index;
    final upperIndex = (index + 1).clamp(0, colors.length - 1);
    final fraction = (heat * (colors.length - 1) / 255.0) - index;
    
    return PixelColors.lerpColor(colors[lowerIndex], colors[upperIndex], fraction);
  }

  @override
  void onActivate() {}

  @override
  void onDeactivate() {}
}
