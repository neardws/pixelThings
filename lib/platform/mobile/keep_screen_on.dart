import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:pixel_things/platform/platform_utils.dart';

class KeepScreenOn {
  static Future<void> enable() async {
    if (PlatformUtils.isMobile) {
      await WakelockPlus.enable();
    }
  }

  static Future<void> disable() async {
    if (PlatformUtils.isMobile) {
      await WakelockPlus.disable();
    }
  }

  static Future<bool> isEnabled() async {
    if (PlatformUtils.isMobile) {
      return await WakelockPlus.enabled;
    }
    return false;
  }
}
