import 'dart:ui';

class PixelColors {
  static const Color background = Color(0xFF000000);
  static const Color pixelOff = Color(0xFF111111);
  static const Color timeColor = Color(0xFF00FF00);
  static const Color dateColor = Color(0xFF00AAFF);
  static const Color weekActive = Color(0xFFFFFFFF);
  static const Color weekInactive = Color(0xFF333333);
  static const Color colonColor = Color(0xFF00FF00);
  static const Color secondsColor = Color(0xFF00CC00);

  static const List<Color> fireColors = [
    Color(0xFF000000),
    Color(0xFF1F0707),
    Color(0xFF3F0F0F),
    Color(0xFF5F1F00),
    Color(0xFF7F2F00),
    Color(0xFF9F4F00),
    Color(0xFFBF6F00),
    Color(0xFFDF8F00),
    Color(0xFFFFAF00),
    Color(0xFFFFCF00),
    Color(0xFFFFEF00),
    Color(0xFFFFFF00),
    Color(0xFFFFFFAA),
  ];

  static const List<Color> matrixColors = [
    Color(0xFF003300),
    Color(0xFF004400),
    Color(0xFF005500),
    Color(0xFF006600),
    Color(0xFF007700),
    Color(0xFF008800),
    Color(0xFF009900),
    Color(0xFF00AA00),
    Color(0xFF00BB00),
    Color(0xFF00CC00),
    Color(0xFF00DD00),
    Color(0xFF00EE00),
    Color(0xFF00FF00),
  ];

  static const List<Color> rainbowColors = [
    Color(0xFFFF0000),
    Color(0xFFFF7F00),
    Color(0xFFFFFF00),
    Color(0xFF00FF00),
    Color(0xFF0000FF),
    Color(0xFF4B0082),
    Color(0xFF9400D3),
  ];

  static Color lerpColor(Color c1, Color c2, double t) {
    return Color.lerp(c1, c2, t) ?? c1;
  }

  static Color hsvToColor(double h, double s, double v) {
    final c = v * s;
    final x = c * (1 - ((h * 6) % 2 - 1).abs());
    final m = v - c;

    double r, g, b;
    if (h < 1 / 6) {
      r = c; g = x; b = 0;
    } else if (h < 2 / 6) {
      r = x; g = c; b = 0;
    } else if (h < 3 / 6) {
      r = 0; g = c; b = x;
    } else if (h < 4 / 6) {
      r = 0; g = x; b = c;
    } else if (h < 5 / 6) {
      r = x; g = 0; b = c;
    } else {
      r = c; g = 0; b = x;
    }

    return Color.fromRGBO(
      ((r + m) * 255).round(),
      ((g + m) * 255).round(),
      ((b + m) * 255).round(),
      1,
    );
  }
}
