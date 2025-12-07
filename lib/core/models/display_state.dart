enum DisplayMode {
  clockOnly,
  clockWithInfo,
  effectWithClock,
}

class DisplayState {
  final DisplayMode mode;
  final double clockScale;
  final String infoText;

  const DisplayState({
    this.mode = DisplayMode.clockOnly,
    this.clockScale = 1.0,
    this.infoText = '',
  });

  DisplayState copyWith({
    DisplayMode? mode,
    double? clockScale,
    String? infoText,
  }) {
    return DisplayState(
      mode: mode ?? this.mode,
      clockScale: clockScale ?? this.clockScale,
      infoText: infoText ?? this.infoText,
    );
  }
}
