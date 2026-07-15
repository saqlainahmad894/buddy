import 'dart:math';

import '../data/islamic_content.dart';
import '../data/offline_responses.dart';
import '../models/user_profile.dart';
import 'gemini_service.dart';

class BuddyEngine {
  BuddyEngine({GeminiService? gemini}) : _gemini = gemini ?? GeminiService();

  final GeminiService _gemini;
  final _rng = Random();

  String pick(List<String> list) => list[_rng.nextInt(list.length)];

  String welcome(UserProfile profile) {
    final name = profile.name.isEmpty ? 'friend' : profile.name;
    final personal = <String>[];
    if (profile.aboutMe.trim().isNotEmpty) {
      personal.add('I’ll remember this about you: ${profile.aboutMe.trim()}');
    }
    if (profile.whatHelps.trim().isNotEmpty) {
      personal.add('What helps you: ${profile.whatHelps.trim()}');
    }
    if (profile.struggles.trim().isNotEmpty) {
      personal.add('I’ll keep this in mind: ${profile.struggles.trim()}');
    }
    final personalBlock =
        personal.isEmpty ? '' : '\n\n${personal.join('\n')}';

    return '${pick(OfflineBank.openings)}\n\n'
        'I’m ${profile.buddyName} — a companion for your day, habits, and deen. '
        'Your connection with Allah is direct; I’m just here to support you.\n\n'
        'Assalamu alaikum, $name. You can text, send a voice note, share a photo, '
        'or ask for a reminder.$personalBlock';
  }

  String checkIn(UserProfile profile) {
    final name = profile.name.isEmpty ? '' : ' ${profile.name}';
    return pick(OfflineBank.checkIns).replaceFirst('you?', 'you$name?');
  }

  String habitNudge(String habitTitle) {
    final lines = [
      'Reminder: “$habitTitle”. A small step still counts.',
      'Soft tap: “$habitTitle” is on your list when you’re ready.',
      'Habit check: “$habitTitle”. Progress over perfection.',
    ];
    return pick(lines);
  }

  String photoCompliment() => pick(OfflineBank.photoCompliments);

  String islamicBite() {
    final n = kIslamicNudges[_rng.nextInt(kIslamicNudges.length)];
    final src = n.source.isEmpty ? '' : '\n— ${n.source}';
    return '${n.arabic}\n\n${n.translation}$src\n\n${n.reflection}';
  }

  String dawahPing() => pick(kDawahCheckIns);

  Future<String> reply({
    required String userText,
    required UserProfile profile,
    required List<String> recentContext,
    String? imageHint,
  }) async {
    if (profile.useOnlineAi && profile.geminiApiKey.trim().isNotEmpty) {
      try {
        final online = await _gemini.chat(
          apiKey: profile.geminiApiKey.trim(),
          profile: profile,
          userMessage: userText,
          recentContext: recentContext,
          imageHint: imageHint,
        );
        if (online != null && online.trim().isNotEmpty) {
          return online.trim();
        }
      } catch (_) {
        // Fall through to offline replies.
      }
    }

    return offlineReply(userText, profile, imageHint: imageHint);
  }

  String offlineReply(
    String userText,
    UserProfile profile, {
    String? imageHint,
  }) {
    if (imageHint != null) {
      return '${photoCompliment()}\n\n'
          'Thanks for sharing the photo. I’m glad you did.';
    }

    final lower = userText.toLowerCase();
    final name = profile.name.isEmpty ? 'brother' : profile.name;
    final chunks = <String>[];

    for (final entry in OfflineBank.keywordReplies.entries) {
      if (lower.contains(entry.key)) {
        chunks.add(pick(entry.value));
        break;
      }
    }

    if (lower.contains('compliment') ||
        lower.contains('look good') ||
        lower.contains('do i look')) {
      chunks.add(photoCompliment());
    }

    if (lower.contains('trauma') ||
        lower.contains('childhood') ||
        lower.contains('memory')) {
      chunks.add(pick(OfflineBank.traumaHold));
    }

    if (lower.contains('nobody') ||
        lower.contains('appreciate') ||
        lower.contains('ignored') ||
        lower.contains('valued')) {
      chunks.add(pick(OfflineBank.appreciation));
    }

    if (lower.contains('correct me') ||
        lower.contains('be honest') ||
        lower.contains('am i wrong')) {
      chunks.add(pick(OfflineBank.correctionSoft));
    }

    if (lower.contains('deen') ||
        lower.contains('islam') ||
        lower.contains('quran') ||
        lower.contains('dua') ||
        lower.contains('iman')) {
      chunks.add(islamicBite());
    }

    if (chunks.isEmpty) {
      chunks.add(pick(OfflineBank.fallback));
      if (_rng.nextBool()) {
        chunks.add(pick(OfflineBank.supportGentle));
      }
    }

    if (profile.whatHelps.trim().isNotEmpty && _rng.nextInt(4) == 0) {
      chunks.add(
        'I’ll keep this in mind — you said this helps: “${profile.whatHelps.trim()}”.',
      );
    }

    final closes = [
      'I’m still here, $name.',
      'You can keep writing whenever you want.',
      'May Allah make it easy. I’m here if you need me.',
      'Want a habit reminder, a dua, or just more listening?',
    ];
    chunks.add(pick(closes));

    return chunks.join('\n\n');
  }
}
