import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user_profile.dart';

/// Optional free-tier Gemini. User pastes their own key from Google AI Studio.
class GeminiService {
  Future<String?> chat({
    required String apiKey,
    required UserProfile profile,
    required String userMessage,
    required List<String> recentContext,
    String? imageHint,
  }) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
    );

    final system = '''
You are "${profile.buddyName}", a calm companion app for ${profile.name}.
Tone: ${profile.languageTone}. Warm friend (not romantic/flirty/sexual).
Keep replies generic and supportive — daily life, habits, deen, encouragement.
Do NOT center "drama", jealousy narratives, or "safe house between him and Allah".
His relationship with Allah is direct; you only support routines and listening.
Do not trash-talk other people. Validate feelings briefly, then be practical and kind.
Personal notes:
- About: ${profile.aboutMe.isEmpty ? 'not set' : profile.aboutMe}
- What helps: ${profile.whatHelps.isEmpty ? 'not set' : profile.whatHelps}
- Notes: ${profile.struggles.isEmpty ? 'not set' : profile.struggles}
If active self-harm intent: urge real-world help + Allah's mercy.
2–4 short paragraphs.
''';

    final history = recentContext.take(8).join('\n');
    final imageLine = imageHint == null
        ? ''
        : '\nUser shared a photo. Compliment briefly like a friend.';

    final body = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {
              'text':
                  '$system\n\nRecent chat:\n$history\n\nUser: $userMessage$imageLine\n\n${profile.buddyName}:',
            }
          ],
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 420,
      },
    };

    final res = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) return null;

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return null;
    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List?;
    if (parts == null || parts.isEmpty) return null;
    return parts.first['text'] as String?;
  }
}
