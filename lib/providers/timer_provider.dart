import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pixel_things/core/models/timer_models.dart';

// ==================== 番茄钟 Provider ====================

class PomodoroNotifier extends StateNotifier<PomodoroSession> {
  Timer? _timer;

  PomodoroNotifier() : super(const PomodoroSession());

  void updateSettings(PomodoroSettings settings) {
    state = state.copyWith(settings: settings);
  }

  void startFocus() {
    _stopTimer();
    final seconds = state.settings.focusMinutes * 60;
    state = state.copyWith(
      state: PomodoroState.focus,
      remainingSeconds: seconds,
      totalSeconds: seconds,
    );
    _startTimer();
  }

  void startShortBreak() {
    _stopTimer();
    final seconds = state.settings.shortBreakMinutes * 60;
    state = state.copyWith(
      state: PomodoroState.shortBreak,
      remainingSeconds: seconds,
      totalSeconds: seconds,
    );
    _startTimer();
  }

  void startLongBreak() {
    _stopTimer();
    final seconds = state.settings.longBreakMinutes * 60;
    state = state.copyWith(
      state: PomodoroState.longBreak,
      remainingSeconds: seconds,
      totalSeconds: seconds,
    );
    _startTimer();
  }

  void pause() {
    if (state.state == PomodoroState.focus ||
        state.state == PomodoroState.shortBreak ||
        state.state == PomodoroState.longBreak) {
      _stopTimer();
      state = state.copyWith(state: PomodoroState.paused);
    }
  }

  void resume() {
    if (state.state == PomodoroState.paused && state.remainingSeconds > 0) {
      // 恢复到之前的状态
      state = state.copyWith(state: PomodoroState.focus);
      _startTimer();
    }
  }

  void stop() {
    _stopTimer();
    state = state.copyWith(
      state: PomodoroState.idle,
      remainingSeconds: 0,
      totalSeconds: 0,
    );
  }

  void skip() {
    _onTimerComplete();
  }

  void reset() {
    _stopTimer();
    state = const PomodoroSession();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _onTimerComplete();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _onTimerComplete() {
    _stopTimer();

    switch (state.state) {
      case PomodoroState.focus:
        final newCompleted = state.completedSessions + 1;
        state = state.copyWith(completedSessions: newCompleted);

        // 判断是短休息还是长休息
        if (newCompleted % state.settings.sessionsBeforeLongBreak == 0) {
          if (state.settings.autoStartBreak) {
            startLongBreak();
          } else {
            state = state.copyWith(state: PomodoroState.idle);
          }
        } else {
          if (state.settings.autoStartBreak) {
            startShortBreak();
          } else {
            state = state.copyWith(state: PomodoroState.idle);
          }
        }
        break;

      case PomodoroState.shortBreak:
      case PomodoroState.longBreak:
        if (state.settings.autoStartFocus) {
          startFocus();
        } else {
          state = state.copyWith(state: PomodoroState.idle);
        }
        break;

      default:
        break;
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

final pomodoroProvider = StateNotifierProvider<PomodoroNotifier, PomodoroSession>((ref) {
  return PomodoroNotifier();
});

// ==================== 倒计时 Provider ====================

class CountdownNotifier extends StateNotifier<List<CountdownTimer>> {
  static const String _storageKey = 'countdown_timers';

  CountdownNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        state = jsonList.map((json) => CountdownTimer.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load countdowns: $e');
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.map((t) => t.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('Failed to save countdowns: $e');
    }
  }

  void addTimer(CountdownTimer timer) {
    state = [...state, timer];
    _save();
  }

  void updateTimer(CountdownTimer timer) {
    state = state.map((t) => t.id == timer.id ? timer : t).toList();
    _save();
  }

  void removeTimer(String id) {
    state = state.where((t) => t.id != id).toList();
    _save();
  }

  void toggleTimer(String id) {
    state = state.map((t) {
      if (t.id == id) {
        return t.copyWith(isActive: !t.isActive);
      }
      return t;
    }).toList();
    _save();
  }

  CountdownTimer? getActiveTimer() {
    final active = state.where((t) => t.isActive && !t.isExpired).toList();
    if (active.isEmpty) return null;
    active.sort((a, b) => a.remaining.compareTo(b.remaining));
    return active.first;
  }
}

final countdownProvider = StateNotifierProvider<CountdownNotifier, List<CountdownTimer>>((ref) {
  return CountdownNotifier();
});

// ==================== 闹钟 Provider ====================

class AlarmNotifier extends StateNotifier<List<Alarm>> {
  static const String _storageKey = 'alarms';
  Timer? _checkTimer;

  AlarmNotifier() : super([]) {
    _load();
    _startChecking();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        state = jsonList.map((json) => Alarm.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load alarms: $e');
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.map((a) => a.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('Failed to save alarms: $e');
    }
  }

  void _startChecking() {
    _checkTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkAlarms();
    });
  }

  void _checkAlarms() {
    final now = DateTime.now();
    for (final alarm in state) {
      if (!alarm.isEnabled) continue;
      
      final next = alarm.nextTrigger;
      if (next == null) continue;

      // 检查是否在当前分钟内
      if (next.hour == now.hour && 
          next.minute == now.minute &&
          next.day == now.day &&
          next.month == now.month &&
          next.year == now.year &&
          now.second == 0) {
        _triggerAlarm(alarm);
      }
    }
  }

  void _triggerAlarm(Alarm alarm) {
    // 触发闹钟通知 - 这里可以集成本地通知
    debugPrint('Alarm triggered: ${alarm.name}');
    
    // 如果是一次性闹钟，禁用它
    if (alarm.repeat == AlarmRepeat.once) {
      toggleAlarm(alarm.id);
    }
  }

  void addAlarm(Alarm alarm) {
    state = [...state, alarm];
    _save();
  }

  void updateAlarm(Alarm alarm) {
    state = state.map((a) => a.id == alarm.id ? alarm : a).toList();
    _save();
  }

  void removeAlarm(String id) {
    state = state.where((a) => a.id != id).toList();
    _save();
  }

  void toggleAlarm(String id) {
    state = state.map((a) {
      if (a.id == id) {
        return a.copyWith(isEnabled: !a.isEnabled);
      }
      return a;
    }).toList();
    _save();
  }

  Alarm? getNextAlarm() {
    final enabled = state.where((a) => a.isEnabled).toList();
    if (enabled.isEmpty) return null;

    Alarm? nearest;
    Duration? nearestDuration;

    for (final alarm in enabled) {
      final next = alarm.nextTrigger;
      if (next == null) continue;

      final duration = next.difference(DateTime.now());
      if (nearestDuration == null || duration < nearestDuration) {
        nearest = alarm;
        nearestDuration = duration;
      }
    }

    return nearest;
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }
}

final alarmProvider = StateNotifierProvider<AlarmNotifier, List<Alarm>>((ref) {
  return AlarmNotifier();
});
