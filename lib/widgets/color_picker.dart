import 'dart:math';
import 'package:flutter/material.dart';

class HSVColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;
  final VoidCallback? onConfirm;

  const HSVColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
    this.onConfirm,
  });

  @override
  State<HSVColorPicker> createState() => _HSVColorPickerState();
}

class _HSVColorPickerState extends State<HSVColorPicker> {
  late HSVColor _currentHSV;

  @override
  void initState() {
    super.initState();
    _currentHSV = HSVColor.fromColor(widget.initialColor);
  }

  void _updateColor(HSVColor hsv) {
    setState(() => _currentHSV = hsv);
    widget.onColorChanged(hsv.toColor());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 色相环
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 色相环
                _HueRing(
                  hue: _currentHSV.hue,
                  onHueChanged: (hue) {
                    _updateColor(_currentHSV.withHue(hue));
                  },
                ),
                // 中心预览
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _currentHSV.toColor(),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: _currentHSV.toColor().withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 饱和度滑块
          _ColorSlider(
            label: 'Saturation',
            value: _currentHSV.saturation,
            gradient: LinearGradient(
              colors: [
                HSVColor.fromAHSV(1, _currentHSV.hue, 0, _currentHSV.value).toColor(),
                HSVColor.fromAHSV(1, _currentHSV.hue, 1, _currentHSV.value).toColor(),
              ],
            ),
            onChanged: (value) {
              _updateColor(_currentHSV.withSaturation(value));
            },
          ),
          const SizedBox(height: 12),
          // 明度滑块
          _ColorSlider(
            label: 'Brightness',
            value: _currentHSV.value,
            gradient: LinearGradient(
              colors: [
                HSVColor.fromAHSV(1, _currentHSV.hue, _currentHSV.saturation, 0).toColor(),
                HSVColor.fromAHSV(1, _currentHSV.hue, _currentHSV.saturation, 1).toColor(),
              ],
            ),
            onChanged: (value) {
              _updateColor(_currentHSV.withValue(value));
            },
          ),
          const SizedBox(height: 20),
          // 预设颜色
          _PresetColors(
            onColorSelected: (color) {
              _updateColor(HSVColor.fromColor(color));
            },
          ),
          const SizedBox(height: 16),
          // 颜色代码
          Text(
            '#${_currentHSV.toColor().value.toRadixString(16).substring(2).toUpperCase()}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
          if (widget.onConfirm != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentHSV.toColor(),
                foregroundColor: _currentHSV.value > 0.5 ? Colors.black : Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Apply'),
            ),
          ],
        ],
      ),
    );
  }
}

class _HueRing extends StatelessWidget {
  final double hue;
  final ValueChanged<double> onHueChanged;

  const _HueRing({
    required this.hue,
    required this.onHueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) => _handleTouch(details.localPosition, context),
      onPanUpdate: (details) => _handleTouch(details.localPosition, context),
      child: CustomPaint(
        size: const Size(200, 200),
        painter: _HueRingPainter(hue: hue),
      ),
    );
  }

  void _handleTouch(Offset position, BuildContext context) {
    final center = const Offset(100, 100);
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final distance = sqrt(dx * dx + dy * dy);

    // 只在环形区域响应
    if (distance >= 60 && distance <= 100) {
      var angle = atan2(dy, dx) * 180 / pi;
      if (angle < 0) angle += 360;
      onHueChanged(angle);
    }
  }
}

class _HueRingPainter extends CustomPainter {
  final double hue;

  _HueRingPainter({required this.hue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.6;

    // 绘制色相环
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = outerRadius - innerRadius;
    
    for (int i = 0; i < 360; i++) {
      paint.color = HSVColor.fromAHSV(1, i.toDouble(), 1, 1).toColor();
      final startAngle = (i - 90) * pi / 180;
      final sweepAngle = 1.5 * pi / 180;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: (outerRadius + innerRadius) / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    // 绘制指示器
    final indicatorAngle = (hue - 90) * pi / 180;
    final indicatorRadius = (outerRadius + innerRadius) / 2;
    final indicatorPos = Offset(
      center.dx + indicatorRadius * cos(indicatorAngle),
      center.dy + indicatorRadius * sin(indicatorAngle),
    );

    canvas.drawCircle(
      indicatorPos,
      12,
      Paint()..color = Colors.white..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      indicatorPos,
      10,
      Paint()..color = HSVColor.fromAHSV(1, hue, 1, 1).toColor()..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_HueRingPainter oldDelegate) => oldDelegate.hue != hue;
}

class _ColorSlider extends StatelessWidget {
  final String label;
  final double value;
  final Gradient gradient;
  final ValueChanged<double> onChanged;

  const _ColorSlider({
    required this.label,
    required this.value,
    required this.gradient,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onPanDown: (details) => _handleTouch(details, context),
          onPanUpdate: (details) => _handleTouch(details, context),
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Positioned(
                      left: value * constraints.maxWidth - 8,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _handleTouch(dynamic details, BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition as Offset);
    final newValue = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
    onChanged(newValue);
  }
}

class _PresetColors extends StatelessWidget {
  final ValueChanged<Color> onColorSelected;

  const _PresetColors({required this.onColorSelected});

  static const List<Color> _presets = [
    Color(0xFF00FF00), // Green
    Color(0xFF00AAFF), // Blue
    Color(0xFFFF6600), // Orange
    Color(0xFFFF00FF), // Pink
    Color(0xFFFFFFFF), // White
    Color(0xFFFFAA00), // Amber
    Color(0xFFFF0000), // Red
    Color(0xFF00FFFF), // Cyan
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _presets.map((color) {
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30, width: 2),
            ),
          ),
        );
      }).toList(),
    );
  }
}
