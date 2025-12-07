import 'dart:ui';
import 'package:pixel_things/core/models/pixel_matrix.dart';

class PixelFont {
  static const int charWidth = 5;
  static const int charHeight = 7;
  static const int charSpacing = 1;

  static const int largeCharWidth = 8;
  static const int largeCharHeight = 12;
  static const int largeCharSpacing = 2;

  static const Map<String, List<String>> _smallDigits = {
    '0': ['01110', '10001', '10011', '10101', '11001', '10001', '01110'],
    '1': ['00100', '01100', '00100', '00100', '00100', '00100', '01110'],
    '2': ['01110', '10001', '00001', '00110', '01000', '10000', '11111'],
    '3': ['01110', '10001', '00001', '00110', '00001', '10001', '01110'],
    '4': ['00010', '00110', '01010', '10010', '11111', '00010', '00010'],
    '5': ['11111', '10000', '11110', '00001', '00001', '10001', '01110'],
    '6': ['00110', '01000', '10000', '11110', '10001', '10001', '01110'],
    '7': ['11111', '00001', '00010', '00100', '01000', '01000', '01000'],
    '8': ['01110', '10001', '10001', '01110', '10001', '10001', '01110'],
    '9': ['01110', '10001', '10001', '01111', '00001', '00010', '01100'],
    ':': ['00000', '00100', '00100', '00000', '00100', '00100', '00000'],
    ' ': ['00000', '00000', '00000', '00000', '00000', '00000', '00000'],
  };

  static const Map<String, List<String>> _largeDigits = {
    '0': [
      '00111100', '01111110', '11000011', '11000011',
      '11000011', '11000011', '11000011', '11000011',
      '11000011', '11000011', '01111110', '00111100'
    ],
    '1': [
      '00011000', '00111000', '01111000', '00011000',
      '00011000', '00011000', '00011000', '00011000',
      '00011000', '00011000', '01111110', '01111110'
    ],
    '2': [
      '00111100', '01111110', '11000011', '00000011',
      '00000110', '00001100', '00011000', '00110000',
      '01100000', '11000000', '11111111', '11111111'
    ],
    '3': [
      '00111100', '01111110', '11000011', '00000011',
      '00000110', '00011100', '00011100', '00000110',
      '00000011', '11000011', '01111110', '00111100'
    ],
    '4': [
      '00000110', '00001110', '00011110', '00110110',
      '01100110', '11000110', '11111111', '11111111',
      '00000110', '00000110', '00000110', '00000110'
    ],
    '5': [
      '11111111', '11111111', '11000000', '11000000',
      '11111100', '11111110', '00000011', '00000011',
      '00000011', '11000011', '01111110', '00111100'
    ],
    '6': [
      '00011100', '00111000', '01100000', '11000000',
      '11111100', '11111110', '11000011', '11000011',
      '11000011', '11000011', '01111110', '00111100'
    ],
    '7': [
      '11111111', '11111111', '00000011', '00000110',
      '00001100', '00011000', '00110000', '00110000',
      '00110000', '00110000', '00110000', '00110000'
    ],
    '8': [
      '00111100', '01111110', '11000011', '11000011',
      '01111110', '00111100', '01111110', '11000011',
      '11000011', '11000011', '01111110', '00111100'
    ],
    '9': [
      '00111100', '01111110', '11000011', '11000011',
      '11000011', '01111111', '00111111', '00000011',
      '00000110', '00001100', '00111000', '00110000'
    ],
    ':': [
      '00000000', '00000000', '00011000', '00011000',
      '00000000', '00000000', '00000000', '00000000',
      '00011000', '00011000', '00000000', '00000000'
    ],
    ' ': [
      '00000000', '00000000', '00000000', '00000000',
      '00000000', '00000000', '00000000', '00000000',
      '00000000', '00000000', '00000000', '00000000'
    ],
  };

  static PixelMatrix renderSmallText(String text, Color color) {
    final totalWidth = text.isEmpty 
        ? 1 
        : text.length * (charWidth + charSpacing) - charSpacing;
    final matrix = PixelMatrix(width: totalWidth, height: charHeight);

    var xOffset = 0;
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      final pattern = _smallDigits[char] ?? _smallDigits[' ']!;
      
      for (var y = 0; y < charHeight; y++) {
        for (var x = 0; x < charWidth; x++) {
          if (pattern[y][x] == '1') {
            matrix.setPixel(xOffset + x, y, color);
          }
        }
      }
      xOffset += charWidth + charSpacing;
    }
    return matrix;
  }

  static PixelMatrix renderLargeText(String text, Color color) {
    final totalWidth = text.isEmpty 
        ? 1 
        : text.length * (largeCharWidth + largeCharSpacing) - largeCharSpacing;
    final matrix = PixelMatrix(width: totalWidth, height: largeCharHeight);

    var xOffset = 0;
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      final pattern = _largeDigits[char] ?? _largeDigits[' ']!;
      
      for (var y = 0; y < largeCharHeight; y++) {
        for (var x = 0; x < largeCharWidth; x++) {
          if (pattern[y][x] == '1') {
            matrix.setPixel(xOffset + x, y, color);
          }
        }
      }
      xOffset += largeCharWidth + largeCharSpacing;
    }
    return matrix;
  }

  static int getSmallTextWidth(String text) {
    if (text.isEmpty) return 0;
    return text.length * (charWidth + charSpacing) - charSpacing;
  }

  static int getLargeTextWidth(String text) {
    if (text.isEmpty) return 0;
    return text.length * (largeCharWidth + largeCharSpacing) - largeCharSpacing;
  }
}
