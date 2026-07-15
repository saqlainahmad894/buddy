import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/buddy_state.dart';
import '../theme/buddy_theme.dart';
import '../widgets/atmosphere.dart';

const _cityPresets = <String, List<double>>{
  'Makkah': [21.4225, 39.8262],
  'Madinah': [24.5247, 39.5692],
  // India (IST)
  'Delhi': [28.6139, 77.2090],
  'Mumbai': [19.0760, 72.8777],
  'Bengaluru': [12.9716, 77.5946],
  'Hyderabad': [17.3850, 78.4867],
  'Chennai': [13.0827, 80.2707],
  'Kolkata': [22.5726, 88.3639],
  'Lucknow': [26.8467, 80.9462],
  'Ahmedabad': [23.0225, 72.5714],
  'Pune': [18.5204, 73.8567],
  'Jaipur': [26.9124, 75.7873],
  'Srinagar': [34.0837, 74.7973],
  'Kochi': [9.9312, 76.2673],
  'Patna': [25.5941, 85.1376],
  'Bhopal': [23.2599, 77.4126],
  // Pakistan
  'Karachi': [24.8607, 67.0011],
  'Lahore': [31.5497, 74.3436],
  'Islamabad': [33.6844, 73.0479],
  // Other
  'Dubai': [25.2048, 55.2708],
  'Istanbul': [41.0082, 28.9784],
  'London': [51.5074, -0.1278],
  'New York': [40.7128, -74.0060],
  'Cairo': [30.0444, 31.2357],
  'Jakarta': [-6.2088, 106.8456],
};

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _name;
  late TextEditingController _buddy;
  late TextEditingController _key;
  late TextEditingController _about;
  late TextEditingController _helps;
  late TextEditingController _struggles;

  @override
  void initState() {
    super.initState();
    final p = context.read<BuddyState>().profile;
    _name = TextEditingController(text: p.name);
    _buddy = TextEditingController(text: p.buddyName);
    _key = TextEditingController(text: p.geminiApiKey);
    _about = TextEditingController(text: p.aboutMe);
    _helps = TextEditingController(text: p.whatHelps);
    _struggles = TextEditingController(text: p.struggles);
  }

  @override
  void dispose() {
    _name.dispose();
    _buddy.dispose();
    _key.dispose();
    _about.dispose();
    _helps.dispose();
    _struggles.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final state = context.read<BuddyState>();
    await state.updateProfile(
      state.profile.copyWith(
        name: _name.text.trim(),
        buddyName: _buddy.text.trim().isEmpty ? 'Buddy' : _buddy.text.trim(),
        geminiApiKey: _key.text.trim(),
        aboutMe: _about.text.trim(),
        whatHelps: _helps.text.trim(),
        struggles: _struggles.text.trim(),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BuddyState>();
    final p = state.profile;
    final theme = Theme.of(context);

    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Settings'),
          actions: [
            TextButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text('Look & feel', style: theme.textTheme.headlineMedium),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Dark mode'),
              subtitle: const Text('Night safe-house lighting'),
              value: p.darkMode,
              activeThumbColor: BuddyColors.sage,
              onChanged: (v) => state.updateProfile(p.copyWith(darkMode: v)),
            ),
            const SizedBox(height: 12),
            Text('You & Buddy', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 10),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Your name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _buddy,
              decoration: const InputDecoration(labelText: 'Buddy’s name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _about,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'About you (personalization)',
                hintText: 'Who you are, what you carry…',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _helps,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'What makes you feel valued',
                hintText: 'Compliments, check-ins, being asked how I am…',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _struggles,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Soft spots Buddy should remember',
                hintText: 'Stress, focus, sleep, consistency…',
              ),
            ),
            const SizedBox(height: 22),
            Text('Salah location', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              key: ValueKey('city-${p.cityName}'),
              initialValue:
                  _cityPresets.containsKey(p.cityName) ? p.cityName : null,
              decoration: const InputDecoration(labelText: 'City preset'),
              items: _cityPresets.keys
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (city) {
                if (city == null) return;
                final coords = _cityPresets[city]!;
                state.updateProfile(
                  p.copyWith(
                    cityName: city,
                    latitude: coords[0],
                    longitude: coords[1],
                  ),
                );
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Prayer reminders'),
              value: p.prayerRemindersEnabled,
              activeThumbColor: BuddyColors.sage,
              onChanged: (v) =>
                  state.updateProfile(p.copyWith(prayerRemindersEnabled: v)),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Remind me ${p.minutesBeforePrayer} min before'),
              subtitle: Slider(
                value: p.minutesBeforePrayer.toDouble(),
                min: 5,
                max: 30,
                divisions: 5,
                label: '${p.minutesBeforePrayer}',
                onChanged: (v) => state.updateProfile(
                  p.copyWith(minutesBeforePrayer: v.round()),
                ),
              ),
            ),
            DropdownButtonFormField<String>(
              key: ValueKey('calc-${p.calcMethod}'),
              initialValue: p.calcMethod,
              decoration: const InputDecoration(labelText: 'Calculation method'),
              items: const [
                DropdownMenuItem(
                  value: 'muslim_world_league',
                  child: Text('Muslim World League'),
                ),
                DropdownMenuItem(value: 'karachi', child: Text('Karachi')),
                DropdownMenuItem(
                  value: 'umm_al_qura',
                  child: Text('Umm al-Qura'),
                ),
                DropdownMenuItem(value: 'egypt', child: Text('Egyptian')),
                DropdownMenuItem(
                  value: 'north_america',
                  child: Text('North America (ISNA)'),
                ),
                DropdownMenuItem(value: 'dubai', child: Text('Dubai')),
                DropdownMenuItem(value: 'turkey', child: Text('Turkey')),
              ],
              onChanged: (v) {
                if (v == null) return;
                state.updateProfile(p.copyWith(calcMethod: v));
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              key: ValueKey('madhab-${p.madhab}'),
              initialValue: p.madhab,
              decoration: const InputDecoration(labelText: 'Asr madhab'),
              items: const [
                DropdownMenuItem(value: 'hanafi', child: Text('Hanafi')),
                DropdownMenuItem(value: 'shafi', child: Text('Shafi / others')),
              ],
              onChanged: (v) {
                if (v == null) return;
                state.updateProfile(p.copyWith(madhab: v));
              },
            ),
            const SizedBox(height: 22),
            Text('Care signals', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(
              'Turn on reminders, then set your own times. '
              'Habits & goals also notify separately.',
              style: theme.textTheme.bodyMedium,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Daily check-ins & lifestyle reminders'),
              value: p.checkInsEnabled,
              activeThumbColor: BuddyColors.sage,
              onChanged: (v) =>
                  state.updateProfile(p.copyWith(checkInsEnabled: v)),
            ),
            if (p.checkInsEnabled) ...[
              _TimeTile(
                label: 'Day check-in',
                hour: p.dayCheckInHour,
                minute: p.dayCheckInMinute,
                onPick: (t) => state.updateProfile(
                  p.copyWith(
                    dayCheckInHour: t.hour,
                    dayCheckInMinute: t.minute,
                  ),
                ),
              ),
              _TimeTile(
                label: 'Evening check-in',
                hour: p.eveningCheckInHour,
                minute: p.eveningCheckInMinute,
                onPick: (t) => state.updateProfile(
                  p.copyWith(
                    eveningCheckInHour: t.hour,
                    eveningCheckInMinute: t.minute,
                  ),
                ),
              ),
              _TimeTile(
                label: 'Scenery / break',
                hour: p.sceneryHour,
                minute: p.sceneryMinute,
                onPick: (t) => state.updateProfile(
                  p.copyWith(sceneryHour: t.hour, sceneryMinute: t.minute),
                ),
              ),
              _TimeTile(
                label: 'Scroll pause',
                hour: p.scrollHour,
                minute: p.scrollMinute,
                onPick: (t) => state.updateProfile(
                  p.copyWith(scrollHour: t.hour, scrollMinute: t.minute),
                ),
              ),
              _TimeTile(
                label: 'Journal reminder',
                hour: p.journalHour,
                minute: p.journalMinute,
                onPick: (t) => state.updateProfile(
                  p.copyWith(journalHour: t.hour, journalMinute: t.minute),
                ),
              ),
            ],
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Islamic reminders'),
              value: p.dawahEnabled,
              activeThumbColor: BuddyColors.sage,
              onChanged: (v) =>
                  state.updateProfile(p.copyWith(dawahEnabled: v)),
            ),
            if (p.dawahEnabled)
              _TimeTile(
                label: 'Islamic reminder time',
                hour: p.dawahHour,
                minute: p.dawahMinute,
                onPick: (t) => state.updateProfile(
                  p.copyWith(dawahHour: t.hour, dawahMinute: t.minute),
                ),
              ),
            const SizedBox(height: 16),
            Text('Optional online AI', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Offline always works. Optional free Gemini key = smarter chats.',
              style: theme.textTheme.bodyMedium,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Use online AI when available'),
              value: p.useOnlineAi,
              activeThumbColor: BuddyColors.sage,
              onChanged: (v) =>
                  state.updateProfile(p.copyWith(useOnlineAi: v)),
            ),
            TextField(
              controller: _key,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Gemini API key (optional)',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.label,
    required this.hour,
    required this.minute,
    required this.onPick,
  });

  final String label;
  final int hour;
  final int minute;
  final ValueChanged<TimeOfDay> onPick;

  String get _label {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text('Tap to change'),
      trailing: Text(
        _label,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: BuddyColors.warm,
              fontWeight: FontWeight.w700,
            ),
      ),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: hour, minute: minute),
        );
        if (picked != null) onPick(picked);
      },
    );
  }
}
