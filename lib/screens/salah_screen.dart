import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/islamic_content.dart';
import '../state/buddy_state.dart';
import '../theme/buddy_theme.dart';
import '../widgets/atmosphere.dart';

class SalahScreen extends StatefulWidget {
  const SalahScreen({super.key});

  @override
  State<SalahScreen> createState() => _SalahScreenState();
}

class _SalahScreenState extends State<SalahScreen> {
  late IslamicNudge _nudge;

  @override
  void initState() {
    super.initState();
    _nudge = kIslamicNudges[Random().nextInt(kIslamicNudges.length)];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BuddyState>().refreshPrayers();
    });
  }

  String _fmtCountdown(Duration? d) {
    if (d == null) return '';
    if (d.isNegative) return 'now';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BuddyState>();
    final theme = Theme.of(context);
    final day = state.todayPrayers;
    final city = state.profile.cityName.isEmpty
        ? 'Set your city in Settings'
        : state.profile.cityName;

    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Salah'),
          actions: [
            IconButton(
              onPressed: () => state.refreshPrayers(),
              icon: const Icon(Icons.refresh_rounded),
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
                  Text(city, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 6),
                  if (day?.next != null) ...[
                    Text(
                      'Next: ${day!.next!.name}',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: BuddyColors.warm,
                      ),
                    ),
                    Text(
                      '${day.next!.timeLabel} · in ${_fmtCountdown(day.countdown)}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ] else
                    Text(
                      'Prayer times need your location in Settings.',
                      style: theme.textTheme.bodyLarge,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    state.profile.prayerRemindersEnabled
                        ? 'Reminders on · ${state.profile.minutesBeforePrayer} min before'
                        : 'Reminders off — enable in Settings',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: BuddyColors.sage,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (day != null)
              SoftPanel(
                child: Column(
                  children: day.slots.map((s) {
                    final isNext = day.next?.name == s.name;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              s.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: isNext ? BuddyColors.warm : null,
                                fontWeight:
                                    isNext ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            s.timeLabel,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: isNext ? BuddyColors.warm : null,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 18),
            SoftPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _nudge.arabic,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 10),
                  Text(_nudge.translation, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(_nudge.reflection, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => setState(() {
                      _nudge = kIslamicNudges[
                          Random().nextInt(kIslamicNudges.length)];
                    }),
                    child: const Text('Another reminder'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => state.askDawah(),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Open chat with reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
