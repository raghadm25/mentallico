import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/config.dart';

class CloudSpeechService {
  static const _url =
      'https://speech.googleapis.com/v1/speech:recognize?key=';

  /// Sends a WAV file (16 kHz, mono, 16-bit PCM) to Google Cloud STT.
  /// Returns the transcript, or null if recognition failed or key is unset.
  static Future<String?> transcribeWav(String wavFilePath) async {
    if (AppConfig.googleCloudApiKey.isEmpty) return null;

    final bytes = await File(wavFilePath).readAsBytes();
    // WAV header is exactly 44 bytes — strip it for LINEAR16 raw PCM.
    if (bytes.length <= 44) return null;
    final pcmBase64 = base64Encode(bytes.sublist(44));

    final body = jsonEncode({
      'config': {
        'encoding': 'LINEAR16',
        'sampleRateHertz': 16000,
        'languageCode': 'en-US',
        'model': 'latest_short',
        'enableAutomaticPunctuation': true,
      },
      'audio': {'content': pcmBase64},
    });

    try {
      final response = await http
          .post(
            Uri.parse('$_url${AppConfig.googleCloudApiKey}'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List?;
      if (results == null || results.isEmpty) return null;

      final alternatives = results[0]['alternatives'] as List?;
      if (alternatives == null || alternatives.isEmpty) return null;

      return (alternatives[0]['transcript'] as String?)?.trim();
    } catch (_) {
      return null;
    }
  }
}
