import 'package:pixel_things/plugins/plugin_interface.dart';
import 'package:pixel_things/core/models/pixel_matrix.dart';
import 'package:pixel_things/core/utils/color_utils.dart';

class RainbowPlugin implements Plugin {
  @override
  String get name => 'Rainbow';
  
  @override
  String get id => 'rainbow_effect';

  double _offset = 0;
  static const double _speed = 0.02;

  @override
  void reset() {
    _offset = 0;
  }

  @override
  void update(PixelMatrix matrix, int deltaTime) {
    _offset += _speed;
    if (_offset > 1) _offset -= 1;

    for (var y = 0; y < matrix.height; y++) {
      for (var x = 0; x < matrix.width; x++) {
        final hue = ((x / matrix.width) + _offset) % 1.0;
        final color = PixelColors.hsvToColor(hue, 1.0, 1.0);
        matrix.setPixel(x, y, color);
      }
    }
  }

  @override
  void onActivate() {}

  @override
  void onDeactivate() {}
}
