import 'dart:ui';
import 'package:pixel_things/core/models/pixel_matrix.dart';
import 'package:pixel_things/plugins/plugin_interface.dart';
import 'package:pixel_things/plugins/fire_plugin.dart';
import 'package:pixel_things/plugins/matrix_plugin.dart';
import 'package:pixel_things/plugins/rainbow_plugin.dart';
import 'package:pixel_things/plugins/game_of_life_plugin.dart';
import 'package:pixel_things/plugins/worm_plugin.dart';
import 'package:pixel_things/plugins/plasma_plugin.dart';
import 'package:pixel_things/plugins/starfield_plugin.dart';
import 'package:pixel_things/plugins/snow_plugin.dart';
import 'package:pixel_things/plugins/bouncing_ball_plugin.dart';
import 'package:pixel_things/plugins/fireworks_plugin.dart';
import 'package:pixel_things/plugins/ripple_plugin.dart';

enum BlendMode {
  replace,   // 替换（默认）
  additive,  // 叠加
  multiply,  // 正片叠底
  screen,    // 滤色
}

class PluginManager {
  final Map<String, Plugin> _plugins = {};
  Plugin? _activePlugin;
  String? _activePluginId;
  
  // 组合模式支持
  final Set<String> _activePluginIds = {};
  bool _combineMode = false;
  BlendMode _blendMode = BlendMode.additive;

  PluginManager() {
    _registerPlugin(FirePlugin());
    _registerPlugin(MatrixPlugin());
    _registerPlugin(RainbowPlugin());
    _registerPlugin(GameOfLifePlugin());
    _registerPlugin(WormPlugin());
    _registerPlugin(PlasmaPlugin());
    _registerPlugin(StarfieldPlugin());
    _registerPlugin(SnowPlugin());
    _registerPlugin(BouncingBallPlugin());
    _registerPlugin(FireworksPlugin());
    _registerPlugin(RipplePlugin());
  }

  void _registerPlugin(Plugin plugin) {
    _plugins[plugin.id] = plugin;
  }

  List<PluginInfo> getAvailablePlugins() {
    return _plugins.values.map((plugin) => PluginInfo(
      id: plugin.id,
      name: plugin.name,
      type: PluginType.effect,
    )).toList();
  }

  void activatePlugin(String pluginId) {
    _activePlugin?.onDeactivate();
    _activePlugin = _plugins[pluginId];
    _activePluginId = pluginId;
    _activePlugin?.onActivate();
    _activePlugin?.reset();
  }

  void deactivatePlugin() {
    _activePlugin?.onDeactivate();
    _activePlugin = null;
    _activePluginId = null;
  }

  String? get activePluginId => _activePluginId;

  bool get isPluginActive => _activePlugin != null;

  void updateActivePlugin(PixelMatrix matrix, int deltaTime) {
    _activePlugin?.update(matrix, deltaTime);
  }

  void cycleNextPlugin() {
    final pluginIds = _plugins.keys.toList();
    if (pluginIds.isEmpty) return;

    final currentIndex = _activePluginId != null 
        ? pluginIds.indexOf(_activePluginId!) 
        : -1;
    final nextIndex = (currentIndex + 1) % pluginIds.length;
    activatePlugin(pluginIds[nextIndex]);
  }

  void cyclePreviousPlugin() {
    final pluginIds = _plugins.keys.toList();
    if (pluginIds.isEmpty) return;

    final currentIndex = _activePluginId != null 
        ? pluginIds.indexOf(_activePluginId!) 
        : 0;
    final prevIndex = currentIndex <= 0 ? pluginIds.length - 1 : currentIndex - 1;
    activatePlugin(pluginIds[prevIndex]);
  }

  String? getActivePluginName() {
    return _activePlugin?.name;
  }

  // 组合模式方法
  bool get isCombineMode => _combineMode;
  BlendMode get blendMode => _blendMode;
  Set<String> get activePluginIds => _activePluginIds;

  void setCombineMode(bool enabled) {
    _combineMode = enabled;
    if (!enabled) {
      // 退出组合模式时，停用所有插件
      for (final id in _activePluginIds) {
        _plugins[id]?.onDeactivate();
      }
      _activePluginIds.clear();
    }
  }

  void setBlendMode(BlendMode mode) {
    _blendMode = mode;
  }

  void togglePluginInCombine(String pluginId) {
    if (_activePluginIds.contains(pluginId)) {
      _activePluginIds.remove(pluginId);
      _plugins[pluginId]?.onDeactivate();
    } else {
      _activePluginIds.add(pluginId);
      _plugins[pluginId]?.onActivate();
      _plugins[pluginId]?.reset();
    }
  }

  void updateCombinedPlugins(PixelMatrix matrix, int deltaTime) {
    if (!_combineMode || _activePluginIds.isEmpty) {
      updateActivePlugin(matrix, deltaTime);
      return;
    }

    // 创建临时矩阵存储每个插件的输出
    final tempMatrices = <PixelMatrix>[];
    
    for (final id in _activePluginIds) {
      final tempMatrix = PixelMatrix(matrix.width, matrix.height);
      _plugins[id]?.update(tempMatrix, deltaTime);
      tempMatrices.add(tempMatrix);
    }

    // 混合所有矩阵
    for (int y = 0; y < matrix.height; y++) {
      for (int x = 0; x < matrix.width; x++) {
        int r = 0, g = 0, b = 0;
        
        for (final temp in tempMatrices) {
          final color = temp.getPixel(x, y);
          switch (_blendMode) {
            case BlendMode.replace:
              r = color.red;
              g = color.green;
              b = color.blue;
              break;
            case BlendMode.additive:
              r = (r + color.red).clamp(0, 255);
              g = (g + color.green).clamp(0, 255);
              b = (b + color.blue).clamp(0, 255);
              break;
            case BlendMode.multiply:
              r = ((r * color.red) / 255).round().clamp(0, 255);
              g = ((g * color.green) / 255).round().clamp(0, 255);
              b = ((b * color.blue) / 255).round().clamp(0, 255);
              break;
            case BlendMode.screen:
              r = (255 - ((255 - r) * (255 - color.red) / 255)).round().clamp(0, 255);
              g = (255 - ((255 - g) * (255 - color.green) / 255)).round().clamp(0, 255);
              b = (255 - ((255 - b) * (255 - color.blue) / 255)).round().clamp(0, 255);
              break;
          }
        }
        
        matrix.setPixel(x, y, Color.fromRGBO(r, g, b, 1));
      }
    }
  }
}
