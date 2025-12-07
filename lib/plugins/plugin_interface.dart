import 'package:pixel_things/core/models/pixel_matrix.dart';

abstract class Plugin {
  String get name;
  String get id;

  void onActivate() {}
  void onDeactivate() {}
  void update(PixelMatrix matrix, int deltaTime);
  void reset() {}
}

enum PluginType { effect, info, utility }

class PluginInfo {
  final String id;
  final String name;
  final PluginType type;
  final bool enabled;

  const PluginInfo({
    required this.id,
    required this.name,
    required this.type,
    this.enabled = true,
  });
}
