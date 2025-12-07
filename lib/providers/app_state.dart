import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_things/core/models/pixel_matrix.dart';
import 'package:pixel_things/core/models/display_state.dart';
import 'package:pixel_things/core/models/clock_layout.dart';
import 'package:pixel_things/core/models/app_settings.dart';
import 'package:pixel_things/core/fonts/pixel_font.dart';
import 'package:pixel_things/core/utils/color_utils.dart';
import 'package:pixel_things/core/utils/date_utils.dart';
import 'package:pixel_things/plugins/plugin_manager.dart';
import 'package:pixel_things/plugins/plugin_interface.dart';

class AppState extends ChangeNotifier {
  final PluginManager _pluginManager = PluginManager();

  int _matrixWidth = 64;
  int _matrixHeight = 16;
  late PixelMatrix _matrix;
  DisplayState _displayState = const DisplayState();
  ClockLayout _clockLayout = const ClockLayout();
  bool _colonVisible = true;
  String _currentTime = '';
  String _currentSeconds = '';
  String _currentDate = '';
  int _dayOfWeek = 1;
  Timer? _timer;
  DateTime _lastUpdate = DateTime.now();

  // 日期显示设置
  DateDisplayMode _dateDisplayMode = DateDisplayMode.hidden;
  DateFormat _dateFormat = DateFormat.mmdd;
  bool _showWeekday = true;
  int _dateAlternateSeconds = 5;
  bool _showingDate = false; // 交替模式时：true=显示日期，false=显示时间
  int _alternateTimer = 0;

  // 动画相关
  double _layoutAnimationProgress = 0.0;
  ClockDisplayMode _targetLayoutMode = ClockDisplayMode.centered;
  static const _layoutAnimationDuration = 300; // ms

  AppState() {
    _matrix = PixelMatrix(width: _matrixWidth, height: _matrixHeight);
    _startClockUpdate();
  }

  PixelMatrix get matrix => _matrix;
  DisplayState get displayState => _displayState;
  ClockLayout get clockLayout => _clockLayout;
  String? get activePluginName => _pluginManager.getActivePluginName();
  List<PluginInfo> get availablePlugins => _pluginManager.getAvailablePlugins();
  String? get activePluginId => _pluginManager.activePluginId;
  DateDisplayMode get dateDisplayMode => _dateDisplayMode;
  bool get showingDate => _showingDate;

  void setDateDisplaySettings({
    DateDisplayMode? mode,
    DateFormat? format,
    bool? showWeekday,
    int? alternateSeconds,
  }) {
    if (mode != null) _dateDisplayMode = mode;
    if (format != null) _dateFormat = format;
    if (showWeekday != null) _showWeekday = showWeekday;
    if (alternateSeconds != null) _dateAlternateSeconds = alternateSeconds;
    notifyListeners();
  }

  void updateMatrixSize(int width, int height) {
    _matrixWidth = width;
    _matrixHeight = height;
    _matrix = PixelMatrix(width: width, height: height);
    _updateDisplay(0);
    notifyListeners();
  }

  void _startClockUpdate() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(milliseconds: _pluginManager.isPluginActive ? 33 : 500),
      (_) {
        final now = DateTime.now();
        final deltaTime = now.difference(_lastUpdate).inMilliseconds;
        _lastUpdate = now;

        _updateTime();
        _updateLayoutAnimation(deltaTime);
        _updateDisplay(deltaTime);

        if (!_pluginManager.isPluginActive) {
          _colonVisible = !_colonVisible;
        }
        notifyListeners();
      },
    );
  }

  void _updateLayoutAnimation(int deltaTime) {
    final targetProgress = _targetLayoutMode == ClockDisplayMode.miniTopLeft ? 1.0 : 0.0;
    
    if (_layoutAnimationProgress != targetProgress) {
      final step = deltaTime / _layoutAnimationDuration;
      
      if (_layoutAnimationProgress < targetProgress) {
        _layoutAnimationProgress = (_layoutAnimationProgress + step).clamp(0.0, 1.0);
      } else {
        _layoutAnimationProgress = (_layoutAnimationProgress - step).clamp(0.0, 1.0);
      }
      
      _clockLayout = _clockLayout.copyWith(
        animationProgress: _layoutAnimationProgress,
        mode: _layoutAnimationProgress > 0.5 ? ClockDisplayMode.miniTopLeft : ClockDisplayMode.centered,
        showSeconds: _layoutAnimationProgress < 0.5,
        showWeekIndicator: _layoutAnimationProgress < 0.5,
      );
    }
  }

  void _setTargetLayoutMode(ClockDisplayMode mode) {
    _targetLayoutMode = mode;
  }

  void _updateTime() {
    final now = DateTime.now();
    _currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    _currentSeconds = now.second.toString().padLeft(2, '0');
    _dayOfWeek = now.weekday;
    
    // 更新日期字符串
    _currentDate = DateFormatUtils.formatDateWithWeekday(
      now,
      _dateFormat,
      showWeekday: _showWeekday,
    );

    // 处理交替显示计时器
    if (_dateDisplayMode == DateDisplayMode.alternate) {
      _alternateTimer += _pluginManager.isPluginActive ? 33 : 500;
      if (_alternateTimer >= _dateAlternateSeconds * 1000) {
        _alternateTimer = 0;
        _showingDate = !_showingDate;
      }
    } else {
      _showingDate = false;
      _alternateTimer = 0;
    }
  }

  void _updateDisplay(int deltaTime) {
    _matrix.clear();

    switch (_displayState.mode) {
      case DisplayMode.clockOnly:
        _renderClockOnly();
        break;
      case DisplayMode.clockWithInfo:
        _renderClockOnly();
        break;
      case DisplayMode.effectWithClock:
        _renderEffectWithClock(deltaTime);
        break;
    }
  }

  void _renderClockOnly() {
    // 根据动画进度插值计算位置
    final progress = _clockLayout.animationProgress;
    
    // 判断是否显示日期（交替模式）
    final showDate = _dateDisplayMode == DateDisplayMode.alternate && _showingDate;
    
    // 大字体渲染参数 - 根据是否显示日期决定文本
    final displayText = showDate 
        ? _currentDate 
        : (_colonVisible ? _currentTime : _currentTime.replaceAll(':', ' '));
    final largeMatrix = PixelFont.renderLargeText(displayText, PixelColors.timeColor);
    final largeWidth = largeMatrix.width;
    final largeHeight = PixelFont.largeCharHeight;

    // 小字体渲染参数
    final smallMatrix = PixelFont.renderSmallText(_currentTime, PixelColors.timeColor);
    final smallWidth = smallMatrix.width;
    final smallHeight = PixelFont.charHeight;

    // 秒数参数 (仅在显示时间时有意义)
    final secondsMatrix = PixelFont.renderSmallText(_currentSeconds, PixelColors.secondsColor);
    final secondsWidth = secondsMatrix.width;

    // 居中模式位置 - 如果显示日期则不需要秒数宽度
    final effectiveSecondsWidth = showDate ? 0 : (2 + secondsWidth);
    final centeredTotalWidth = largeWidth + effectiveSecondsWidth;
    final centeredStartX = (_matrixWidth - centeredTotalWidth) ~/ 2;
    final centeredTimeY = (_matrixHeight - largeHeight - 3) ~/ 2;

    // 左上角模式位置
    const miniStartX = 2;
    const miniStartY = 1;

    // 插值计算当前位置
    final currentX = (centeredStartX * (1 - progress) + miniStartX * progress).round();
    final currentY = (centeredTimeY * (1 - progress) + miniStartY * progress).round();

    // 渲染时间 - 根据进度在大小字体间切换
    if (progress < 0.5) {
      // 使用大字体
      final opacity = 1.0 - progress * 2; // 0.5时完全透明
      for (var y = 0; y < largeHeight; y++) {
        for (var x = 0; x < largeWidth; x++) {
          final color = largeMatrix.getPixel(x, y);
          if (color.value != 0xFF000000 && color.opacity > 0) {
            final fadedColor = Color.fromRGBO(
              color.red, color.green, color.blue, 
              color.opacity * opacity,
            );
            _matrix.setPixel(currentX + x, currentY + y, fadedColor);
          }
        }
      }
      
      // 渲染秒数 (仅在大字体模式且不显示日期时)
      if (_clockLayout.showSeconds && !showDate) {
        final secondsX = currentX + largeWidth + 2;
        final secondsY = currentY + largeHeight - smallHeight;
        for (var y = 0; y < smallHeight; y++) {
          for (var x = 0; x < secondsWidth; x++) {
            final color = secondsMatrix.getPixel(x, y);
            if (color.value != 0xFF000000 && color.opacity > 0) {
              final fadedColor = Color.fromRGBO(
                color.red, color.green, color.blue,
                color.opacity * opacity,
              );
              _matrix.setPixel(secondsX + x, secondsY + y, fadedColor);
            }
          }
        }
      }

      // 渲染星期指示器 (仅在大字体模式)
      if (_clockLayout.showWeekIndicator) {
        _renderWeekIndicator(currentY + largeHeight + 2, opacity);
      }
    } else {
      // 使用小字体
      final opacity = (progress - 0.5) * 2; // 从0.5开始淡入
      for (var y = 0; y < smallHeight; y++) {
        for (var x = 0; x < smallWidth; x++) {
          final color = smallMatrix.getPixel(x, y);
          if (color.value != 0xFF000000 && color.opacity > 0) {
            final fadedColor = Color.fromRGBO(
              color.red, color.green, color.blue,
              color.opacity * opacity,
            );
            _matrix.setPixel(currentX + x, currentY + y, fadedColor);
          }
        }
      }
    }
  }

  void _renderWeekIndicator(int y, [double opacity = 1.0]) {
    const dotSpacing = 3;
    const totalWidth = 7 * dotSpacing - 1;
    final startX = (_matrixWidth - totalWidth) ~/ 2;

    for (var i = 0; i < 7; i++) {
      final baseColor = (i + 1 == _dayOfWeek) ? PixelColors.weekActive : PixelColors.weekInactive;
      final color = Color.fromRGBO(
        baseColor.red, baseColor.green, baseColor.blue,
        baseColor.opacity * opacity,
      );
      _matrix.setPixel(startX + i * dotSpacing, y, color);
    }
  }

  void _renderEffectWithClock(int deltaTime) {
    _pluginManager.updateActivePlugin(_matrix, deltaTime);
    _renderClockOverlay();
  }

  void _renderClockOverlay() {
    final timeText = _currentTime;
    final timeMatrix = PixelFont.renderSmallText(timeText, PixelColors.timeColor);

    const startX = 2;
    const startY = 1;

    // Draw outline (black background for text)
    for (var y = 0; y < PixelFont.charHeight; y++) {
      for (var x = 0; x < timeMatrix.width; x++) {
        final color = timeMatrix.getPixel(x, y);
        if (color.value != 0xFF000000 && color.opacity > 0) {
          // Draw black outline
          for (var dy = -1; dy <= 1; dy++) {
            for (var dx = -1; dx <= 1; dx++) {
              if (dx == 0 && dy == 0) continue;
              final px = startX + x + dx;
              final py = startY + y + dy;
              if (px >= 0 && px < _matrixWidth && py >= 0 && py < _matrixHeight) {
                _matrix.setPixel(px, py, const Color(0xFF000000));
              }
            }
          }
        }
      }
    }

    // Draw text
    for (var y = 0; y < PixelFont.charHeight; y++) {
      for (var x = 0; x < timeMatrix.width; x++) {
        final color = timeMatrix.getPixel(x, y);
        if (color.value != 0xFF000000 && color.opacity > 0) {
          _matrix.setPixel(startX + x, startY + y, color);
        }
      }
    }
  }

  void setDisplayMode(DisplayMode mode) {
    _displayState = _displayState.copyWith(mode: mode);
    if (mode != DisplayMode.effectWithClock) {
      _pluginManager.deactivatePlugin();
    }
    _restartTimer();
    notifyListeners();
  }

  void activatePlugin(String pluginId) {
    _pluginManager.activatePlugin(pluginId);
    _displayState = _displayState.copyWith(mode: DisplayMode.effectWithClock);
    _setTargetLayoutMode(ClockDisplayMode.miniTopLeft); // 触发缩小动画
    _restartTimer();
    notifyListeners();
  }

  void deactivatePlugin() {
    _pluginManager.deactivatePlugin();
    _displayState = _displayState.copyWith(mode: DisplayMode.clockOnly);
    _setTargetLayoutMode(ClockDisplayMode.centered); // 触发放大动画
    _restartTimer();
    notifyListeners();
  }

  void cycleNextEffect() {
    if (!_pluginManager.isPluginActive) {
      final plugins = _pluginManager.getAvailablePlugins();
      if (plugins.isNotEmpty) {
        activatePlugin(plugins.first.id);
      }
    } else {
      _pluginManager.cycleNextPlugin();
    }
    _displayState = _displayState.copyWith(mode: DisplayMode.effectWithClock);
    _setTargetLayoutMode(ClockDisplayMode.miniTopLeft);
    _restartTimer();
    notifyListeners();
  }

  void toggleEffect() {
    if (_pluginManager.isPluginActive) {
      deactivatePlugin();
    } else {
      cycleNextEffect();
    }
  }

  void _restartTimer() {
    _startClockUpdate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final appStateProvider = ChangeNotifierProvider((ref) => AppState());
