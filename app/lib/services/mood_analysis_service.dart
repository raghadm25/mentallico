import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mood_analysis.dart';

class MoodAnalysisService {
  // Get a free key at: https://aistudio.google.com/app/apikey
  static const _apiKey = 'AIzaSyAghYuIm3XDc-WNLuAxWlx2E24MbMjxXV';
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  static const _system = '''
You are a clinical mental health analysis assistant supporting licensed therapists during live therapy sessions.
Analyze the patient message and return ONLY a JSON object with this exact structure — no markdown, no explanation:
{
  "primaryMood": "<one of: anxious|depressed|hopeful|neutral|frustrated|sad|calm|confused|resistant|reflective|distressed>",
  "intensity": <integer 0-10>,
  "mentalHealthIndicators": ["<e.g. sleep_issues, social_isolation, low_self_worth, hopelessness, negative_self_talk, anhedonia>"],
  "riskLevel": "<none|low|moderate|high>",
  "riskFlags": ["<verbatim concerning phrase if any, else empty array>"],
  "themes": ["<e.g. work_stress, relationships, grief, self_esteem, family, trauma, identity>"],
  "clinicalNote": "<one concise clinical observation for the therapist>"
}
Rules:
- riskLevel "high": only when clear self-harm / suicidal ideation / immediate danger.
- riskLevel "moderate": persistent hopelessness, significant distress, or notable withdrawal.
- riskLevel "low": mild negative affect without alarming content.
- Return valid JSON only. No markdown code blocks, no extra text.
''';

  Future<MoodResult> analyze(String message, List<String> priorMessages) async {
    final context = priorMessages.isNotEmpty
        ? 'Prior patient messages this session:\n${priorMessages.map((m) => '• "$m"').join('\n')}\n\n'
        : '';

    final response = await http.post(
      Uri.parse('$_endpoint?key=$_apiKey'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'systemInstruction': {
          'parts': [
            {'text': _system},
          ],
        },
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': '${context}Analyze this patient message: "$message"'},
            ],
          },
        ],
        'generationConfig': {'temperature': 0.1, 'maxOutputTokens': 512},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini API error ${response.statusCode}: ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final raw =
        ((body['candidates'] as List).first['content']['parts'] as List)
                .first['text']
            as String;

    // Strip markdown code fences if Gemini wraps the JSON
    final cleaned = raw.replaceAll(RegExp(r'```json\s*|```\s*'), '').trim();

    return MoodResult.fromJson(jsonDecode(cleaned) as Map<String, dynamic>);
  }
}
