import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/islamic_content.dart';
import '../state/buddy_state.dart';
import '../theme/buddy_theme.dart';
import '../widgets/atmosphere.dart';

class DeenScreen extends StatefulWidget {
  const DeenScreen({super.key});

  @override
  State<DeenScreen> createState() => _DeenScreenState();
}

class _DeenScreenState extends State<DeenScreen> {
  late IslamicNudge _nudge;
  late String _adhkar;

  @override
  void initState() {
    super.initState();
    _reshuffle();
  }

  void _reshuffle() {
    final rng = Random();
    _nudge = kIslamicNudges[rng.nextInt(kIslamicNudges.length)];
    _adhkar = kShortAdhkar[rng.nextInt(kShortAdhkar.length)];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('With Allah')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              'Dawah without shouting. Come as you are.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: BuddyColors.moss,
              ),
            ),
            const SizedBox(height: 18),
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _nudge.arabic,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _nudge.translation,
                    style: theme.textTheme.titleLarge,
                  ),
                  if (_nudge.source.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _nudge.source,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: BuddyColors.warm,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(_nudge.reflection, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => setState(_reshuffle),
                    child: const Text('Another reminder'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dhikr for this breath', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(_adhkar, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () {
                context.read<BuddyState>().askDawah();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sent a deen note into your chat.'),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: BuddyColors.moss,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Ask Buddy for a soft dawah message'),
            ),
            const SizedBox(height: 20),
            Text(
              'Short truths',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            ...kDawahCheckIns.take(4).map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _Panel(
                  child: Text(line, style: theme.textTheme.bodyMedium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
