import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';

import '../models/user_profile.dart';

class PrayerSlot {
  const PrayerSlot({required this.name, required this.time});

  final String name;
  final DateTime time;

  String get timeLabel => DateFormat.jm().format(time);
}

class DayPrayers {
  const DayPrayers({
    required this.slots,
    required this.next,
    required this.countdown,
  });

  final List<PrayerSlot> slots;
  final PrayerSlot? next;
  final Duration? countdown;
}

class PrayerService {
  DayPrayers forProfile(UserProfile profile, {DateTime? now}) {
    final when = now ?? DateTime.now();
    final coords = Coordinates(profile.latitude, profile.longitude);
    final params = _params(profile);
    final date = DateComponents(when.year, when.month, when.day);
    final times = PrayerTimes(coords, date, params);

    final slots = <PrayerSlot>[
      PrayerSlot(name: 'Fajr', time: times.fajr),
      PrayerSlot(name: 'Sunrise', time: times.sunrise),
      PrayerSlot(name: 'Dhuhr', time: times.dhuhr),
      PrayerSlot(name: 'Asr', time: times.asr),
      PrayerSlot(name: 'Maghrib', time: times.maghrib),
      PrayerSlot(name: 'Isha', time: times.isha),
    ];

    PrayerSlot? next;
    for (final s in slots) {
      if (s.name == 'Sunrise') continue;
      if (s.time.isAfter(when)) {
        next = s;
        break;
      }
    }
    next ??= PrayerSlot(
      name: 'Fajr',
      time: times.fajr.add(const Duration(days: 1)),
    );

    return DayPrayers(
      slots: slots,
      next: next,
      countdown: next.time.difference(when),
    );
  }

  CalculationParameters _params(UserProfile profile) {
    final method = switch (profile.calcMethod) {
      'karachi' => CalculationMethod.karachi,
      'egypt' => CalculationMethod.egyptian,
      'umm_al_qura' => CalculationMethod.umm_al_qura,
      'dubai' => CalculationMethod.dubai,
      'moon_sighting' => CalculationMethod.moon_sighting_committee,
      'north_america' => CalculationMethod.north_america,
      'kuwait' => CalculationMethod.kuwait,
      'qatar' => CalculationMethod.qatar,
      'singapore' => CalculationMethod.singapore,
      'turkey' => CalculationMethod.turkey,
      'tehran' => CalculationMethod.tehran,
      _ => CalculationMethod.muslim_world_league,
    };
    final params = method.getParameters();
    params.madhab =
        profile.madhab == 'shafi' ? Madhab.shafi : Madhab.hanafi;
    return params;
  }
}
