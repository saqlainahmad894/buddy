import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../state/buddy_state.dart';
import '../theme/buddy_theme.dart';
import '../widgets/atmosphere.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  static const moods = [
    'heavy',
    'numb',
    'anxious',
    'angry',
    'hopeful',
    'grateful',
    'lonely',
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BuddyState>();
    final theme = Theme.of(context);

    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Journal'),
          actions: [
            IconButton(
              onPressed: () => _compose(context),
              icon: const Icon(Icons.edit_note_rounded),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              'Write thoughts, plans, or reflections. '
              'This stays on your device.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: BuddyColors.sage,
              ),
            ),
            const SizedBox(height: 18),
            if (state.journal.isEmpty)
              Text(
                'Nothing written yet. When it hurts, put it here — Buddy will witness it.',
                style: theme.textTheme.bodyMedium,
              ),
            ...state.journal.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SoftPanel(
                  child: InkWell(
                    onLongPress: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete entry?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Keep'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await state.deleteJournal(e.id);
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                e.title,
                                style: theme.textTheme.titleLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: BuddyColors.sage.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(e.mood),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat.yMMMd().add_jm().format(e.createdAt),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.55),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(e.body, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _compose(context),
          icon: const Icon(Icons.add),
          label: const Text('Unload'),
        ),
      ),
    );
  }

  Future<void> _compose(BuildContext context) async {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    var mood = moods.first;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BuddyColors.sand,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Put it down',
                      style: Theme.of(ctx).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Title (optional)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: moods.map((m) {
                        final selected = m == mood;
                        return ChoiceChip(
                          label: Text(m),
                          selected: selected,
                          selectedColor: BuddyColors.sage,
                          onSelected: (_) => setModal(() => mood = m),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: bodyCtrl,
                      minLines: 5,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        hintText:
                            'What’s on your mind today…',
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () async {
                        if (bodyCtrl.text.trim().isEmpty) return;
                        final buddy = context.read<BuddyState>();
                        await buddy.addJournal(
                          title: titleCtrl.text,
                          body: bodyCtrl.text,
                          mood: mood,
                        );
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Saved. Buddy left a note in chat.'),
                            action: SnackBarAction(
                              label: 'Open chat',
                              onPressed: buddy.openChat,
                            ),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: BuddyColors.moss,
                      ),
                      child: const Text('Save entry'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
