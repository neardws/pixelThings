import 'dart:async';
import 'package:flutter/services.dart';
import 'package:pixel_things/platform/platform_utils.dart';

enum ScreensaverState {
  inactive,
  active,
  disabled,
}

class ScreensaverHandler {
  static ScreensaverHandler? _instance;
  static ScreensaverHandler get instance => _instance ??= ScreensaverHandler._();

  ScreensaverHandler._();

  Timer? _idleTimer;
  DateTime _lastActivity = DateTime.now();
  ScreensaverState _state = ScreensaverState.inactive;
  Duration _idleTimeout = const Duration(minutes: 5);
  
  final _stateController = StreamController<ScreensaverState>.broadcast();
  Stream<ScreensaverState> get stateStream => _stateController.stream;
  ScreensaverState get state => _state;

  bool _enabled = true;
  bool get enabled => _enabled;

  void Function()? onActivate;
  void Function()? onDeactivate;

  void initialize({
    Duration idleTimeout = const Duration(minutes: 5),
    void Function()? onActivate,
    void Function()? onDeactivate,
  }) {
    if (!PlatformUtils.isDesktop) return;

    _idleTimeout = idleTimeout;
    this.onActivate = onActivate;
    this.onDeactivate = onDeactivate;

    _startIdleDetection();
  }

  void _startIdleDetection() {
    _idleTimer?.cancel();
    _idleTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_enabled) return;
      
      final idleTime = DateTime.now().difference(_lastActivity);
      if (idleTime >= _idleTimeout && _state == ScreensaverState.inactive) {
        _activateScreensaver();
      }
    });
  }

  void registerActivity() {
    _lastActivity = DateTime.now();
    
    if (_state == ScreensaverState.active) {
      _deactivateScreensaver();
    }
  }

  void _activateScreensaver() {
    if (_state == ScreensaverState.active) return;
    
    _state = ScreensaverState.active;
    _stateController.add(_state);
    onActivate?.call();
  }

  void _deactivateScreensaver() {
    if (_state == ScreensaverState.inactive) return;
    
    _state = ScreensaverState.inactive;
    _stateController.add(_state);
    onDeactivate?.call();
  }

  void setEnabled(bool enabled) {
    _enabled = enabled;
    if (!enabled && _state == ScreensaverState.active) {
      _deactivateScreensaver();
    }
  }

  void setIdleTimeout(Duration timeout) {
    _idleTimeout = timeout;
  }

  void forceActivate() {
    _activateScreensaver();
  }

  void forceDeactivate() {
    _deactivateScreensaver();
    registerActivity();
  }

  void dispose() {
    _idleTimer?.cancel();
    _stateController.close();
  }
}

mixin ScreensaverActivityMixin {
  void onUserActivity() {
    ScreensaverHandler.instance.registerActivity();
  }
}
