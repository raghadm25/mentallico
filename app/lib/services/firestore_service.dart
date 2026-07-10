import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_state.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ── User profile ───────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> loadProfile() async {
    final uid = _uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  static Future<void> saveProfile({String? name, String? bio}) async {
    final uid = _uid;
    if (uid == null) return;
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (bio  != null) updates['bio']  = bio;
    if (updates.isNotEmpty) {
      await _db.collection('users').doc(uid).update(updates);
    }
  }

  // ── Journal entries ────────────────────────────────────────────────────────

  static CollectionReference _journalCol(String uid) =>
      _db.collection('users').doc(uid).collection('journal_entries');

  static Future<List<JournalEntry>> loadJournalEntries() async {
    final uid = _uid;
    if (uid == null) return [];
    return loadJournalEntriesFor(uid);
  }

  static Future<String> addJournalEntry(JournalEntry e) =>
      addJournalEntryFor(_uid ?? '', e);

  static Future<String> addJournalEntryFor(String uid, JournalEntry e) async {
    if (uid.isEmpty) return '';
    final ref = await _journalCol(uid).add({
      'title':   e.title,
      'content': e.content,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  static JournalEntry _journalEntryFromDoc(
      String id, Map<String, dynamic> d) =>
      JournalEntry(
        id:      id,
        date:    (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        title:   d['title']   as String? ?? '',
        content: d['content'] as String? ?? '',
      );

  static Future<List<JournalEntry>> loadJournalEntriesFor(String uid) async {
    final snap = await _journalCol(uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((doc) =>
            _journalEntryFromDoc(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  static Stream<List<JournalEntry>> journalEntriesStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _journalCol(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => _journalEntryFromDoc(
                doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  static Future<void> updateJournalEntry(JournalEntry e) async {
    final uid = _uid;
    if (uid == null || e.id.isEmpty) return;
    await _journalCol(uid).doc(e.id).update({
      'title':   e.title,
      'content': e.content,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteJournalEntry(String id) async {
    final uid = _uid;
    if (uid == null || id.isEmpty) return;
    await _journalCol(uid).doc(id).delete();
  }

  // ── Mood log ───────────────────────────────────────────────────────────────

  static CollectionReference _moodCol(String uid) =>
      _db.collection('users').doc(uid).collection('mood_logs');

  static MoodLogEntry _moodEntryFromDoc(Map<String, dynamic> d) =>
      MoodLogEntry(
        face: d['mood'] as int? ?? 0,
        tag:  d['tag']  as String?,
      );

  static Future<Map<String, MoodLogEntry>> loadMoodLog() async {
    final uid = _uid;
    if (uid == null) return {};
    return loadMoodLogFor(uid);
  }

  static Future<Map<String, MoodLogEntry>> loadMoodLogFor(String uid) async {
    final snap = await _moodCol(uid).get();
    return {
      for (final doc in snap.docs)
        doc.id: _moodEntryFromDoc(doc.data() as Map<String, dynamic>)
    };
  }

  static Stream<Map<String, MoodLogEntry>> moodLogStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _moodCol(uid).snapshots().map((snap) => {
          for (final doc in snap.docs)
            doc.id: _moodEntryFromDoc(doc.data() as Map<String, dynamic>)
        });
  }

  static Future<void> logMood(String dateKey, int face, {String? tag}) =>
      logMoodFor(_uid ?? '', dateKey, face, tag: tag);

  /// [extra] merges additional fields (e.g. the richer AI mood analysis)
  /// onto the same day's doc without clobbering the simple face/tag.
  static Future<void> logMoodFor(
    String uid,
    String dateKey,
    int face, {
    String? tag,
    Map<String, dynamic>? extra,
  }) async {
    if (uid.isEmpty) return;
    await _moodCol(uid).doc(dateKey).set({
      'mood': face,
      'tag': tag,
      'recordedAt': FieldValue.serverTimestamp(),
      ...?extra,
    }, SetOptions(merge: true));
  }

  // ── AI-derived notes (mood analysis / diagnostic indicators from AI chat) ──

  static CollectionReference _aiNotesCol(String uid) =>
      _db.collection('users').doc(uid).collection('ai_notes');

  static Future<void> addAiNoteFor(
    String uid, {
    required String analysisResult,
    required String diagnosticSuggestion,
    String source = 'ai_chat',
  }) async {
    if (uid.isEmpty) return;
    await _aiNotesCol(uid).add({
      'analysisResult':       analysisResult,
      'diagnosticSuggestion': diagnosticSuggestion,
      'source':               source,
      'createdAt':            FieldValue.serverTimestamp(),
    });
  }

  static Future<List<Map<String, dynamic>>> loadAiNotesFor(String uid) async {
    if (uid.isEmpty) return [];
    final snap = await _aiNotesCol(uid)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();
    return snap.docs.map((d) => d.data() as Map<String, dynamic>).toList();
  }

  // ── AI chat conversations (persisted drawer history) ────────────────────────

  static CollectionReference _aiChatsCol(String uid) =>
      _db.collection('users').doc(uid).collection('ai_chats');

  static Future<String> createAiChat(String uid, String title) async {
    if (uid.isEmpty) return '';
    final ref = await _aiChatsCol(uid).add({
      'title':     title,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  static Future<void> addAiChatMessage(
    String uid,
    String chatId, {
    required String text,
    required bool isAi,
  }) async {
    if (uid.isEmpty || chatId.isEmpty) return;
    final chatDoc = _aiChatsCol(uid).doc(chatId);
    final batch = _db.batch();
    batch.set(chatDoc.collection('messages').doc(), {
      'text':      text,
      'isAi':      isAi,
      'timestamp': FieldValue.serverTimestamp(),
    });
    batch.set(chatDoc, {
      'updatedAt':   FieldValue.serverTimestamp(),
      'lastMessage': text,
    }, SetOptions(merge: true));
    await batch.commit();
  }

  static Future<List<AiChatMessage>> loadAiChatMessages(
      String uid, String chatId) async {
    if (uid.isEmpty || chatId.isEmpty) return [];
    final snap = await _aiChatsCol(uid)
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      return AiChatMessage(
        text: data['text'] as String? ?? '',
        isAi: data['isAi'] as bool? ?? false,
      );
    }).toList();
  }

  static Stream<List<AiChatSummary>> aiChatsStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _aiChatsCol(uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              return AiChatSummary(
                id:    d.id,
                title: data['title'] as String? ?? 'New Chat',
              );
            }).toList());
  }

  // ── Habits ─────────────────────────────────────────────────────────────────

  static DocumentReference _habitsDoc(String uid) =>
      _db.collection('users').doc(uid).collection('habits').doc('progress');

  static Future<Map<String, double>> loadHabits() async {
    final uid = _uid;
    if (uid == null) return {};
    final doc = await _habitsDoc(uid).get();
    if (!doc.exists) return {};
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return data.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  static Future<void> saveHabits(Map<String, double> habits) async {
    final uid = _uid;
    if (uid == null) return;
    await _habitsDoc(uid).set(Map<String, dynamic>.from(habits));
  }

  // ── Direct chat (patient ↔ therapist outside sessions) ─────────────────────

  static String _chatId(String a, String b) =>
      ([a, b]..sort()).join('_');

  static Stream<QuerySnapshot<Map<String, dynamic>>> chatStream(String otherUid) {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('chats')
        .doc(_chatId(uid, otherUid))
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  static Future<void> sendChatMessage(String otherUid, String text) async {
    final uid = _uid;
    if (uid == null || text.trim().isEmpty) return;
    final chatId = _chatId(uid, otherUid);
    final batch = _db.batch();

    final msgRef = _db.collection('chats').doc(chatId).collection('messages').doc();
    batch.set(msgRef, {
      'senderId':  uid,
      'text':      text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'isRead':    false,
    });

    batch.set(_db.collection('chats').doc(chatId), {
      'participantIds': [uid, otherUid],
      'lastMessage':    text.trim(),
      'lastMessageAt':  FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
  }
}
