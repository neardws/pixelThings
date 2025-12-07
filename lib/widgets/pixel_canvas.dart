import 'package:flutter/material.dart';
import 'package:pixel_things/core/models/pixel_matrix.dart';
import 'package:pixel_things/core/utils/color_utils.dart';

class PixelCanvas extends StatelessWidget {
  final PixelMatrix matrix;
  final double pixelGap;

  const PixelCanvas({
    super.key,
    required this.matrix,
    this.pixelGap = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PixelCanvasPainter(
        matrix: matrix,
        pixelGap: pixelGap,
      ),
      size: Size.infinite,
    );
  }
}

class _PixelCanvasPainter extends CustomPainter {
  final PixelMatrix matrix;
  final double pixelGap;

  _PixelCanvasPainter({
    required this.matrix,
    required this.pixelGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pixelWidth = size.width / matrix.width;
    final pixelHeight = size.height / matrix.height;
    final pixelSize = pixelWidth < pixelHeight ? pixelWidth : pixelHeight;

    final totalWidth = pixelSize * matrix.width;
    final totalHeight = pixelSize * matrix.height;
    final offsetX = (size.width - totalWidth) / 2;
    final offsetY = (size.height - totalHeight) / 2;

    final paint = Paint()..style = PaintingStyle.fill;

    for (var y = 0; y < matrix.height; y++) {
      for (var x = 0; x < matrix.width; x++) {
        final color = matrix.getPixel(x, y);
        final displayColor = (color.value == 0xFF000000 || color.opacity == 0)
            ? PixelColors.pixelOff
            : color;

        final centerX = offsetX + x * pixelSize + pixelSize / 2;
        final centerY = offsetY + y * pixelSize + pixelSize / 2;
        final radius = (pixelSize - pixelGap * 2) / 2;

        paint.color = displayColor;
        canvas.drawCircle(Offset(centerX, centerY), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PixelCanvasPainter oldDelegate) {
    return true; // Always repaint for animations
  }
}
