import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:pixel_things/platform/platform_utils.dart';
import 'package:pixel_things/platform/desktop/window_handler.dart';

class SystemTrayHandler with TrayListener {
  static SystemTrayHandler? _instance;
  static SystemTrayHandler get instance => _instance ??= SystemTrayHandler._();

  SystemTrayHandler._();

  bool _initialized = false;
  
  void Function()? onShowWindow;
  void Function()? onOpenSettings;
  void Function()? onToggleScreensaver;
  void Function()? onExit;

  Future<void> initialize({
    void Function()? onShowWindow,
    void Function()? onOpenSettings,
    void Function()? onToggleScreensaver,
    void Function()? onExit,
  }) async {
    if (!PlatformUtils.isDesktop || _initialized) return;

    this.onShowWindow = onShowWindow;
    this.onOpenSettings = onOpenSettings;
    this.onToggleScreensaver = onToggleScreensaver;
    this.onExit = onExit;

    trayManager.addListener(this);

    String iconPath;
    if (Platform.isWindows) {
      iconPath = 'assets/icons/app_icon.ico';
    } else if (Platform.isMacOS) {
      iconPath = 'assets/icons/app_icon.png';
    } else {
      iconPath = 'assets/icons/app_icon.png';
    }

    try {
      await trayManager.setIcon(iconPath);
      await _updateContextMenu();
      _initialized = true;
    } catch (e) {
      debugPrint('Failed to initialize system tray: $e');
    }
  }

  Future<void> _updateContextMenu() async {
    final menu = Menu(
      items: [
        MenuItem(
          key: 'show',
          label: 'Show Window',
        ),
        MenuItem(
          key: 'settings',
          label: 'Settings',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'screensaver',
          label: 'Start Screensaver',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit',
          label: 'Exit',
        ),
      ],
    );

    await trayManager.setContextMenu(menu);
  }

  Future<void> setTooltip(String tooltip) async {
    if (!PlatformUtils.isDesktop) return;
    await trayManager.setToolTip(tooltip);
  }

  @override
  void onTrayIconMouseDown() {
    onShowWindow?.call();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show':
        onShowWindow?.call();
        break;
      case 'settings':
        onOpenSettings?.call();
        break;
      case 'screensaver':
        onToggleScreensaver?.call();
        break;
      case 'exit':
        onExit?.call();
        break;
    }
  }

  void dispose() {
    trayManager.removeListener(this);
    trayManager.destroy();
  }
}
