import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('zh'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General
      'app_name': 'Pixel Things',
      'settings': 'Settings',
      'back': 'Back',
      'apply': 'Apply',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'reset': 'Reset',
      'save': 'Save',
      
      // Settings sections
      'effects': 'Effects',
      'theme': 'Theme',
      'screensaver': 'Screensaver',
      'controls': 'Controls',
      'display': 'Display',
      'language': 'Language',
      'backup': 'Backup & Restore',
      
      // Effects
      'clock_only': 'Clock Only',
      'fire': 'Fire',
      'matrix': 'Matrix',
      'rainbow': 'Rainbow',
      'game_of_life': 'Game of Life',
      'worm': 'Worm',
      'plasma': 'Plasma',
      'starfield': 'Starfield',
      'snow': 'Snow',
      
      // Themes
      'matrix_green': 'Matrix Green',
      'cyber_blue': 'Cyber Blue',
      'sunset_orange': 'Sunset Orange',
      'neon_pink': 'Neon Pink',
      'pure_white': 'Pure White',
      'retro_amber': 'Retro Amber',
      'custom': 'Custom',
      
      // Screensaver
      'enable_screensaver': 'Enable Screensaver',
      'screensaver_hint': 'Activate after idle timeout',
      'idle_timeout': 'Idle Timeout',
      'launch_at_startup': 'Launch at Startup',
      'startup_hint': 'Start automatically when system boots',
      'start_screensaver': 'Start Screensaver Now',
      'toggle_fullscreen': 'Toggle Fullscreen',
      
      // Controls
      'space': 'Space',
      'toggle_effect': 'Toggle effect',
      'esc': 'Esc',
      'clock_mode': 'Clock only mode',
      'key_s': 'S',
      'open_settings': 'Open/close settings',
      'arrow_keys': 'Arrow keys',
      'switch_effects': 'Switch effects',
      'single_tap': 'Single Tap',
      'next_effect': 'Next effect',
      'double_tap': 'Double Tap',
      'long_press': 'Long Press',
      
      // Color picker
      'saturation': 'Saturation',
      'brightness': 'Brightness',
      'custom_color': 'Custom Color',
      'time_color': 'Time Color',
      'seconds_color': 'Seconds Color',
      
      // Backup
      'export_settings': 'Export Settings',
      'import_settings': 'Import Settings',
      'export_success': 'Settings exported successfully',
      'import_success': 'Settings imported successfully',
      'import_failed': 'Failed to import settings',
      'reset_to_defaults': 'Reset to Defaults',
      'reset_confirm': 'Are you sure you want to reset all settings?',
      
      // Date
      'date_display': 'Date Display',
      'time_only': 'Time Only',
      'alternate': 'Alternate',
      'combined': 'Combined',
      
      // Minutes
      'min': 'min',
    },
    'zh': {
      // General
      'app_name': '像素时钟',
      'settings': '设置',
      'back': '返回',
      'apply': '应用',
      'cancel': '取消',
      'confirm': '确认',
      'reset': '重置',
      'save': '保存',
      
      // Settings sections
      'effects': '效果',
      'theme': '主题',
      'screensaver': '屏保',
      'controls': '操作',
      'display': '显示',
      'language': '语言',
      'backup': '备份与恢复',
      
      // Effects
      'clock_only': '仅时钟',
      'fire': '火焰',
      'matrix': '黑客帝国',
      'rainbow': '彩虹',
      'game_of_life': '生命游戏',
      'worm': '蠕虫',
      'plasma': '等离子',
      'starfield': '星空',
      'snow': '雪花',
      
      // Themes
      'matrix_green': '矩阵绿',
      'cyber_blue': '赛博蓝',
      'sunset_orange': '日落橙',
      'neon_pink': '霓虹粉',
      'pure_white': '纯白',
      'retro_amber': '复古琥珀',
      'custom': '自定义',
      
      // Screensaver
      'enable_screensaver': '启用屏保',
      'screensaver_hint': '空闲后自动激活',
      'idle_timeout': '空闲超时',
      'launch_at_startup': '开机启动',
      'startup_hint': '系统启动时自动运行',
      'start_screensaver': '立即启动屏保',
      'toggle_fullscreen': '切换全屏',
      
      // Controls
      'space': '空格',
      'toggle_effect': '切换效果',
      'esc': 'Esc',
      'clock_mode': '仅时钟模式',
      'key_s': 'S',
      'open_settings': '打开/关闭设置',
      'arrow_keys': '方向键',
      'switch_effects': '切换效果',
      'single_tap': '单击',
      'next_effect': '下一个效果',
      'double_tap': '双击',
      'long_press': '长按',
      
      // Color picker
      'saturation': '饱和度',
      'brightness': '亮度',
      'custom_color': '自定义颜色',
      'time_color': '时间颜色',
      'seconds_color': '秒数颜色',
      
      // Backup
      'export_settings': '导出设置',
      'import_settings': '导入设置',
      'export_success': '设置导出成功',
      'import_success': '设置导入成功',
      'import_failed': '导入设置失败',
      'reset_to_defaults': '恢复默认设置',
      'reset_confirm': '确定要重置所有设置吗？',
      
      // Date
      'date_display': '日期显示',
      'time_only': '仅时间',
      'alternate': '交替显示',
      'combined': '同时显示',
      
      // Minutes
      'min': '分钟',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  // 便捷方法
  String get appName => get('app_name');
  String get settings => get('settings');
  String get back => get('back');
  String get apply => get('apply');
  String get cancel => get('cancel');
  String get effects => get('effects');
  String get theme => get('theme');
  String get screensaver => get('screensaver');
  String get controls => get('controls');
  String get language => get('language');
  String get backup => get('backup');
  String get exportSettings => get('export_settings');
  String get importSettings => get('import_settings');
  String get resetToDefaults => get('reset_to_defaults');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
