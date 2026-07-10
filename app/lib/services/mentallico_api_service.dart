import 'dart:convert';
import 'package:http/http.dart' as http;

/// Result of a single turn against the real `/api/v2/session/{id}/message`
/// endpoint — carries both the conversational reply and whatever diagnostic
/// signal the backend has derived so far for the session.
class MentallicoChatResponse {
  final String response;
  final String? diagnosis;
  final double confidence;
  final String urgency;
  final String? predictedLabel;
  /// Full decoded response body, kept alongside the typed fields above so
  /// callers can defensively look up keys (e.g. a future `diagnostic_signal`
  /// field) that aren't modeled here yet.
  final Map<String, dynamic> raw;

  const MentallicoChatResponse({
    required this.response,
    this.diagnosis,
    required this.confidence,
    required this.urgency,
    this.predictedLabel,
    this.raw = const {},
  });
}

class MentallicoAnalysisResult {
  final String analysisResult;
  final String diagnosticSuggestion;

  const MentallicoAnalysisResult({
    required this.analysisResult,
    required this.diagnosticSuggestion,
  });
}

class MentallicoApiService {
  static const _baseUrl = 'https://ziad9022-mentallico-api-v2.hf.space';

  static Future<String> createSession() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v2/session/create'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Mentallico API error ${response.statusCode}: ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['session_id'] as String;
  }

  /// Sends one message within an existing session. Reuse the same
  /// [sessionId] across a conversation — the backend needs several turns
  /// in the same session before it produces a confirmed diagnosis.
  static Future<MentallicoChatResponse> sendSessionMessage(
    String sessionId,
    String text,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v2/session/$sessionId/message'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Mentallico API error ${response.statusCode}: ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final internal = data['internal'] as Map<String, dynamic>?;
    final prediction = internal?['current_prediction'] as Map<String, dynamic>?;
    return MentallicoChatResponse(
      response: data['response'] as String? ?? '',
      diagnosis: data['diagnosis'] as String?,
      confidence: (data['confidence'] as num?)?.toDouble() ?? 0,
      urgency: data['urgency'] as String? ?? 'normal',
      predictedLabel: prediction?['label'] as String?,
      raw: data,
    );
  }

  /// Convenience one-shot call in a throwaway session (no cross-turn
  /// memory). Prefer [createSession] + [sendSessionMessage] when the
  /// caller can hold onto a session id across a whole conversation.
  static Future<String> sendMessage(String input) async {
    final sessionId = await createSession();
    final result = await sendSessionMessage(sessionId, input);
    return result.response;
  }

  static Future<MentallicoAnalysisResult> analyzeMessage(String input) async {
    final sessionId = await createSession();
    final result = await sendSessionMessage(sessionId, input);
    return MentallicoAnalysisResult(
      analysisResult:
          result.diagnosis ?? result.predictedLabel ?? 'Assessment in progress',
      diagnosticSuggestion: result.response,
    );
  }
}
