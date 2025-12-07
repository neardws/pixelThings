import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pixel_things/core/models/app_settings.dart';
import 'package:pixel_things/platform/storage_service.dart';

class SettingsBackup {
  static const String _fileName = 'pixel_things_settings.json';

  /// 导出设置到文件
  static Future<String?> exportSettings(AppSettings settings) async {
    try {
      final jsonData = {
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'settings': settings.toJson(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

      // 获取临时目录
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$_fileName');
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      debugPrint('Export failed: $e');
      return null;
    }
  }

  /// 分享导出的设置
  static Future<void> shareSettings(AppSettings settings) async {
    final filePath = await exportSettings(settings);
    if (filePath != null) {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Pixel Things Settings',
      );
    }
  }

  /// 从文件导入设置
  static Future<AppSettings?> importSettings() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return null;

      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // 验证版本
      final version = jsonData['version'] as int?;
      if (version == null || version > 1) {
        debugPrint('Unsupported settings version');
        return null;
      }

      final settingsJson = jsonData['settings'] as Map<String, dynamic>;
      return AppSettings.fromJson(settingsJson);
    } catch (e) {
      debugPrint('Import failed: $e');
      return null;
    }
  }

  /// 复制设置到剪贴板
  static Future<String> settingsToClipboard(AppSettings settings) async {
    final jsonData = {
      'version': 1,
      'settings': settings.toJson(),
    };
    return const JsonEncoder.withIndent('  ').convert(jsonData);
  }

  /// 从剪贴板字符串解析设置
  static AppSettings? settingsFromClipboard(String jsonString) {
    try {
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final settingsJson = jsonData['settings'] as Map<String, dynamic>;
      return AppSettings.fromJson(settingsJson);
    } catch (e) {
      debugPrint('Parse failed: $e');
      return null;
    }
  }
}
