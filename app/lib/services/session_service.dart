import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SessionService {
  static final _db = FirebaseFirestore.instance;
  static String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  // ── Therapist opens a VR session ─────────────────────────────────────────
  // Status starts as 'therapist_ready'. Patient sees it and can join.
  // Session only becomes 'active' when BOTH sides are present.
  static Future<String> createSession({
    required String therapistName,
    String patientName = '',
  }) async {
    final doc = await _db.collection('sessions').add({
      'type':            'therapist',
      'therapistName':   therapistName,
      'therapistId':     _uid,
      'patientName':     patientName,
      'patientId':       '',
      'status':          'therapist_ready',
      'therapistJoined': true,
      'patientJoined':   false,
      'createdAt':       FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // ── Patient joins a therapist session ────────────────────────────────────
  // Marks patientJoined. Because therapistJoined is already true, the session
  // becomes 'active' immediately — both sides are now live.
  static Future<void> joinSession(String sessionId,
      {String patientName = ''}) async {
    await _db.collection('sessions').doc(sessionId).update({
      'patientJoined': true,
      'patientId':     _uid,
      if (patientName.isNotEmpty) 'patientName': patientName,
      'status':        'active',
      'startedAt':     FieldValue.serverTimestamp(),
    });
  }

  // ── AI session ───────────────────────────────────────────────────────────
  static Future<String> createAISession({required String patientName}) async {
    final doc = await _db.collection('sessions').add({
      'type':            'ai',
      'patientName':     patientName,
      'patientId':       _uid,
      'therapistName':   'AI Therapist',
      'therapistId':     '',
      'status':          'active',
      'therapistJoined': true,
      'patientJoined':   true,
      'createdAt':       FieldValue.serverTimestamp(),
      'startedAt':       FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // ── Shared ───────────────────────────────────────────────────────────────

  static Future<void> endSession(String sessionId) async {
    await _db.collection('sessions').doc(sessionId).update({
      'status':  'ended',
      'endedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> sendMessage({
    required String sessionId,
    required String text,
    required String sender,
    Map<String, dynamic>? mood,
  }) async {
    await _db
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .add({
      'text':      text,
      'sender':    sender,
      'type':      'text',
      'timestamp': FieldValue.serverTimestamp(),
      if (mood != null) 'mood': mood,
    });
  }

  static Future<void> sendVoiceMessage({
    required String sessionId,
    required String audioUrl,
    String? transcript,
  }) async {
    await _db
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .add({
      'text':      transcript ?? '',
      'sender':    'therapist',
      'type':      'voice',
      'audioUrl':  audioUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(
      String sessionId) {
    return _db
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  static Future<void> saveDoctorNote({
    required String sessionId,
    required String analysisResult,
    required String diagnosticSuggestion,
  }) async {
    await _db
        .collection('sessions')
        .doc(sessionId)
        .collection('notes')
        .add({
      'analysisResult':       analysisResult,
      'diagnosticSuggestion': diagnosticSuggestion,
      'timestamp':            FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> doctorNotesStream(
      String sessionId) {
    return _db
        .collection('sessions')
        .doc(sessionId)
        .collection('notes')
        .orderBy('timestamp')
        .snapshots();
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> sessionStream(
      String sessionId) {
    return _db.collection('sessions').doc(sessionId).snapshots();
  }

  // ── Therapist streams ────────────────────────────────────────────────────

  // All open + active sessions the logged-in therapist owns.
  // Sorted client-side to avoid requiring a composite Firestore index.
  static Stream<QuerySnapshot<Map<String, dynamic>>> myTherapistSessionsStream() {
    return _db
        .collection('sessions')
        .where('therapistId', isEqualTo: _uid)
        .snapshots();
  }

  // ── Patient streams ──────────────────────────────────────────────────────

  // Sessions a patient can join: therapist has opened the room and is waiting.
  static Stream<QuerySnapshot<Map<String, dynamic>>> availableSessionsStream() {
    return _db
        .collection('sessions')
        .where('type', isEqualTo: 'therapist')
        .where('status', isEqualTo: 'therapist_ready')
        .snapshots();
  }

  // Therapists who are currently available (shown in patient's browse list).
  static Stream<QuerySnapshot<Map<String, dynamic>>> availableTherapistsStream() {
    return _db
        .collection('therapists')
        .where('available', isEqualTo: true)
        .snapshots();
  }
}
