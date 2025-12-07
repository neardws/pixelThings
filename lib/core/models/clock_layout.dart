enum ClockDisplayMode {
  centered,    // 居中大显示 (默认，无效果时)
  miniTopLeft, // 左上角小显示 (有效果时)
}

class ClockLayout {
  final ClockDisplayMode mode;
  final bool showSeconds;
  final bool showWeekIndicator;
  final double animationProgress; // 0.0 = centered, 1.0 = miniTopLeft

  const ClockLayout({
    this.mode = ClockDisplayMode.centered,
    this.showSeconds = true,
    this.showWeekIndicator = true,
    this.animationProgress = 0.0,
  });

  ClockLayout copyWith({
    ClockDisplayMode? mode,
    bool? showSeconds,
    bool? showWeekIndicator,
    double? animationProgress,
  }) {
    return ClockLayout(
      mode: mode ?? this.mode,
      showSeconds: showSeconds ?? this.showSeconds,
      showWeekIndicator: showWeekIndicator ?? this.showWeekIndicator,
      animationProgress: animationProgress ?? this.animationProgress,
    );
  }

  // 是否使用大字体
  bool get useLargeFont => mode == ClockDisplayMode.centered;

  // 时钟起始位置 (像素坐标)
  int getStartX(int matrixWidth, int timeWidth) {
    if (mode == ClockDisplayMode.centered) {
      return (matrixWidth - timeWidth) ~/ 2;
    } else {
      return 2; // 左上角固定位置
    }
  }

  int getStartY(int matrixHeight, int timeHeight) {
    if (mode == ClockDisplayMode.centered) {
      return (matrixHeight - timeHeight - 3) ~/ 2;
    } else {
      return 1; // 左上角固定位置
    }
  }
}
