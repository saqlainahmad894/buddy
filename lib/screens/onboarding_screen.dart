import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/buddy_state.dart';
import '../theme/buddy_theme.dart';
import '../widgets/atmosphere.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameCtrl = TextEditingController();
  final _buddyCtrl = TextEditingController(text: 'Buddy');
  final _aboutCtrl = TextEditingController();
  final _helpsCtrl = TextEditingController();
  final _strugglesCtrl = TextEditingController();
  int _step = 0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _buddyCtrl.dispose();
    _aboutCtrl.dispose();
    _helpsCtrl.dispose();
    _strugglesCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.read<BuddyState>().completeOnboarding(
          name: _nameCtrl.text,
          buddyName: _buddyCtrl.text,
          aboutMe: _aboutCtrl.text,
          whatHelps: _helpsCtrl.text,
          struggles: _strugglesCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: switch (_step) {
              0 => _HeroStep(
                  key: const ValueKey(0),
                  onNext: () => setState(() => _step = 1),
                ),
              1 => _SetupStep(
                  key: const ValueKey(1),
                  nameCtrl: _nameCtrl,
                  buddyCtrl: _buddyCtrl,
                  onBack: () => setState(() => _step = 0),
                  onNext: () => setState(() => _step = 2),
                ),
              _ => _PersonalStep(
                  key: const ValueKey(2),
                  aboutCtrl: _aboutCtrl,
                  helpsCtrl: _helpsCtrl,
                  strugglesCtrl: _strugglesCtrl,
                  onBack: () => setState(() => _step = 1),
                  onFinish: _finish,
                ),
            },
          ),
        ),
      ),
    );
  }
}

class _HeroStep extends StatelessWidget {
  const _HeroStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              'assets/brand/buddy_logo.png',
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          Text('Buddy', style: theme.textTheme.displayLarge),
          const SizedBox(height: 12),
          Text(
            'A calm companion\nfor your day and deen.',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: BuddyColors.sage,
              height: 1.25,
            ),
          ),
          const Spacer(),
          Text(
            'Chat, voice notes, habits, salah reminders — private on your phone. '
            'Your connection with Allah stays direct; Buddy only supports you.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                backgroundColor: BuddyColors.moss,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Get started'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetupStep extends StatelessWidget {
  const _SetupStep({
    super.key,
    required this.nameCtrl,
    required this.buddyCtrl,
    required this.onBack,
    required this.onNext,
  });

  final TextEditingController nameCtrl;
  final TextEditingController buddyCtrl;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(onPressed: onBack, child: const Text('Back')),
          Text('Tell me your name', style: theme.textTheme.displayMedium),
          const SizedBox(height: 8),
          Text(
            'Everything stays on this phone. Free. Offline by default.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          TextField(
            controller: nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Your name'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: buddyCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'What should I be called?',
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                backgroundColor: BuddyColors.warm,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Personalize me'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalStep extends StatelessWidget {
  const _PersonalStep({
    super.key,
    required this.aboutCtrl,
    required this.helpsCtrl,
    required this.strugglesCtrl,
    required this.onBack,
    required this.onFinish,
  });

  final TextEditingController aboutCtrl;
  final TextEditingController helpsCtrl;
  final TextEditingController strugglesCtrl;
  final VoidCallback onBack;
  final Future<void> Function() onFinish;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
      child: ListView(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: onBack, child: const Text('Back')),
          ),
          Text('So I know you', style: theme.textTheme.displayMedium),
          const SizedBox(height: 8),
          Text(
            'Optional — but this makes Buddy feel like yours.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: aboutCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'About you',
              hintText: 'Who you are in a few lines…',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: helpsCtrl,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'What makes you feel valued',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: strugglesCtrl,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Soft spots to remember',
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () => onFinish(),
            style: FilledButton.styleFrom(
              backgroundColor: BuddyColors.moss,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text('I’m ready'),
          ),
        ],
      ),
    );
  }
}
