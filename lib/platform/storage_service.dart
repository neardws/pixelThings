import 'package:shared_preferences/shared_preferences.dart';
import 'package:pixel_things/core/models/app_settings.dart';

class StorageService {
  static const String _settingsKey = 'app_settings';
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<AppSettings> loadSettings() async {
    if (_prefs == null) await initialize();

    final jsonString = _prefs?.getString(_settingsKey);
    if (jsonString == null) {
      return const AppSettings();
    }

    try {
      return AppSettings.fromJsonString(jsonString);
    } catch (e) {
      return const AppSettings();
    }
  }

  static Future<void> saveSettings(AppSettings settings) async {
    if (_prefs == null) await initialize();
    await _prefs?.setString(_settingsKey, settings.toJsonString());
  }

  static Future<void> clearSettings() async {
    if (_prefs == null) await initialize();
    await _prefs?.remove(_settingsKey);
  }

  // 便捷方法：保存单个设置项
  static Future<void> updateSetting<T>(
    AppSettings current,
    AppSettings Function(AppSettings) updater,
  ) async {
    final updated = updater(current);
    await saveSettings(updated);
  }
}
