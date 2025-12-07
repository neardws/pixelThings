import 'package:flutter/material.dart';

enum InfoType {
  text,      // 自定义文字
  date,      // 日期
  battery,   // 电池状态
  countdown, // 倒计时
}

class InfoSlot {
  final String id;
  final InfoType type;
  final String content;
  final Color color;
  final Duration displayDuration;
  final int priority; // 高优先级可打断低优先级
  final DateTime? expiresAt;

  const InfoSlot({
    required this.id,
    required this.type,
    required this.content,
    this.color = const Color(0xFF00FF00),
    this.displayDuration = const Duration(seconds: 5),
    this.priority = 0,
    this.expiresAt,
  });

  InfoSlot copyWith({
    String? id,
    InfoType? type,
    String? content,
    Color? color,
    Duration? displayDuration,
    int? priority,
    DateTime? expiresAt,
  }) {
    return InfoSlot(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      color: color ?? this.color,
      displayDuration: displayDuration ?? this.displayDuration,
      priority: priority ?? this.priority,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}

class InfoQueue {
  final List<InfoSlot> _slots = [];
  InfoSlot? _currentSlot;
  int _displayTimer = 0;
  int _scrollOffset = 0;
  int _scrollTimer = 0;
  static const int _scrollInterval = 150; // ms per pixel scroll

  InfoSlot? get currentSlot => _currentSlot;
  int get scrollOffset => _scrollOffset;
  bool get hasInfo => _currentSlot != null || _slots.isNotEmpty;

  void addInfo(InfoSlot slot) {
    // 移除相同 ID 的旧信息
    _slots.removeWhere((s) => s.id == slot.id);
    
    // 如果优先级更高，立即显示
    if (_currentSlot != null && slot.priority > _currentSlot!.priority) {
      _slots.insert(0, _currentSlot!);
      _currentSlot = slot;
      _displayTimer = 0;
      _scrollOffset = 0;
    } else {
      // 按优先级插入
      int insertIndex = _slots.length;
      for (int i = 0; i < _slots.length; i++) {
        if (slot.priority > _slots[i].priority) {
          insertIndex = i;
          break;
        }
      }
      _slots.insert(insertIndex, slot);
    }
  }

  void removeInfo(String id) {
    _slots.removeWhere((s) => s.id == id);
    if (_currentSlot?.id == id) {
      _currentSlot = null;
      _displayTimer = 0;
    }
  }

  void clearAll() {
    _slots.clear();
    _currentSlot = null;
    _displayTimer = 0;
    _scrollOffset = 0;
  }

  void update(int deltaTime, int contentWidth, int viewportWidth) {
    // 移除过期信息
    _slots.removeWhere((s) => s.isExpired);
    if (_currentSlot?.isExpired == true) {
      _currentSlot = null;
    }

    // 如果没有当前显示的信息，从队列取一个
    if (_currentSlot == null && _slots.isNotEmpty) {
      _currentSlot = _slots.removeAt(0);
      _displayTimer = 0;
      _scrollOffset = 0;
    }

    if (_currentSlot == null) return;

    // 更新显示计时器
    _displayTimer += deltaTime;

    // 如果内容超出视口，滚动显示
    if (contentWidth > viewportWidth) {
      _scrollTimer += deltaTime;
      if (_scrollTimer >= _scrollInterval) {
        _scrollTimer = 0;
        _scrollOffset++;
        // 滚动完成后重置
        if (_scrollOffset > contentWidth - viewportWidth + 10) {
          _scrollOffset = 0;
        }
      }
    }

    // 检查是否显示完成
    if (_displayTimer >= _currentSlot!.displayDuration.inMilliseconds) {
      _currentSlot = null;
      _displayTimer = 0;
      _scrollOffset = 0;
    }
  }
}
