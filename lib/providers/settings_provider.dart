import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_things/core/models/app_settings.dart';
import 'package:pixel_things/platform/storage_service.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    state = await StorageService.loadSettings();
    _initialized = true;
  }

  Future<void> _save() async {
    await StorageService.saveSettings(state);
  }

  // 显示设置
  Future<void> setMatrixRows(int rows) async {
    state = state.copyWith(matrixRows: rows);
    await _save();
  }

  Future<void> setPixelGap(double gap) async {
    state = state.copyWith(pixelGap: gap);
    await _save();
  }

  Future<void> setShowSeconds(bool show) async {
    state = state.copyWith(showSeconds: show);
    await _save();
  }

  Future<void> setColonBlink(bool blink) async {
    state = state.copyWith(colonBlink: blink);
    await _save();
  }

  // 主题和颜色设置
  Future<void> setTheme(String themeId) async {
    state = state.copyWith(themeId: themeId);
    await _save();
  }

  Future<void> setTimeColor(int colorHex) async {
    state = state.copyWith(timeColorHex: colorHex);
    await _save();
  }

  Future<void> setSecondsColor(int colorHex) async {
    state = state.copyWith(secondsColorHex: colorHex);
    await _save();
  }

  // 效果设置
  Future<void> setLastActivePlugin(String? pluginId) async {
    state = state.copyWith(lastActivePluginId: pluginId);
    await _save();
  }

  Future<void> setAutoStartEffect(bool autoStart) async {
    state = state.copyWith(autoStartEffect: autoStart);
    await _save();
  }

  // 日期显示设置
  Future<void> setDateDisplayMode(DateDisplayMode mode) async {
    state = state.copyWith(dateDisplayMode: mode);
    await _save();
  }

  Future<void> setDateFormat(DateFormat format) async {
    state = state.copyWith(dateFormat: format);
    await _save();
  }

  Future<void> setShowWeekday(bool show) async {
    state = state.copyWith(showWeekday: show);
    await _save();
  }

  Future<void> setDateAlternateSeconds(int seconds) async {
    state = state.copyWith(dateAlternateSeconds: seconds);
    await _save();
  }

  // 屏保设置
  Future<void> setScreensaverEnabled(bool enabled) async {
    state = state.copyWith(screensaverEnabled: enabled);
    await _save();
  }

  Future<void> setScreensaverTimeout(int minutes) async {
    state = state.copyWith(screensaverTimeoutMin: minutes);
    await _save();
  }

  Future<void> setLaunchAtStartup(bool enabled) async {
    state = state.copyWith(launchAtStartup: enabled);
    await _save();
  }

  Future<void> setMinimizeToTray(bool enabled) async {
    state = state.copyWith(minimizeToTray: enabled);
    await _save();
  }

  Future<void> setStartMinimized(bool enabled) async {
    state = state.copyWith(startMinimized: enabled);
    await _save();
  }

  // 批量更新
  Future<void> updateSettings(AppSettings Function(AppSettings) updater) async {
    state = updater(state);
    await _save();
  }

  // 重置为默认
  Future<void> resetToDefaults() async {
    state = const AppSettings();
    await _save();
  }
}
