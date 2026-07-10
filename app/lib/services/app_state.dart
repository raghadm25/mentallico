import 'dart:async';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart';

// ── Models ────────────────────────────────────────────────────────────────────

/// A single day's mood: the picked face (0-4) and an optional descriptive
/// tag (e.g. "Grateful") — a patient can record a face alone, or a face plus
/// a tag, and both get persisted.
class MoodLogEntry {
  final int face;
  final String? tag;
  const MoodLogEntry({required this.face, this.tag});
}

class JournalEntry {
  final String id;          // Firestore document ID (empty for unsaved entries)
  final DateTime date;
  final String title;
  final String content;
  final List<Uint8List> images;

  JournalEntry({
    this.id = '',
    required this.date,
    required this.content,
    this.title = '',
    List<Uint8List>? images,
  }) : images = images ?? [];

  JournalEntry copyWith({String? id, String? title, String? content}) => JournalEntry(
        id:      id      ?? this.id,
        date:    date,
        title:   title   ?? this.title,
        content: content ?? this.content,
        images:  images,
      );
}

/// One entry in a patient's persisted AI chat history (drawer list).
class AiChatSummary {
  final String id;
  final String title;
  const AiChatSummary({required this.id, required this.title});
}

/// A single saved message within an AI chat conversation.
class AiChatMessage {
  final String text;
  final bool isAi;
  const AiChatMessage({required this.text, required this.isAi});
}

class SharedUserPost {
  final String content;
  final Uint8List? image;
  final bool isAnonymous;
  final DateTime createdAt;
  SharedUserPost({
    required this.content,
    this.image,
    this.isAnonymous = false,
  }) : createdAt = DateTime.now();
}

// ── Singleton state ───────────────────────────────────────────────────────────

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._();

  AppState._();

  bool _loaded = false;
  StreamSubscription<Map<String, MoodLogEntry>>? _moodSub;
  StreamSubscription<List<JournalEntry>>? _journalSub;

  // ── Profile ───────────────────────────────────────────────────────────────
  String userName = 'Jane Doe';
  String userBio =
      "I'm Jane Doe, currently seeking support for anxiety and stress management. I enjoy reading, yoga, and spending time with friends.";

  void updateProfile({String? name, String? bio}) {
    if (name != null) userName = name;
    if (bio  != null) userBio  = bio;
    notifyListeners();
    FirestoreService.saveProfile(name: name, bio: bio);
  }

  // ── Journal ───────────────────────────────────────────────────────────────
  final List<JournalEntry> _journalEntries = [];
  List<JournalEntry> get journalEntries => List.unmodifiable(_journalEntries);

  Future<void> addJournalEntry(JournalEntry entry) async {
    final id = await FirestoreService.addJournalEntry(entry);
    _journalEntries.insert(0, entry.copyWith(id: id));
    notifyListeners();
  }

  Future<void> updateJournalEntry(int index, JournalEntry updated) async {
    if (index < 0 || index >= _journalEntries.length) return;
    _journalEntries[index] = updated;
    notifyListeners();
    await FirestoreService.updateJournalEntry(updated);
  }

  Future<void> deleteJournalEntry(int index) async {
    if (index < 0 || index >= _journalEntries.length) return;
    final id = _journalEntries[index].id;
    _journalEntries.removeAt(index);
    notifyListeners();
    await FirestoreService.deleteJournalEntry(id);
  }

  bool hasEntryOn(DateTime d) => _journalEntries.any((e) =>
      e.date.year  == d.year  &&
      e.date.month == d.month &&
      e.date.day   == d.day);

  // ── Mood ──────────────────────────────────────────────────────────────────
  final Map<String, MoodLogEntry> _moodLog = {};
  Map<String, MoodLogEntry> get moodLog => Map.unmodifiable(_moodLog);

  void logMood(DateTime d, int face, {String? tag}) {
    final key = _dateKey(d);
    _moodLog[key] = MoodLogEntry(face: face, tag: tag);
    notifyListeners();
    FirestoreService.logMood(key, face, tag: tag);
  }

  int? getMood(DateTime d) => _moodLog[_dateKey(d)]?.face;
  String? getMoodTag(DateTime d) => _moodLog[_dateKey(d)]?.tag;

  // ── Community interactions ────────────────────────────────────────────────
  final Set<int> likedPosts = {};
  final Set<int> savedPosts = {};
  final List<SharedUserPost> userPosts = [];

  void toggleLike(int idx) {
    likedPosts.contains(idx) ? likedPosts.remove(idx) : likedPosts.add(idx);
    notifyListeners();
  }

  void toggleSave(int idx) {
    savedPosts.contains(idx) ? savedPosts.remove(idx) : savedPosts.add(idx);
    notifyListeners();
  }

  void addUserPost(SharedUserPost post) {
    userPosts.insert(0, post);
    notifyListeners();
  }

  // ── Habit progress ────────────────────────────────────────────────────────
  final Map<String, double> habitProgress = {
    'Practice Gratitude': 0.85,
    'Meditate': 0.65,
    'Workout': 0.45,
  };

  void updateHabitProgress(String title, double progress) {
    habitProgress[title] = progress.clamp(0.0, 1.0);
    notifyListeners();
    FirestoreService.saveHabits(Map.from(habitProgress));
  }

  void addHabit(String title) {
    if (!habitProgress.containsKey(title)) {
      habitProgress[title] = 0.0;
      notifyListeners();
      FirestoreService.saveHabits(Map.from(habitProgress));
    }
  }

  void removeHabit(String title) {
    habitProgress.remove(title);
    notifyListeners();
    FirestoreService.saveHabits(Map.from(habitProgress));
  }

  // ── Load / clear (called by auth flow) ───────────────────────────────────

  Future<void> loadForUser() async {
    if (_loaded) return;
    _loaded = true;

    final profile = await FirestoreService.loadProfile();
    if (profile != null) {
      userName = profile['name'] as String? ?? userName;
      userBio  = profile['bio']  as String? ?? userBio;
    }

    final entries = await FirestoreService.loadJournalEntries();
    _journalEntries
      ..clear()
      ..addAll(entries);

    final mood = await FirestoreService.loadMoodLog();
    _moodLog
      ..clear()
      ..addAll(mood);

    // Live sync: a therapist-ended session can write to this patient's mood
    // log/journal while the patient's app is open — pick those up immediately
    // instead of only on next launch.
    _moodSub?.cancel();
    _moodSub = FirestoreService.moodLogStream().listen((log) {
      _moodLog
        ..clear()
        ..addAll(log);
      notifyListeners();
    });
    _journalSub?.cancel();
    _journalSub = FirestoreService.journalEntriesStream().listen((entries) {
      _journalEntries
        ..clear()
        ..addAll(entries);
      notifyListeners();
    });

    final habits = await FirestoreService.loadHabits();
    if (habits.isNotEmpty) {
      habitProgress
        ..clear()
        ..addAll(habits);
    }

    notifyListeners();
  }

  void clearState() {
    _loaded = false;
    _moodSub?.cancel();
    _moodSub = null;
    _journalSub?.cancel();
    _journalSub = null;
    userName = 'Jane Doe';
    userBio  = '';
    _journalEntries.clear();
    _moodLog.clear();
    likedPosts.clear();
    savedPosts.clear();
    userPosts.clear();
    habitProgress
      ..clear()
      ..addAll({'Practice Gratitude': 0.85, 'Meditate': 0.65, 'Workout': 0.45});
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
