import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/buddy_state.dart';
import '../theme/buddy_theme.dart';
import '../widgets/atmosphere.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BuddyState>();
    final theme = Theme.of(context);

    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Habits'),
          actions: [
            IconButton(
              onPressed: () => _showAdd(context),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              'Gentle structure. No guilt trips.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: BuddyColors.moss,
              ),
            ),
            const SizedBox(height: 16),
            ...state.habits.map((habit) {
              final done = habit.isDoneToday();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(18),
                  child: ListTile(
                    titleAlignment: ListTileTitleAlignment.center,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    leading: Text(habit.emoji, style: const TextStyle(fontSize: 26)),
                    title: Text(
                      habit.title,
                      style: TextStyle(
                        decoration:
                            done ? TextDecoration.lineThrough : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Reminder ${habit.reminderHour.toString().padLeft(2, '0')}:'
                      '${habit.reminderMinute.toString().padLeft(2, '0')}'
                      '${habit.enabled ? '' : ' · paused'}',
                    ),
                    trailing: Checkbox(
                      value: done,
                      activeColor: BuddyColors.moss,
                      onChanged: (_) => state.toggleHabitDone(habit),
                    ),
                    onLongPress: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Remove habit?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Keep'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) await state.removeHabit(habit);
                    },
                  ),
                ),
              );
            }),
            if (state.habits.isEmpty)
              Text(
                'Add one tiny habit. Small wins rebuild self-worth.',
                style: theme.textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAdd(BuildContext context) async {
    final ctrl = TextEditingController();
    final title = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BuddyColors.sand,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'New habit',
                style: Theme.of(ctx).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'e.g. Touch Qur’an for 2 minutes',
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, ctrl.text),
                style: FilledButton.styleFrom(
                  backgroundColor: BuddyColors.moss,
                ),
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
    if (title != null && title.trim().isNotEmpty && context.mounted) {
      await context.read<BuddyState>().addHabit(title.trim());
    }
  }
}
