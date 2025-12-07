import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_things/app.dart';
import 'package:pixel_things/platform/platform_utils.dart';
import 'package:pixel_things/platform/desktop/window_handler.dart';
import 'package:pixel_things/platform/desktop/screensaver_handler.dart';
import 'package:pixel_things/platform/desktop/launch_at_startup_handler.dart';
import 'package:pixel_things/platform/mobile/keep_screen_on.dart';
import 'package:pixel_things/platform/storage_service.dart';
import 'package:pixel_things/core/models/app_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化存储服务并加载设置
  await StorageService.initialize();
  final settings = await StorageService.loadSettings();

  if (PlatformUtils.isMobile) {
    await _initMobile();
  }

  if (PlatformUtils.isDesktop) {
    await _initDesktop(settings);
  }

  runApp(const ProviderScope(child: PixelThingsApp()));
}

Future<void> _initMobile() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await KeepScreenOn.enable();
}

Future<void> _initDesktop(AppSettings settings) async {
  await WindowHandler.instance.initialize(
    title: 'Pixel Things',
    size: const Size(800, 400),
    minimumSize: const Size(400, 200),
  );

  ScreensaverHandler.instance.initialize(
    idleTimeout: Duration(minutes: settings.screensaverTimeoutMin),
    onActivate: () {
      WindowHandler.instance.setMode(WindowMode.screensaver);
    },
    onDeactivate: () {
      WindowHandler.instance.setMode(WindowMode.normal);
    },
  );

  ScreensaverHandler.instance.setEnabled(settings.screensaverEnabled);

  await LaunchAtStartupHandler.initialize();
  if (settings.launchAtStartup) {
    await LaunchAtStartupHandler.setEnabled(true);
  }
}
