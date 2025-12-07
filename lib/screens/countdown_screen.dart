import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_things/core/models/timer_models.dart';
import 'package:pixel_things/providers/timer_provider.dart';

class CountdownScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const CountdownScreen({super.key, required this.onBack});

  @override
  ConsumerState<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends ConsumerState<CountdownScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timers = ref.watch(countdownProvider);

    return Container(
      color: const Color(0xFF1A1A1A),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Expanded(
                child: timers.isEmpty
                    ? _buildEmptyState()
                    : _buildTimerList(timers),
              ),
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
          'Countdown',
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
              onPressed: () => _showAddDialog(),
            ),
            TextButton(
              onPressed: widget.onBack,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No countdowns yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Countdown'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FF00),
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerList(List<CountdownTimer> timers) {
    return ListView.builder(
      itemCount: timers.length,
      itemBuilder: (context, index) {
        final timer = timers[index];
        return _buildTimerCard(timer);
      },
    );
  }

  Widget _buildTimerCard(CountdownTimer timer) {
    final remaining = timer.remaining;
    final isExpired = timer.isExpired;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpired ? Colors.red.withOpacity(0.5) : timer.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 颜色指示器
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: timer.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          // 内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timer.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isExpired ? 'Expired' : timer.displayString,
                  style: TextStyle(
                    color: isExpired ? Colors.red : timer.color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  _formatTargetDate(timer.targetDate),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // 操作按钮
          IconButton(
            icon: Icon(
              timer.isActive ? Icons.pause : Icons.play_arrow,
              color: Colors.white.withOpacity(0.7),
            ),
            onPressed: () {
              ref.read(countdownProvider.notifier).toggleTimer(timer.id);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.white.withOpacity(0.5),
            ),
            onPressed: () {
              ref.read(countdownProvider.notifier).removeTimer(timer.id);
            },
          ),
        ],
      ),
    );
  }

  String _formatTargetDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showAddDialog() {
    String name = '';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text('Add Countdown', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                ),
                onChanged: (value) => name = value,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date', style: TextStyle(color: Colors.white70)),
                subtitle: Text(
                  '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Time', style: TextStyle(color: Colors.white70)),
                subtitle: Text(
                  '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setState(() => selectedTime = time);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (name.isNotEmpty) {
                  final targetDate = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                  ref.read(countdownProvider.notifier).addTimer(
                    CountdownTimer(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      targetDate: targetDate,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
