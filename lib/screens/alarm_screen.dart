import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_things/core/models/timer_models.dart';
import 'package:pixel_things/providers/timer_provider.dart';

class AlarmScreen extends ConsumerWidget {
  final VoidCallback onBack;

  const AlarmScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarms = ref.watch(alarmProvider);

    return Container(
      color: const Color(0xFF1A1A1A),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, ref),
              const SizedBox(height: 24),
              Expanded(
                child: alarms.isEmpty
                    ? _buildEmptyState(context, ref)
                    : _buildAlarmList(context, ref, alarms),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Alarms',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF00FF00)),
              onPressed: () => _showAddDialog(context, ref),
            ),
            TextButton(
              onPressed: onBack,
              child: const Text(
                'Back',
                style: TextStyle(color: Color(0xFF00FF00), fontSize: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.alarm_outlined,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No alarms yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add Alarm'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FF00),
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmList(BuildContext context, WidgetRef ref, List<Alarm> alarms) {
    return ListView.builder(
      itemCount: alarms.length,
      itemBuilder: (context, index) {
        final alarm = alarms[index];
        return _buildAlarmCard(context, ref, alarm);
      },
    );
  }

  Widget _buildAlarmCard(BuildContext context, WidgetRef ref, Alarm alarm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alarm.isEnabled
              ? const Color(0xFF00FF00).withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 时间
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alarm.timeString,
                  style: TextStyle(
                    color: alarm.isEnabled ? Colors.white : Colors.white54,
                    fontSize: 36,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alarm.name,
                  style: TextStyle(
                    color: alarm.isEnabled ? Colors.white70 : Colors.white38,
                    fontSize: 14,
                  ),
                ),
                Text(
                  alarm.repeatString,
                  style: TextStyle(
                    color: alarm.isEnabled
                        ? const Color(0xFF00FF00).withOpacity(0.7)
                        : Colors.white24,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // 开关
          Switch(
            value: alarm.isEnabled,
            onChanged: (_) {
              ref.read(alarmProvider.notifier).toggleAlarm(alarm.id);
            },
            activeColor: const Color(0xFF00FF00),
          ),
          // 删除
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.white.withOpacity(0.5),
            ),
            onPressed: () {
              ref.read(alarmProvider.notifier).removeAlarm(alarm.id);
            },
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    String name = 'Alarm';
    TimeOfDay selectedTime = TimeOfDay.now();
    AlarmRepeat repeat = AlarmRepeat.once;
    List<int> customDays = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text('Add Alarm', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 时间选择
                GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setState(() => selectedTime = time);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
                // 名称
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                  ),
                  controller: TextEditingController(text: name),
                  onChanged: (value) => name = value,
                ),
                const SizedBox(height: 16),
                // 重复选项
                DropdownButtonFormField<AlarmRepeat>(
                  value: repeat,
                  dropdownColor: const Color(0xFF3A3A3A),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Repeat',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                  ),
                  items: AlarmRepeat.values.map((r) {
                    String label;
                    switch (r) {
                      case AlarmRepeat.once:
                        label = 'Once';
                        break;
                      case AlarmRepeat.daily:
                        label = 'Daily';
                        break;
                      case AlarmRepeat.weekdays:
                        label = 'Weekdays';
                        break;
                      case AlarmRepeat.weekends:
                        label = 'Weekends';
                        break;
                      case AlarmRepeat.custom:
                        label = 'Custom';
                        break;
                    }
                    return DropdownMenuItem(value: r, child: Text(label));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => repeat = value);
                  },
                ),
                // 自定义天数选择
                if (repeat == AlarmRepeat.custom) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: List.generate(7, (index) {
                      final day = index + 1;
                      final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                      final isSelected = customDays.contains(day);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              customDays.remove(day);
                            } else {
                              customDays.add(day);
                            }
                          });
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? const Color(0xFF00FF00)
                                : Colors.white.withOpacity(0.1),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            dayNames[index],
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(alarmProvider.notifier).addAlarm(
                  Alarm(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    hour: selectedTime.hour,
                    minute: selectedTime.minute,
                    repeat: repeat,
                    customDays: customDays,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
