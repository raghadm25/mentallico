import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'firestore_service.dart';
import 'mentallico_api_service.dart';
import 'session_service.dart';

void sendAiResponseToUnity(String aiResponse) {
  final json = jsonEncode({'type': 'ai_response', 'payload': aiResponse});
  sendToUnity('FlutterBridge', 'OnFlutterMessage', json);
}

void sendMedicalNoteToUnity(String diagnosticSuggestion) {
  final json = jsonEncode({'type': 'medical_note', 'payload': diagnosticSuggestion});
  sendToUnity('FlutterBridge', 'OnFlutterMessage', json);
}

/// Owns one running Mentallico API session for the lifetime of a VR call.
/// Every turn is sent into the *same* session_id so the backend keeps
/// conversation context and can build up to a confirmed diagnosis after a
/// few messages — a single call per turn now yields both the reply text and
/// the diagnostic signal (`/api/v2/session/{id}/message` returns both).
///
/// One instance should be created per VR session (owned by
/// ActiveVrSessionScreen's state) and discarded when that session ends.
class VrAiChatSession {
  String? _sessionId;
  int _turn = 0;

  /// Last confirmed `diagnosis` value seen from the backend, if any.
  dynamic _lastDiagnosticSignal;
  dynamic get lastDiagnosticSignal => _lastDiagnosticSignal;

  /// Optional hook so the owning widget can react (e.g. setState) whenever
  /// a new diagnostic signal comes in, without VrAiChatSession knowing
  /// anything about UI state itself.
  void Function(dynamic signal)? onDiagnosticSignal;

  void _log(String message) => debugPrint('[VrAiChatSession] $message');

  /// Fires when the backend's `diagnosis` field goes non-null. Purely
  /// internal to Dart — never touches the Unity {"type", "payload"} envelope.
  void _handleDiagnosticSignal(dynamic signal) {
    _lastDiagnosticSignal = signal;
    onDiagnosticSignal?.call(signal);
  }

  /// Checks the real `diagnosis` field (not the non-existent
  /// `diagnostic_signal` key) every turn, so its null → confirmed
  /// transition is visible in the console during testing.
  void _checkDiagnosticSignal(MentallicoChatResponse response) {
    _log('diagnosis field status: ${response.diagnosis ?? "null (not yet confirmed)"}');
    if (response.diagnosis != null) {
      _handleDiagnosticSignal(response.diagnosis);
    }
  }

  Future<String> _ensureSession() async {
    if (_sessionId != null) return _sessionId!;
    _sessionId = await MentallicoApiService.createSession();
    _log('session created — session_id=$_sessionId');
    return _sessionId!;
  }

  Future<MentallicoChatResponse> _sendWithRetry(String userInput) async {
    final sessionId = await _ensureSession();
    _turn++;
    _log('turn=$_turn using session_id=$sessionId');
    try {
      final response =
          await MentallicoApiService.sendSessionMessage(sessionId, userInput);
      _log('turn=$_turn session_id=$sessionId — success');
      _checkDiagnosticSignal(response);
      return response;
    } catch (e) {
      // The session may have expired/been invalidated server-side —
      // start a fresh one and retry once before giving up.
      _log('turn=$_turn session_id=$sessionId — failed ($e), retrying with '
          'a new session');
      _sessionId = await MentallicoApiService.createSession();
      _log('turn=$_turn retry — new session_id=$_sessionId');
      final response = await MentallicoApiService.sendSessionMessage(
          _sessionId!, userInput);
      _log('turn=$_turn session_id=$_sessionId — retry succeeded');
      _checkDiagnosticSignal(response);
      return response;
    }
  }

  /// Sends [userInput] as the next turn in this VR call's running session,
  /// pushes the AI's reply and any diagnostic note to Unity, and persists
  /// the note to the therapist session + the patient's AI notes.
  Future<MentallicoAnalysisResult> handleUserInput({
    required String vrSessionId,
    required String userInput,
  }) async {
    final chat = await _sendWithRetry(userInput);
    sendAiResponseToUnity(chat.response);

    final result = MentallicoAnalysisResult(
      analysisResult:
          chat.diagnosis ?? chat.predictedLabel ?? 'Assessment in progress',
      diagnosticSuggestion: chat.response,
    );

    sendMedicalNoteToUnity(result.diagnosticSuggestion);

    await SessionService.saveDoctorNote(
      sessionId: vrSessionId,
      analysisResult: result.analysisResult,
      diagnosticSuggestion: result.diagnosticSuggestion,
    );

    final patientUid = FirebaseAuth.instance.currentUser?.uid;
    if (patientUid != null && patientUid.isNotEmpty) {
      await FirestoreService.addAiNoteFor(
        patientUid,
        analysisResult: result.analysisResult,
        diagnosticSuggestion: result.diagnosticSuggestion,
      );
    }

    return result;
  }

  /// Starts a brand-new backend session on the next message (e.g. if the
  /// VR call is restarted without recreating this object).
  void reset() => _sessionId = null;
}
