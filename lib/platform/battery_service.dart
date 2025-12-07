import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:pixel_things/platform/platform_utils.dart';

enum BatteryStatus {
  unknown,
  charging,
  discharging,
  full,
  notCharging,
}

class BatteryInfo {
  final int level;
  final BatteryStatus status;

  const BatteryInfo({
    this.level = -1,
    this.status = BatteryStatus.unknown,
  });

  bool get isAvailable => level >= 0;

  String get displayString {
    if (!isAvailable) return '--';
    final statusIcon = status == BatteryStatus.charging ? '+' : '';
    return '$level%$statusIcon';
  }

  String get barDisplay {
    if (!isAvailable) return '------';
    final filled = (level / 100 * 6).round();
    final empty = 6 - filled;
    return '${'█' * filled}${'░' * empty}';
  }
}

class BatteryService {
  static BatteryService? _instance;
  static BatteryService get instance => _instance ??= BatteryService._();

  BatteryService._();

  final Battery _battery = Battery();
  StreamSubscription<BatteryState>? _subscription;
  
  BatteryInfo _currentInfo = const BatteryInfo();
  BatteryInfo get currentInfo => _currentInfo;

  final _controller = StreamController<BatteryInfo>.broadcast();
  Stream<BatteryInfo> get onBatteryChanged => _controller.stream;

  Future<void> initialize() async {
    if (!PlatformUtils.isMobile) {
      // 桌面端可能不支持电池
      _currentInfo = const BatteryInfo(level: -1);
      return;
    }

    try {
      await _updateBatteryInfo();
      
      _subscription = _battery.onBatteryStateChanged.listen((state) {
        _updateBatteryInfo();
      });
    } catch (e) {
      debugPrint('Battery service init failed: $e');
      _currentInfo = const BatteryInfo(level: -1);
    }
  }

  Future<void> _updateBatteryInfo() async {
    try {
      final level = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      
      _currentInfo = BatteryInfo(
        level: level,
        status: _convertState(state),
      );
      
      _controller.add(_currentInfo);
    } catch (e) {
      debugPrint('Failed to get battery info: $e');
    }
  }

  BatteryStatus _convertState(BatteryState state) {
    switch (state) {
      case BatteryState.charging:
        return BatteryStatus.charging;
      case BatteryState.discharging:
        return BatteryStatus.discharging;
      case BatteryState.full:
        return BatteryStatus.full;
      case BatteryState.connectedNotCharging:
        return BatteryStatus.notCharging;
      default:
        return BatteryStatus.unknown;
    }
  }

  Future<BatteryInfo> getBatteryInfo() async {
    await _updateBatteryInfo();
    return _currentInfo;
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
