import 'dart:ui';
import 'package:window_manager/window_manager.dart';
import 'package:pixel_things/platform/platform_utils.dart';

enum WindowMode {
  normal,
  fullscreen,
  alwaysOnTop,
  minimized,
  screensaver,
}

class WindowHandler with WindowListener {
  static WindowHandler? _instance;
  static WindowHandler get instance => _instance ??= WindowHandler._();

  WindowHandler._();

  WindowMode _currentMode = WindowMode.normal;
  WindowMode get currentMode => _currentMode;

  bool _initialized = false;
  
  void Function()? onWindowClose;
  void Function()? onWindowFocus;
  void Function()? onWindowBlur;

  Future<void> initialize({
    String title = 'Pixel Things',
    Size size = const Size(800, 400),
    Size minimumSize = const Size(400, 200),
    bool center = true,
    void Function()? onClose,
    void Function()? onFocus,
    void Function()? onBlur,
  }) async {
    if (!PlatformUtils.isDesktop || _initialized) return;

    onWindowClose = onClose;
    onWindowFocus = onFocus;
    onWindowBlur = onBlur;

    await windowManager.ensureInitialized();

    WindowOptions windowOptions = WindowOptions(
      size: size,
      minimumSize: minimumSize,
      center: center,
      backgroundColor: const Color(0xFF000000),
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: title,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    windowManager.addListener(this);
    _initialized = true;
  }

  Future<void> setMode(WindowMode mode) async {
    if (!PlatformUtils.isDesktop) return;
    
    _currentMode = mode;
    
    switch (mode) {
      case WindowMode.normal:
        await windowManager.setFullScreen(false);
        await windowManager.setAlwaysOnTop(false);
        await windowManager.setSkipTaskbar(false);
        break;
      case WindowMode.fullscreen:
        await windowManager.setFullScreen(true);
        break;
      case WindowMode.alwaysOnTop:
        await windowManager.setFullScreen(false);
        await windowManager.setAlwaysOnTop(true);
        break;
      case WindowMode.minimized:
        await windowManager.minimize();
        break;
      case WindowMode.screensaver:
        await windowManager.setFullScreen(true);
        await windowManager.setAlwaysOnTop(true);
        break;
    }
  }

  Future<void> toggleFullscreen() async {
    if (!PlatformUtils.isDesktop) return;
    
    if (_currentMode == WindowMode.fullscreen) {
      await setMode(WindowMode.normal);
    } else {
      await setMode(WindowMode.fullscreen);
    }
  }

  Future<void> show() async {
    if (!PlatformUtils.isDesktop) return;
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> hide() async {
    if (!PlatformUtils.isDesktop) return;
    await windowManager.hide();
  }

  Future<void> minimize() async {
    if (!PlatformUtils.isDesktop) return;
    await windowManager.minimize();
  }

  Future<void> close() async {
    if (!PlatformUtils.isDesktop) return;
    await windowManager.close();
  }

  Future<void> setSize(double width, double height) async {
    if (!PlatformUtils.isDesktop) return;
    await windowManager.setSize(Size(width, height));
  }

  Future<void> center() async {
    if (!PlatformUtils.isDesktop) return;
    await windowManager.center();
  }

  Future<void> setTitle(String title) async {
    if (!PlatformUtils.isDesktop) return;
    await windowManager.setTitle(title);
  }

  Future<bool> isFullScreen() async {
    if (!PlatformUtils.isDesktop) return false;
    return await windowManager.isFullScreen();
  }

  @override
  void onWindowClose() {
    onWindowClose?.call();
  }

  @override
  void onWindowFocus() {
    onWindowFocus?.call();
  }

  @override
  void onWindowBlur() {
    onWindowBlur?.call();
  }

  void dispose() {
    windowManager.removeListener(this);
  }
}
