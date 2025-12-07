import 'dart:convert';

enum DateDisplayMode {
  hidden,     // 仅时间
  alternate,  // 时间/日期交替显示
  combined,   // 时间和日期同时显示
}

enum DateFormat {
  mmdd,       // MM/DD
  ddmm,       // DD/MM
  mmddDash,   // MM-DD
  ddmmDot,    // DD.MM
}

class AppSettings {
  // 显示设置
  final int matrixRows;
  final double pixelGap;
  final bool showSeconds;
  final bool colonBlink;

  // 主题和颜色设置
  final String themeId;
  final int timeColorHex;
  final int secondsColorHex;

  // 日期显示设置
  final DateDisplayMode dateDisplayMode;
  final DateFormat dateFormat;
  final bool showWeekday;
  final int dateAlternateSeconds; // 交替显示间隔秒数

  // 效果设置
  final String? lastActivePluginId;
  final bool autoStartEffect;

  // 屏保设置 (桌面端)
  final bool screensaverEnabled;
  final int screensaverTimeoutMin;
  final bool launchAtStartup;
  final bool minimizeToTray;
  final bool startMinimized;

  // 语言设置
  final String languageCode; // 'en', 'zh', 'system'

  const AppSettings({
    this.matrixRows = 16,
    this.pixelGap = 2.0,
    this.showSeconds = true,
    this.colonBlink = true,
    this.themeId = 'matrix_green',
    this.timeColorHex = 0xFF00FF00,
    this.secondsColorHex = 0xFF00CC00,
    this.dateDisplayMode = DateDisplayMode.hidden,
    this.dateFormat = DateFormat.mmdd,
    this.showWeekday = true,
    this.dateAlternateSeconds = 5,
    this.lastActivePluginId,
    this.autoStartEffect = false,
    this.screensaverEnabled = true,
    this.screensaverTimeoutMin = 5,
    this.launchAtStartup = false,
    this.minimizeToTray = true,
    this.startMinimized = false,
    this.languageCode = 'system',
  });

  AppSettings copyWith({
    int? matrixRows,
    double? pixelGap,
    bool? showSeconds,
    bool? colonBlink,
    String? themeId,
    int? timeColorHex,
    int? secondsColorHex,
    DateDisplayMode? dateDisplayMode,
    DateFormat? dateFormat,
    bool? showWeekday,
    int? dateAlternateSeconds,
    String? lastActivePluginId,
    bool? autoStartEffect,
    bool? screensaverEnabled,
    int? screensaverTimeoutMin,
    bool? launchAtStartup,
    bool? minimizeToTray,
    bool? startMinimized,
    String? languageCode,
  }) {
    return AppSettings(
      matrixRows: matrixRows ?? this.matrixRows,
      pixelGap: pixelGap ?? this.pixelGap,
      showSeconds: showSeconds ?? this.showSeconds,
      colonBlink: colonBlink ?? this.colonBlink,
      themeId: themeId ?? this.themeId,
      timeColorHex: timeColorHex ?? this.timeColorHex,
      secondsColorHex: secondsColorHex ?? this.secondsColorHex,
      dateDisplayMode: dateDisplayMode ?? this.dateDisplayMode,
      dateFormat: dateFormat ?? this.dateFormat,
      showWeekday: showWeekday ?? this.showWeekday,
      dateAlternateSeconds: dateAlternateSeconds ?? this.dateAlternateSeconds,
      lastActivePluginId: lastActivePluginId ?? this.lastActivePluginId,
      autoStartEffect: autoStartEffect ?? this.autoStartEffect,
      screensaverEnabled: screensaverEnabled ?? this.screensaverEnabled,
      screensaverTimeoutMin: screensaverTimeoutMin ?? this.screensaverTimeoutMin,
      launchAtStartup: launchAtStartup ?? this.launchAtStartup,
      minimizeToTray: minimizeToTray ?? this.minimizeToTray,
      startMinimized: startMinimized ?? this.startMinimized,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matrixRows': matrixRows,
      'pixelGap': pixelGap,
      'showSeconds': showSeconds,
      'colonBlink': colonBlink,
      'themeId': themeId,
      'timeColorHex': timeColorHex,
      'secondsColorHex': secondsColorHex,
      'dateDisplayMode': dateDisplayMode.index,
      'dateFormat': dateFormat.index,
      'showWeekday': showWeekday,
      'dateAlternateSeconds': dateAlternateSeconds,
      'lastActivePluginId': lastActivePluginId,
      'autoStartEffect': autoStartEffect,
      'screensaverEnabled': screensaverEnabled,
      'screensaverTimeoutMin': screensaverTimeoutMin,
      'launchAtStartup': launchAtStartup,
      'minimizeToTray': minimizeToTray,
      'startMinimized': startMinimized,
      'languageCode': languageCode,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      matrixRows: json['matrixRows'] ?? 16,
      pixelGap: (json['pixelGap'] ?? 2.0).toDouble(),
      showSeconds: json['showSeconds'] ?? true,
      colonBlink: json['colonBlink'] ?? true,
      themeId: json['themeId'] ?? 'matrix_green',
      timeColorHex: json['timeColorHex'] ?? 0xFF00FF00,
      secondsColorHex: json['secondsColorHex'] ?? 0xFF00CC00,
      dateDisplayMode: DateDisplayMode.values[json['dateDisplayMode'] ?? 0],
      dateFormat: DateFormat.values[json['dateFormat'] ?? 0],
      showWeekday: json['showWeekday'] ?? true,
      dateAlternateSeconds: json['dateAlternateSeconds'] ?? 5,
      lastActivePluginId: json['lastActivePluginId'],
      autoStartEffect: json['autoStartEffect'] ?? false,
      screensaverEnabled: json['screensaverEnabled'] ?? true,
      screensaverTimeoutMin: json['screensaverTimeoutMin'] ?? 5,
      launchAtStartup: json['launchAtStartup'] ?? false,
      minimizeToTray: json['minimizeToTray'] ?? true,
      startMinimized: json['startMinimized'] ?? false,
      languageCode: json['languageCode'] ?? 'system',
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory AppSettings.fromJsonString(String jsonString) {
    return AppSettings.fromJson(jsonDecode(jsonString));
  }
}
