import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_things/providers/app_state.dart';
import 'package:pixel_things/widgets/pixel_canvas.dart';
import 'package:pixel_things/screens/settings_screen.dart';
import 'package:pixel_things/core/utils/color_utils.dart';
import 'package:pixel_things/platform/platform_utils.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    _initPlatform();
  }

  Future<void> _initPlatform() async {
    if (PlatformUtils.isMobile) {
      // Keep screen on for mobile
      // wakelock_plus will be used here
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);

    return Scaffold(
      backgroundColor: PixelColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          _updateMatrixSize(constraints, appState);

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showSettings
                ? SettingsScreen(
                    key: const ValueKey('settings'),
                    onBack: () => setState(() => _showSettings = false),
                  )
                : _buildMainContent(appState),
          );
        },
      ),
    );
  }

  void _updateMatrixSize(BoxConstraints constraints, AppState appState) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = constraints.maxWidth;
      final screenHeight = constraints.maxHeight;

      const targetRowHeight = 50.0;
      final rows = (screenHeight / targetRowHeight).clamp(8, 24).toInt();
      final pixelSize = screenHeight / rows;
      final cols = (screenWidth / pixelSize).clamp(32, 128).toInt();

      if (appState.matrix.width != cols || appState.matrix.height != rows) {
        appState.updateMatrixSize(cols, rows);
      }
    });
  }

  Widget _buildMainContent(AppState appState) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () => appState.cycleNextEffect(),
        onDoubleTap: () => appState.deactivatePlugin(),
        onLongPress: () => setState(() => _showSettings = true),
        child: Stack(
          children: [
            PixelCanvas(
              matrix: appState.matrix,
              pixelGap: 2.0,
            ),
            if (appState.activePluginName != null)
              Positioned(
                right: 16,
                bottom: 16,
                child: Text(
                  appState.activePluginName!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ),
            if (PlatformUtils.isDesktop)
              Positioned(
                left: 16,
                bottom: 16,
                child: Text(
                  'Space: Toggle Effect | Esc: Clock Only | S: Settings',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final appState = ref.read(appStateProvider);

      switch (event.logicalKey) {
        case LogicalKeyboardKey.space:
          appState.cycleNextEffect();
          break;
        case LogicalKeyboardKey.escape:
          if (_showSettings) {
            setState(() => _showSettings = false);
          } else {
            appState.deactivatePlugin();
          }
          break;
        case LogicalKeyboardKey.keyS:
          setState(() => _showSettings = !_showSettings);
          break;
        case LogicalKeyboardKey.arrowRight:
          appState.cycleNextEffect();
          break;
        case LogicalKeyboardKey.arrowLeft:
          // Could add previous effect here
          break;
        default:
          break;
      }
    }
  }
}
