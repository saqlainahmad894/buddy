class UserProfile {
  UserProfile({
    required this.name,
    required this.onboarded,
    this.buddyName = 'Buddy',
    this.geminiApiKey = '',
    this.useOnlineAi = false,
    this.checkInsEnabled = true,
    this.dawahEnabled = true,
    this.habitsEnabled = true,
    this.languageTone = 'gentle',
    this.darkMode = false,
    this.aboutMe = '',
    this.whatHelps = '',
    this.struggles = '',
    this.cityName = '',
    this.latitude = 21.4225,
    this.longitude = 39.8262,
    this.prayerRemindersEnabled = true,
    this.minutesBeforePrayer = 15,
    this.calcMethod = 'muslim_world_league',
    this.madhab = 'hanafi',
    this.dayCheckInHour = 11,
    this.dayCheckInMinute = 30,
    this.eveningCheckInHour = 21,
    this.eveningCheckInMinute = 0,
    this.dawahHour = 14,
    this.dawahMinute = 15,
    this.sceneryHour = 16,
    this.sceneryMinute = 0,
    this.scrollHour = 20,
    this.scrollMinute = 15,
    this.journalHour = 21,
    this.journalMinute = 30,
  });

  final String name;
  final bool onboarded;
  final String buddyName;
  final String geminiApiKey;
  final bool useOnlineAi;
  final bool checkInsEnabled;
  final bool dawahEnabled;
  final bool habitsEnabled;
  final String languageTone;
  final bool darkMode;
  final String aboutMe;
  final String whatHelps;
  final String struggles;
  final String cityName;
  final double latitude;
  final double longitude;
  final bool prayerRemindersEnabled;
  final int minutesBeforePrayer;
  final String calcMethod;
  final String madhab;

  final int dayCheckInHour;
  final int dayCheckInMinute;
  final int eveningCheckInHour;
  final int eveningCheckInMinute;
  final int dawahHour;
  final int dawahMinute;
  final int sceneryHour;
  final int sceneryMinute;
  final int scrollHour;
  final int scrollMinute;
  final int journalHour;
  final int journalMinute;

  UserProfile copyWith({
    String? name,
    bool? onboarded,
    String? buddyName,
    String? geminiApiKey,
    bool? useOnlineAi,
    bool? checkInsEnabled,
    bool? dawahEnabled,
    bool? habitsEnabled,
    String? languageTone,
    bool? darkMode,
    String? aboutMe,
    String? whatHelps,
    String? struggles,
    String? cityName,
    double? latitude,
    double? longitude,
    bool? prayerRemindersEnabled,
    int? minutesBeforePrayer,
    String? calcMethod,
    String? madhab,
    int? dayCheckInHour,
    int? dayCheckInMinute,
    int? eveningCheckInHour,
    int? eveningCheckInMinute,
    int? dawahHour,
    int? dawahMinute,
    int? sceneryHour,
    int? sceneryMinute,
    int? scrollHour,
    int? scrollMinute,
    int? journalHour,
    int? journalMinute,
  }) {
    return UserProfile(
      name: name ?? this.name,
      onboarded: onboarded ?? this.onboarded,
      buddyName: buddyName ?? this.buddyName,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      useOnlineAi: useOnlineAi ?? this.useOnlineAi,
      checkInsEnabled: checkInsEnabled ?? this.checkInsEnabled,
      dawahEnabled: dawahEnabled ?? this.dawahEnabled,
      habitsEnabled: habitsEnabled ?? this.habitsEnabled,
      languageTone: languageTone ?? this.languageTone,
      darkMode: darkMode ?? this.darkMode,
      aboutMe: aboutMe ?? this.aboutMe,
      whatHelps: whatHelps ?? this.whatHelps,
      struggles: struggles ?? this.struggles,
      cityName: cityName ?? this.cityName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      prayerRemindersEnabled:
          prayerRemindersEnabled ?? this.prayerRemindersEnabled,
      minutesBeforePrayer: minutesBeforePrayer ?? this.minutesBeforePrayer,
      calcMethod: calcMethod ?? this.calcMethod,
      madhab: madhab ?? this.madhab,
      dayCheckInHour: dayCheckInHour ?? this.dayCheckInHour,
      dayCheckInMinute: dayCheckInMinute ?? this.dayCheckInMinute,
      eveningCheckInHour: eveningCheckInHour ?? this.eveningCheckInHour,
      eveningCheckInMinute: eveningCheckInMinute ?? this.eveningCheckInMinute,
      dawahHour: dawahHour ?? this.dawahHour,
      dawahMinute: dawahMinute ?? this.dawahMinute,
      sceneryHour: sceneryHour ?? this.sceneryHour,
      sceneryMinute: sceneryMinute ?? this.sceneryMinute,
      scrollHour: scrollHour ?? this.scrollHour,
      scrollMinute: scrollMinute ?? this.scrollMinute,
      journalHour: journalHour ?? this.journalHour,
      journalMinute: journalMinute ?? this.journalMinute,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'onboarded': onboarded,
        'buddyName': buddyName,
        'geminiApiKey': geminiApiKey,
        'useOnlineAi': useOnlineAi,
        'checkInsEnabled': checkInsEnabled,
        'dawahEnabled': dawahEnabled,
        'habitsEnabled': habitsEnabled,
        'languageTone': languageTone,
        'darkMode': darkMode,
        'aboutMe': aboutMe,
        'whatHelps': whatHelps,
        'struggles': struggles,
        'cityName': cityName,
        'latitude': latitude,
        'longitude': longitude,
        'prayerRemindersEnabled': prayerRemindersEnabled,
        'minutesBeforePrayer': minutesBeforePrayer,
        'calcMethod': calcMethod,
        'madhab': madhab,
        'dayCheckInHour': dayCheckInHour,
        'dayCheckInMinute': dayCheckInMinute,
        'eveningCheckInHour': eveningCheckInHour,
        'eveningCheckInMinute': eveningCheckInMinute,
        'dawahHour': dawahHour,
        'dawahMinute': dawahMinute,
        'sceneryHour': sceneryHour,
        'sceneryMinute': sceneryMinute,
        'scrollHour': scrollHour,
        'scrollMinute': scrollMinute,
        'journalHour': journalHour,
        'journalMinute': journalMinute,
      };

  factory UserProfile.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return UserProfile(name: '', onboarded: false);
    }
    int i(String key, int fallback) => map[key] as int? ?? fallback;

    return UserProfile(
      name: map['name'] as String? ?? '',
      onboarded: map['onboarded'] as bool? ?? false,
      buddyName: map['buddyName'] as String? ?? 'Buddy',
      geminiApiKey: map['geminiApiKey'] as String? ?? '',
      useOnlineAi: map['useOnlineAi'] as bool? ?? false,
      checkInsEnabled: map['checkInsEnabled'] as bool? ?? true,
      dawahEnabled: map['dawahEnabled'] as bool? ?? true,
      habitsEnabled: map['habitsEnabled'] as bool? ?? true,
      languageTone: map['languageTone'] as String? ?? 'gentle',
      darkMode: map['darkMode'] as bool? ?? false,
      aboutMe: map['aboutMe'] as String? ?? '',
      whatHelps: map['whatHelps'] as String? ?? '',
      struggles: map['struggles'] as String? ?? '',
      cityName: map['cityName'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 21.4225,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 39.8262,
      prayerRemindersEnabled: map['prayerRemindersEnabled'] as bool? ?? true,
      minutesBeforePrayer: map['minutesBeforePrayer'] as int? ?? 15,
      calcMethod: map['calcMethod'] as String? ?? 'muslim_world_league',
      madhab: map['madhab'] as String? ?? 'hanafi',
      dayCheckInHour: i('dayCheckInHour', 11),
      dayCheckInMinute: i('dayCheckInMinute', 30),
      eveningCheckInHour: i('eveningCheckInHour', 21),
      eveningCheckInMinute: i('eveningCheckInMinute', 0),
      dawahHour: i('dawahHour', 14),
      dawahMinute: i('dawahMinute', 15),
      sceneryHour: i('sceneryHour', 16),
      sceneryMinute: i('sceneryMinute', 0),
      scrollHour: i('scrollHour', 20),
      scrollMinute: i('scrollMinute', 15),
      journalHour: i('journalHour', 21),
      journalMinute: i('journalMinute', 30),
    );
  }
}
