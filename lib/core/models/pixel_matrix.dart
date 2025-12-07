import 'dart:ui';

class PixelMatrix {
  final int width;
  final int height;
  final List<List<Color>> pixels;

  PixelMatrix({required this.width, required this.height})
      : pixels = List.generate(
          height,
          (_) => List.generate(width, (_) => const Color(0xFF000000)),
        );

  PixelMatrix.from(this.width, this.height, this.pixels);

  void setPixel(int x, int y, Color color) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      pixels[y][x] = color;
    }
  }

  Color getPixel(int x, int y) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      return pixels[y][x];
    }
    return const Color(0xFF000000);
  }

  void clear([Color color = const Color(0xFF000000)]) {
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        pixels[y][x] = color;
      }
    }
  }

  PixelMatrix copy() {
    final newPixels = List.generate(
      height,
      (y) => List.generate(width, (x) => pixels[y][x]),
    );
    return PixelMatrix.from(width, height, newPixels);
  }
}
