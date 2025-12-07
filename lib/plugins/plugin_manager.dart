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

class PluginManager {
  final Map<String, Plugin> _plugins = {};
  Plugin? _activePlugin;
  String? _activePluginId;

  PluginManager() {
    _registerPlugin(FirePlugin());
    _registerPlugin(MatrixPlugin());
    _registerPlugin(RainbowPlugin());
    _registerPlugin(GameOfLifePlugin());
    _registerPlugin(WormPlugin());
    _registerPlugin(PlasmaPlugin());
    _registerPlugin(StarfieldPlugin());
    _registerPlugin(SnowPlugin());
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
}
