import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:pixel_things/platform/platform_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LaunchAtStartupHandler {
  static const String _prefKey = 'launch_at_startup';

  static Future<void> initialize() async {
    if (!PlatformUtils.isDesktop) return;

    launchAtStartup.setup(
      appName: 'Pixel Things',
      appPath: '', // Will be auto-detected
    );
  }

  static Future<bool> isEnabled() async {
    if (!PlatformUtils.isDesktop) return false;
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  static Future<void> setEnabled(bool enabled) async {
    if (!PlatformUtils.isDesktop) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);

    if (enabled) {
      await launchAtStartup.enable();
    } else {
      await launchAtStartup.disable();
    }
  }

  static Future<void> toggle() async {
    final current = await isEnabled();
    await setEnabled(!current);
  }
}
