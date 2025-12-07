import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_things/core/models/timer_models.dart';
import 'package:pixel_things/providers/timer_provider.dart';

class PomodoroScreen extends ConsumerWidget {
  final VoidCallback onBack;

  const PomodoroScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);

    return Container(
      color: const Color(0xFF1A1A1A),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildHeader(context),
              const Spacer(),
              _buildTimer(session),
              const SizedBox(height: 40),
              _buildControls(session, notifier),
              const SizedBox(height: 24),
              _buildSessionIndicator(session),
              const Spacer(),
              _buildSettings(context, ref, session),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Pomodoro',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onBack,
          child: const Text(
            'Back',
            style: TextStyle(color: Color(0xFF00FF00), fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildTimer(PomodoroSession session) {
    return Column(
      children: [
        // 状态标签
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: session.stateColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            session.stateLabel,
            style: TextStyle(
              color: session.stateColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // 时间显示
        Stack(
          alignment: Alignment.center,
          children: [
            // 进度环
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: session.progress,
                strokeWidth: 8,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation(session.stateColor),
              ),
            ),
            // 时间文字
            Text(
              session.state == PomodoroState.idle
                  ? '${session.settings.focusMinutes}:00'
                  : session.timeDisplay,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w300,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControls(PomodoroSession session, PomodoroNotifier notifier) {
    final isRunning = session.state == PomodoroState.focus ||
        session.state == PomodoroState.shortBreak ||
        session.state == PomodoroState.longBreak;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (session.state == PomodoroState.idle) ...[
          _buildControlButton(
            icon: Icons.play_arrow,
            label: 'Start',
            color: const Color(0xFFFF6B6B),
            onTap: notifier.startFocus,
          ),
        ] else if (session.state == PomodoroState.paused) ...[
          _buildControlButton(
            icon: Icons.play_arrow,
            label: 'Resume',
            color: const Color(0xFF4ECDC4),
            onTap: notifier.resume,
          ),
          const SizedBox(width: 16),
          _buildControlButton(
            icon: Icons.stop,
            label: 'Stop',
            color: Colors.grey,
            onTap: notifier.stop,
          ),
        ] else if (isRunning) ...[
          _buildControlButton(
            icon: Icons.pause,
            label: 'Pause',
            color: const Color(0xFFFFD93D),
            onTap: notifier.pause,
          ),
          const SizedBox(width: 16),
          _buildControlButton(
            icon: Icons.skip_next,
            label: 'Skip',
            color: Colors.grey,
            onTap: notifier.skip,
          ),
        ],
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionIndicator(PomodoroSession session) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(session.settings.sessionsBeforeLongBreak, (index) {
        final isCompleted = index < session.completedSessions % session.settings.sessionsBeforeLongBreak;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? const Color(0xFFFF6B6B) : Colors.white.withOpacity(0.2),
            border: Border.all(
              color: const Color(0xFFFF6B6B).withOpacity(0.5),
              width: 1,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSettings(BuildContext context, WidgetRef ref, PomodoroSession session) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSettingRow(
            'Focus',
            '${session.settings.focusMinutes} min',
            () => _showTimePicker(context, ref, 'focus', session.settings.focusMinutes),
          ),
          const Divider(color: Colors.white12),
          _buildSettingRow(
            'Short Break',
            '${session.settings.shortBreakMinutes} min',
            () => _showTimePicker(context, ref, 'short', session.settings.shortBreakMinutes),
          ),
          const Divider(color: Colors.white12),
          _buildSettingRow(
            'Long Break',
            '${session.settings.longBreakMinutes} min',
            () => _showTimePicker(context, ref, 'long', session.settings.longBreakMinutes),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePicker(BuildContext context, WidgetRef ref, String type, int currentValue) {
    final values = [5, 10, 15, 20, 25, 30, 45, 60];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Duration',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: values.map((v) {
                final isSelected = v == currentValue;
                return GestureDetector(
                  onTap: () {
                    final notifier = ref.read(pomodoroProvider.notifier);
                    final session = ref.read(pomodoroProvider);
                    PomodoroSettings newSettings;
                    switch (type) {
                      case 'focus':
                        newSettings = session.settings.copyWith(focusMinutes: v);
                        break;
                      case 'short':
                        newSettings = session.settings.copyWith(shortBreakMinutes: v);
                        break;
                      case 'long':
                        newSettings = session.settings.copyWith(longBreakMinutes: v);
                        break;
                      default:
                        return;
                    }
                    notifier.updateSettings(newSettings);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF00FF00).withOpacity(0.2) : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected ? Border.all(color: const Color(0xFF00FF00), width: 2) : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$v',
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF00FF00) : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
