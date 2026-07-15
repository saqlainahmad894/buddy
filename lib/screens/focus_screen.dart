import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/buddy_state.dart';
import '../theme/buddy_theme.dart';
import '../widgets/atmosphere.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BuddyState>();
    final theme = Theme.of(context);
    final doneGoals = state.goals.where((g) => g.isDoneToday()).length;
    final doneHabits = state.habits.where((h) => h.isDoneToday()).length;

    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Focus'),
          actions: [
            IconButton(
              tooltip: 'Goal nudge → opens chat',
              onPressed: () => state.askDisciplineNudge(),
              icon: const Icon(Icons.chat_outlined),
            ),
            IconButton(
              tooltip: 'Add goal',
              onPressed: () => _addGoal(context),
              icon: const Icon(Icons.flag_outlined),
            ),
            IconButton(
              tooltip: 'Add habit',
              onPressed: () => _addHabit(context),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            SoftPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today’s board',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$doneHabits/${state.habits.length} habits · '
                    '$doneGoals/${state.goals.length} discipline goals',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: BuddyColors.sage,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Gentle structure. No shame spirals.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('Discipline goals', style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            ...state.goals.map((goal) {
              final done = goal.isDoneToday();
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SoftPanel(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(
                      goal.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      '${goal.category} · streak ${goal.streak}'
                      '${goal.why.isEmpty ? '' : '\n${goal.why}'}',
                    ),
                    isThreeLine: goal.why.isNotEmpty,
                    trailing: Checkbox(
                      value: done,
                      activeColor: BuddyColors.moss,
                      onChanged: (_) => state.toggleGoalDone(goal),
                    ),
                    onLongPress: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Remove goal?'),
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
                      if (ok == true) await state.removeGoal(goal);
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            Text('Habits', style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            ...state.habits.map((habit) {
              final done = habit.isDoneToday();
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SoftPanel(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: Text(habit.emoji, style: const TextStyle(fontSize: 26)),
                    title: Text(
                      habit.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      '${habit.reminderHour.toString().padLeft(2, '0')}:'
                      '${habit.reminderMinute.toString().padLeft(2, '0')}',
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
          ],
        ),
      ),
    );
  }

  Future<void> _addHabit(BuildContext context) async {
    final ctrl = TextEditingController();
    final title = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
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
            Text('New habit', style: Theme.of(ctx).textTheme.headlineMedium),
            const SizedBox(height: 12),
            TextField(controller: ctrl, autofocus: true),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    if (title != null && title.trim().isNotEmpty && context.mounted) {
      await context.read<BuddyState>().addHabit(title.trim());
    }
  }

  Future<void> _addGoal(BuildContext context) async {
    final titleCtrl = TextEditingController();
    final whyCtrl = TextEditingController();
    var category = 'mind';

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
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
                    'Discipline goal',
                    style: Theme.of(ctx).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(hintText: 'Goal title'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: whyCtrl,
                    decoration: const InputDecoration(hintText: 'Why it matters'),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: ['deen', 'body', 'mind', 'digital'].map((c) {
                      return ChoiceChip(
                        label: Text(c),
                        selected: category == c,
                        onSelected: (_) => setModal(() => category = c),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Lock it in'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (saved == true &&
        titleCtrl.text.trim().isNotEmpty &&
        context.mounted) {
      await context.read<BuddyState>().addGoal(
            title: titleCtrl.text.trim(),
            why: whyCtrl.text.trim(),
            category: category,
          );
    }
  }
}
