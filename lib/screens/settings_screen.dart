import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_things/providers/app_state.dart';
import 'package:pixel_things/providers/settings_provider.dart';
import 'package:pixel_things/core/utils/color_utils.dart';
import 'package:pixel_things/core/models/app_theme.dart';
import 'package:pixel_things/widgets/color_picker.dart';
import 'package:pixel_things/platform/platform_utils.dart';
import 'package:pixel_things/platform/settings_backup.dart';
import 'package:pixel_things/platform/desktop/screensaver_handler.dart';
import 'package:pixel_things/platform/desktop/launch_at_startup_handler.dart';
import 'package:pixel_things/platform/desktop/window_handler.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const SettingsScreen({super.key, required this.onBack});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(settingsProvider.notifier).initialize();
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final plugins = appState.availablePlugins;
    final activePluginId = appState.activePluginId;

    return Container(
      color: const Color(0xFF1A1A1A),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildSectionTitle('Effects'),
              const SizedBox(height: 12),
              _buildEffectsList(ref, plugins, activePluginId),
              const SizedBox(height: 32),
              _buildSectionTitle('Theme'),
              const SizedBox(height: 12),
              _buildThemeSelector(),
              if (PlatformUtils.isDesktop) ...[
                const SizedBox(height: 32),
                _buildSectionTitle('Screensaver'),
                const SizedBox(height: 12),
                _buildScreensaverSettings(),
              ],
              const SizedBox(height: 32),
              _buildSectionTitle('Language'),
              const SizedBox(height: 12),
              _buildLanguageSelector(),
              const SizedBox(height: 32),
              _buildSectionTitle('Backup'),
              const SizedBox(height: 12),
              _buildBackupSection(),
              const SizedBox(height: 32),
              _buildSectionTitle('Controls'),
              const SizedBox(height: 12),
              _buildControlsInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: widget.onBack,
          child: const Text(
            'Back',
            style: TextStyle(
              color: PixelColors.timeColor,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScreensaverSettings() {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _SettingsSwitch(
            title: 'Enable Screensaver',
            subtitle: 'Activate after idle timeout',
            value: settings.screensaverEnabled,
            onChanged: (value) {
              settingsNotifier.setScreensaverEnabled(value);
              ScreensaverHandler.instance.setEnabled(value);
            },
          ),
          const SizedBox(height: 16),
          _SettingsDropdown(
            title: 'Idle Timeout',
            value: settings.screensaverTimeoutMin,
            items: const [1, 2, 5, 10, 15, 30],
            suffix: 'min',
            onChanged: (value) {
              settingsNotifier.setScreensaverTimeout(value);
              ScreensaverHandler.instance.setIdleTimeout(
                Duration(minutes: value),
              );
            },
          ),
          const SizedBox(height: 16),
          _SettingsSwitch(
            title: 'Launch at Startup',
            subtitle: 'Start automatically when system boots',
            value: settings.launchAtStartup,
            onChanged: (value) async {
              settingsNotifier.setLaunchAtStartup(value);
              await LaunchAtStartupHandler.setEnabled(value);
            },
          ),
          const SizedBox(height: 16),
          _SettingsButton(
            title: 'Start Screensaver Now',
            onTap: () {
              ScreensaverHandler.instance.forceActivate();
              widget.onBack();
            },
          ),
          const SizedBox(height: 8),
          _SettingsButton(
            title: 'Toggle Fullscreen',
            onTap: () {
              WindowHandler.instance.toggleFullscreen();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildThemeSelector() {
    final settings = ref.watch(settingsProvider);
    final currentThemeId = settings.themeId;

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: AppThemes.all.length,
        itemBuilder: (context, index) {
          final theme = AppThemes.all[index];
          final isSelected = theme.id == currentThemeId;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                ref.read(settingsProvider.notifier).setTheme(theme.id);
              },
              child: Container(
                width: 60,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.timeColor.withOpacity(0.3)
                      : const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: theme.timeColor, width: 2)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: theme.timeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      theme.name.split(' ').first,
                      style: TextStyle(
                        color: isSelected ? theme.timeColor : Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageSelector() {
    final settings = ref.watch(settingsProvider);
    final currentLang = settings.languageCode;

    final languages = [
      ('system', 'System', Icons.settings),
      ('en', 'English', Icons.language),
      ('zh', '中文', Icons.translate),
    ];

    return Row(
      children: languages.map((lang) {
        final isSelected = lang.$1 == currentLang;
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () {
              ref.read(settingsProvider.notifier).setLanguage(lang.$1);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? PixelColors.timeColor.withOpacity(0.2)
                    : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: PixelColors.timeColor, width: 1)
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    lang.$3,
                    color: isSelected ? PixelColors.timeColor : Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    lang.$2,
                    style: TextStyle(
                      color: isSelected ? PixelColors.timeColor : Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBackupSection() {
    final settings = ref.watch(settingsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _SettingsButton(
            title: 'Export Settings',
            onTap: () async {
              await SettingsBackup.shareSettings(settings);
            },
          ),
          const SizedBox(height: 8),
          _SettingsButton(
            title: 'Import Settings',
            onTap: () async {
              final imported = await SettingsBackup.importSettings();
              if (imported != null) {
                await ref.read(settingsProvider.notifier).updateSettings((_) => imported);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings imported successfully')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 8),
          _SettingsButton(
            title: 'Copy to Clipboard',
            onTap: () async {
              final json = await SettingsBackup.settingsToClipboard(settings);
              await Clipboard.setData(ClipboardData(text: json));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings copied to clipboard')),
                );
              }
            },
          ),
          const SizedBox(height: 8),
          _SettingsButton(
            title: 'Reset to Defaults',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF2A2A2A),
                  title: const Text('Reset Settings', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'Are you sure you want to reset all settings to defaults?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(settingsProvider.notifier).resetToDefaults();
                        Navigator.pop(context);
                      },
                      child: const Text('Reset', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showColorPicker(String title, Color initialColor, Function(Color) onConfirm) {
    Color selectedColor = initialColor;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: HSVColorPicker(
          initialColor: initialColor,
          onColorChanged: (color) => selectedColor = color,
          onConfirm: () {
            onConfirm(selectedColor);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _buildEffectsList(WidgetRef ref, List plugins, String? activePluginId) {
    final appState = ref.read(appStateProvider);

    return Expanded(
      child: ListView(
        children: [
          _EffectItem(
            name: 'Clock Only',
            isSelected: activePluginId == null,
            onTap: () {
              appState.deactivatePlugin();
              widget.onBack();
            },
          ),
          ...plugins.map((plugin) => _EffectItem(
            name: plugin.name,
            isSelected: plugin.id == activePluginId,
            onTap: () {
              appState.activatePlugin(plugin.id);
              widget.onBack();
            },
          )),
        ],
      ),
    );
  }

  Widget _buildControlsInfo() {
    final controls = PlatformUtils.isDesktop
        ? [
            ('Space', 'Toggle effect'),
            ('Esc', 'Clock only mode'),
            ('S', 'Open/close settings'),
            ('Arrow keys', 'Switch effects'),
          ]
        : [
            ('Single Tap', 'Next effect'),
            ('Double Tap', 'Clock only mode'),
            ('Long Press', 'Open settings'),
          ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: controls.map((control) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                control.$1,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              Text(
                control.$2,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

class _EffectItem extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _EffectItem({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected
            ? PixelColors.timeColor.withOpacity(0.2)
            : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: isSelected ? PixelColors.timeColor : Colors.white,
                    fontSize: 16,
                  ),
                ),
                if (isSelected)
                  const Text(
                    '●',
                    style: TextStyle(
                      color: PixelColors.timeColor,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: PixelColors.timeColor,
        ),
      ],
    );
  }
}

class _SettingsDropdown extends StatelessWidget {
  final String title;
  final int value;
  final List<int> items;
  final String suffix;
  final ValueChanged<int> onChanged;

  const _SettingsDropdown({
    required this.title,
    required this.value,
    required this.items,
    required this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<int>(
            value: value,
            dropdownColor: const Color(0xFF3A3A3A),
            underline: const SizedBox(),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            items: items.map((item) => DropdownMenuItem(
              value: item,
              child: Text('$item $suffix'),
            )).toList(),
            onChanged: (v) => v != null ? onChanged(v) : null,
          ),
        ),
      ],
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SettingsButton({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PixelColors.timeColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                color: PixelColors.timeColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
