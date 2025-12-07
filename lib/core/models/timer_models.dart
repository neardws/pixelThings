import 'package:flutter/material.dart';

// ==================== 番茄钟 ====================

enum PomodoroState {
  idle,      // 空闲
  focus,     // 专注中
  shortBreak, // 短休息
  longBreak,  // 长休息
  paused,    // 暂停
}

class PomodoroSettings {
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int sessionsBeforeLongBreak;
  final bool autoStartBreak;
  final bool autoStartFocus;

  const PomodoroSettings({
    this.focusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsBeforeLongBreak = 4,
    this.autoStartBreak = true,
    this.autoStartFocus = false,
  });

  PomodoroSettings copyWith({
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? sessionsBeforeLongBreak,
    bool? autoStartBreak,
    bool? autoStartFocus,
  }) {
    return PomodoroSettings(
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      sessionsBeforeLongBreak: sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      autoStartBreak: autoStartBreak ?? this.autoStartBreak,
      autoStartFocus: autoStartFocus ?? this.autoStartFocus,
    );
  }
}

class PomodoroSession {
  final PomodoroState state;
  final int remainingSeconds;
  final int totalSeconds;
  final int completedSessions;
  final PomodoroSettings settings;

  const PomodoroSession({
    this.state = PomodoroState.idle,
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
    this.completedSessions = 0,
    this.settings = const PomodoroSettings(),
  });

  double get progress => totalSeconds > 0 ? 1 - (remainingSeconds / totalSeconds) : 0;
  
  String get timeDisplay {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get stateLabel {
    switch (state) {
      case PomodoroState.idle:
        return 'Ready';
      case PomodoroState.focus:
        return 'Focus';
      case PomodoroState.shortBreak:
        return 'Break';
      case PomodoroState.longBreak:
        return 'Long Break';
      case PomodoroState.paused:
        return 'Paused';
    }
  }

  Color get stateColor {
    switch (state) {
      case PomodoroState.idle:
        return const Color(0xFF888888);
      case PomodoroState.focus:
        return const Color(0xFFFF6B6B);
      case PomodoroState.shortBreak:
        return const Color(0xFF4ECDC4);
      case PomodoroState.longBreak:
        return const Color(0xFF45B7D1);
      case PomodoroState.paused:
        return const Color(0xFFFFD93D);
    }
  }

  PomodoroSession copyWith({
    PomodoroState? state,
    int? remainingSeconds,
    int? totalSeconds,
    int? completedSessions,
    PomodoroSettings? settings,
  }) {
    return PomodoroSession(
      state: state ?? this.state,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      completedSessions: completedSessions ?? this.completedSessions,
      settings: settings ?? this.settings,
    );
  }
}

// ==================== 倒计时器 ====================

class CountdownTimer {
  final String id;
  final String name;
  final DateTime targetDate;
  final Color color;
  final bool showDays;
  final bool showHours;
  final bool isActive;

  const CountdownTimer({
    required this.id,
    required this.name,
    required this.targetDate,
    this.color = const Color(0xFF00FF00),
    this.showDays = true,
    this.showHours = true,
    this.isActive = true,
  });

  Duration get remaining {
    final now = DateTime.now();
    if (targetDate.isBefore(now)) return Duration.zero;
    return targetDate.difference(now);
  }

  bool get isExpired => remaining == Duration.zero;

  String get displayString {
    final r = remaining;
    if (r == Duration.zero) return 'Expired';
    
    final days = r.inDays;
    final hours = r.inHours % 24;
    final minutes = r.inMinutes % 60;
    final seconds = r.inSeconds % 60;

    if (showDays && days > 0) {
      return '${days}d ${hours}h';
    } else if (showHours) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  CountdownTimer copyWith({
    String? id,
    String? name,
    DateTime? targetDate,
    Color? color,
    bool? showDays,
    bool? showHours,
    bool? isActive,
  }) {
    return CountdownTimer(
      id: id ?? this.id,
      name: name ?? this.name,
      targetDate: targetDate ?? this.targetDate,
      color: color ?? this.color,
      showDays: showDays ?? this.showDays,
      showHours: showHours ?? this.showHours,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetDate': targetDate.toIso8601String(),
      'color': color.value,
      'showDays': showDays,
      'showHours': showHours,
      'isActive': isActive,
    };
  }

  factory CountdownTimer.fromJson(Map<String, dynamic> json) {
    return CountdownTimer(
      id: json['id'],
      name: json['name'],
      targetDate: DateTime.parse(json['targetDate']),
      color: Color(json['color']),
      showDays: json['showDays'] ?? true,
      showHours: json['showHours'] ?? true,
      isActive: json['isActive'] ?? true,
    );
  }
}

// ==================== 闹钟 ====================

enum AlarmRepeat {
  once,
  daily,
  weekdays,
  weekends,
  custom,
}

class Alarm {
  final String id;
  final String name;
  final int hour;
  final int minute;
  final AlarmRepeat repeat;
  final List<int> customDays; // 1-7 for Mon-Sun
  final bool isEnabled;
  final String? soundId;

  const Alarm({
    required this.id,
    required this.name,
    required this.hour,
    required this.minute,
    this.repeat = AlarmRepeat.once,
    this.customDays = const [],
    this.isEnabled = true,
    this.soundId,
  });

  String get timeString {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String get repeatString {
    switch (repeat) {
      case AlarmRepeat.once:
        return 'Once';
      case AlarmRepeat.daily:
        return 'Daily';
      case AlarmRepeat.weekdays:
        return 'Weekdays';
      case AlarmRepeat.weekends:
        return 'Weekends';
      case AlarmRepeat.custom:
        return _customDaysString();
    }
  }

  String _customDaysString() {
    const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return customDays.map((d) => dayNames[d - 1]).join(' ');
  }

  DateTime? get nextTrigger {
    final now = DateTime.now();
    var candidate = DateTime(now.year, now.month, now.day, hour, minute);

    if (candidate.isBefore(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }

    switch (repeat) {
      case AlarmRepeat.once:
        return candidate.isAfter(now) ? candidate : null;
      case AlarmRepeat.daily:
        return candidate;
      case AlarmRepeat.weekdays:
        while (candidate.weekday > 5) {
          candidate = candidate.add(const Duration(days: 1));
        }
        return candidate;
      case AlarmRepeat.weekends:
        while (candidate.weekday < 6) {
          candidate = candidate.add(const Duration(days: 1));
        }
        return candidate;
      case AlarmRepeat.custom:
        if (customDays.isEmpty) return null;
        for (int i = 0; i < 7; i++) {
          if (customDays.contains(candidate.weekday)) {
            return candidate;
          }
          candidate = candidate.add(const Duration(days: 1));
        }
        return null;
    }
  }

  Alarm copyWith({
    String? id,
    String? name,
    int? hour,
    int? minute,
    AlarmRepeat? repeat,
    List<int>? customDays,
    bool? isEnabled,
    String? soundId,
  }) {
    return Alarm(
      id: id ?? this.id,
      name: name ?? this.name,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      repeat: repeat ?? this.repeat,
      customDays: customDays ?? this.customDays,
      isEnabled: isEnabled ?? this.isEnabled,
      soundId: soundId ?? this.soundId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hour': hour,
      'minute': minute,
      'repeat': repeat.index,
      'customDays': customDays,
      'isEnabled': isEnabled,
      'soundId': soundId,
    };
  }

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'],
      name: json['name'],
      hour: json['hour'],
      minute: json['minute'],
      repeat: AlarmRepeat.values[json['repeat'] ?? 0],
      customDays: List<int>.from(json['customDays'] ?? []),
      isEnabled: json['isEnabled'] ?? true,
      soundId: json['soundId'],
    );
  }
}
