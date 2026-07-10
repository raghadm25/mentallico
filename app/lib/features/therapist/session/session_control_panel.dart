import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/card_with_shadow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/mood_analysis.dart';
import '../../../services/firestore_service.dart';
import '../../../services/mood_analysis_service.dart';
import '../../../services/session_service.dart';
import '../../../services/app_state.dart' show JournalEntry;
import '../../../services/cloud_speech_service.dart';

// ─── Data models ─────────────────────────────────────────────────────────────

enum SessionMode { vr, responses, notes }

class SessionResponse {
  final String id;
  final String content;
  final bool isVoice;
  final Duration voiceDuration;
  final EmotionTag emotion;
  final DateTime timestamp;
  final bool isNote;

  SessionResponse({
    required this.id,
    required this.content,
    required this.emotion,
    this.isVoice = false,
    this.voiceDuration = Duration.zero,
    required this.timestamp,
    this.isNote = false,
  });
}

class AiNoteEntry {
  final String analysisResult;
  final String diagnosticSuggestion;
  final DateTime timestamp;

  const AiNoteEntry({
    required this.analysisResult,
    required this.diagnosticSuggestion,
    required this.timestamp,
  });
}

class EmotionTag {
  final String label;
  final String emoji;
  final Color color;

  const EmotionTag({
    required this.label,
    required this.emoji,
    required this.color,
  });

  static const anxious =
      EmotionTag(label: 'Anxious', emoji: '😰', color: Color(0xFF7F89E9));
  static const sad =
      EmotionTag(label: 'Sad', emoji: '😢', color: Color(0xFF5C7BD4));
  static const frustrated =
      EmotionTag(label: 'Frustrated', emoji: '😤', color: Color(0xFFE07B5A));
  static const neutral =
      EmotionTag(label: 'Neutral', emoji: '😐', color: Color(0xFF9E9E9E));
  static const calm =
      EmotionTag(label: 'Calm', emoji: '😊', color: Color(0xFF658852));
  static const confused =
      EmotionTag(label: 'Confused', emoji: '😕', color: Color(0xFFA87CC7));
  static const resistant =
      EmotionTag(label: 'Resistant', emoji: '😡', color: Color(0xFFE53935));
  static const reflective =
      EmotionTag(label: 'Reflective', emoji: '🤔', color: Color(0xFF50B8A8));

  static const all = [
    anxious, sad, frustrated, neutral, calm, confused, resistant, reflective,
  ];
}

EmotionTag detectEmotion(String text) {
  final t = text.toLowerCase();
  // Resistant / defensive — check first (most specific)
  if (t.contains(RegExp(
      r'resist|push.?back|refuse|won.?t listen|reject|not ready|can.?t accept|don.?t want to'))) {
    return EmotionTag.resistant;
  }
  // Anxious / stressed / scared
  if (t.contains(RegExp(
      r'worri|anxious|anxiety|nervous|panic|scar|stress|tense|overwhelm|dread|pressure|burden|apprehens|on edge'))) {
    return EmotionTag.anxious;
  }
  // Sad / depressed / hopeless
  if (t.contains(RegExp(
      r'sad|grief|griev|cry|crying|tears|depress|hopeless|loss|losing|miss|lonely|alone|empty|numb|devastat|heartbreak|mourn|feel low|feeling down'))) {
    return EmotionTag.sad;
  }
  // Frustrated / angry
  if (t.contains(RegExp(
      r'angry|anger|frustrat|upset|annoyed|annoy|irritat|rage|furious|resent|bitter|unfair|resentment'))) {
    return EmotionTag.frustrated;
  }
  // Confused / uncertain
  if (t.contains(RegExp(
      r'confus|unclear|uncertain|unsure|not sure|don.?t know|can.?t figure|hard to understand|difficult to understand|mixed up'))) {
    return EmotionTag.confused;
  }
  // Calm / positive / encouraging
  if (t.contains(RegExp(
      r'calm|relax|peace|proud|progress|hopeful|great job|well done|improv|achiev|success|strength|brave|courage|relief|glad|grateful|thankful|wonderful|excellent|amazing|fantastic|good job|positive step|good progress|that.?s great|good news'))) {
    return EmotionTag.calm;
  }
  // Reflective / empathic — catches most therapeutic language
  if (t.contains(RegExp(
      r'understand|i hear|tell me|how do you|what do you|why do you|think about|reflect|consider|realiz|recogni|aware|notice|learn|discover|explore|what if|maybe|perhaps|could be|seem|feel like|sounds like|looks like|appears|pattern|connect|reminds|makes sense|that.?s valid|natural to feel|normal to feel|i.?m here|here for you|go on|say more|interesting|i see'))) {
    return EmotionTag.reflective;
  }
  return EmotionTag.neutral;
}

// ─── Main screen ─────────────────────────────────────────────────────────────

class SessionControlPanel extends StatefulWidget {
  final String sessionId;
  final String patientName;
  final String patientInitials;
  final Color patientColor;
  final String sessionType;
  final String patientId;

  const SessionControlPanel({
    super.key,
    required this.sessionId,
    required this.patientName,
    required this.patientInitials,
    required this.patientColor,
    required this.sessionType,
    this.patientId = '',
  });

  @override
  State<SessionControlPanel> createState() => _SessionControlPanelState();
}

class _SessionControlPanelState extends State<SessionControlPanel>
    with TickerProviderStateMixin {
  // Session timer
  late Timer _timer;
  Duration _elapsed = Duration.zero;

  // Mode — default to VR so therapist sees live view immediately
  SessionMode _mode = SessionMode.vr;

  // Therapist responses sent to the avatar
  final List<SessionResponse> _therapistResponses = [];
  // Patient mood history loaded from Firestore at session start
  final List<SessionResponse> _moodNotes = [];
  // Notes added by therapist during the session
  final List<SessionResponse> _sessionNotes = [];
  // AI-derived indicators from the patient's own mood logs / chatbot use
  final List<AiNoteEntry> _aiNotes = [];
  bool _moodLoaded = false;

  final TextEditingController _textCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final ScrollController _notesScroll = ScrollController();

  // Auto-detected emotion (not manually selectable)
  EmotionTag _detectedEmotion = EmotionTag.neutral;

  // Patient entries from Firestore (speech relayed from Unity)
  final List<PatientEntry> _patientEntries = [];
  final ScrollController _patientScroll = ScrollController();
  final _moodService = MoodAnalysisService();
  RiskLevel _sessionRisk = RiskLevel.none;

  // Firestore listener
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _messagesSub;

  // Recording
  bool _isRecording = false;
  bool _isTranscribing = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _recordingPath;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();

    _loadMoodHistorySummary();
    _loadAiNotes();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _textCtrl.addListener(_onTextChanged);
    _listenToPatientMessages();
  }

  Future<void> _loadMoodHistorySummary() async {
    if (widget.patientId.isEmpty) {
      if (mounted) setState(() => _moodLoaded = true);
      return;
    }
    try {
      final mood = await FirestoreService.loadMoodLogFor(widget.patientId);
      final journal =
          await FirestoreService.loadJournalEntriesFor(widget.patientId);

      if (mood.isEmpty && journal.isEmpty) {
        if (mounted) {
          setState(() {
            _moodNotes.add(SessionResponse(
              id: 'mood-history',
              content: 'No mood history available for this patient yet.',
              emotion: EmotionTag.neutral,
              timestamp: DateTime.now(),
            ));
            _moodLoaded = true;
          });
        }
        return;
      }

      const faceLabels = ['Angry', 'Sad', 'Neutral', 'Happy', 'Amazing'];
      final sortedDates = mood.keys.toList()..sort();
      final recentDates = sortedDates.length > 14
          ? sortedDates.sublist(sortedDates.length - 14)
          : sortedDates;
      final moodLine = recentDates.isEmpty
          ? null
          : 'Recent mood log: ${recentDates.map((d) {
              final e = mood[d]!;
              final label = faceLabels[e.face.clamp(0, 4)];
              return e.tag != null ? '$d=$label ("${e.tag}")' : '$d=$label';
            }).join(', ')}';

      final journalLine = journal.isEmpty
          ? null
          : 'Last journal entry: "${journal.first.content}"';

      final summary =
          [moodLine, journalLine].whereType<String>().join('\n');

      if (mounted) {
        setState(() {
          _moodNotes.add(SessionResponse(
            id: 'mood-history',
            content: summary,
            emotion: EmotionTag.neutral,
            timestamp: DateTime.now(),
          ));
          _moodLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _moodNotes.add(SessionResponse(
            id: 'mood-history',
            content: 'Unable to load mood history for this patient.',
            emotion: EmotionTag.neutral,
            timestamp: DateTime.now(),
          ));
          _moodLoaded = true;
        });
      }
    }
  }

  Future<void> _loadAiNotes() async {
    if (widget.patientId.isEmpty) return;
    try {
      final raw = await FirestoreService.loadAiNotesFor(widget.patientId);
      if (!mounted) return;
      setState(() {
        _aiNotes.addAll(raw.map((d) => AiNoteEntry(
              analysisResult: d['analysisResult'] as String? ?? '',
              diagnosticSuggestion: d['diagnosticSuggestion'] as String? ?? '',
              timestamp: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            )));
      });
    } catch (_) {
      // Best-effort — AI notes are supplementary, not critical to session start.
    }
  }

  void _listenToPatientMessages() {
    _messagesSub =
        SessionService.messagesStream(widget.sessionId).listen(
      (snap) {
        for (final change in snap.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data()!;
            if ((data['sender'] as String?) == 'patient') {
              final text = (data['text'] as String? ?? '').trim();
              final docId = change.doc.id;
              if (text.isNotEmpty) {
                final alreadyExists =
                    _patientEntries.any((e) => e.id == docId);
                if (!alreadyExists) _handleIncomingPatient(text, docId);
              }
            }
          }
        }
      },
      onError: (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Patient messages error: $e')),
          );
        }
      },
    );
  }

  Future<void> _handleIncomingPatient(String text, String docId) async {
    final entry = PatientEntry(
      id: docId,
      text: text,
      timestamp: DateTime.now(),
      isAnalyzing: true,
    );
    if (mounted) {
      setState(() => _patientEntries.add(entry));
      _scrollTo(_patientScroll);
    }
    try {
      final prior = _patientEntries
          .where((e) => e.id != docId && e.mood != null)
          .map((e) => e.text)
          .toList();
      final mood = await _moodService.analyze(text, prior);
      final idx = _patientEntries.indexWhere((e) => e.id == docId);
      if (idx >= 0 && mounted) {
        setState(() {
          _patientEntries[idx] =
              entry.copyWith(mood: mood, isAnalyzing: false);
          if (mood.riskLevel.index > _sessionRisk.index) {
            _sessionRisk = mood.riskLevel;
          }
        });
      }
    } catch (_) {
      final idx = _patientEntries.indexWhere((e) => e.id == docId);
      if (idx >= 0 && mounted) {
        // Gemini unavailable — fall back to keyword detection so the therapist
        // still sees something useful rather than a blank badge.
        final tag = detectEmotion(text);
        final fallback = tag != EmotionTag.neutral
            ? MoodResult(
                primaryMood: tag.label.toLowerCase(),
                intensity: 5,
                indicators: const [],
                riskLevel: RiskLevel.none,
                riskFlags: const [],
                themes: const [],
                clinicalNote: '',
              )
            : null;
        setState(() =>
            _patientEntries[idx] = entry.copyWith(mood: fallback, isAnalyzing: false));
      }
    }
  }

  void _onTextChanged() {
    if (_textCtrl.text.length > 8) {
      final detected = detectEmotion(_textCtrl.text);
      if (detected != _detectedEmotion) {
        setState(() => _detectedEmotion = detected);
      }
    }
  }

  void _addNote() {
    final text = _noteCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _sessionNotes.add(SessionResponse(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: text,
        emotion: EmotionTag.neutral,
        timestamp: DateTime.now(),
        isNote: true,
      ));
      _noteCtrl.clear();
    });
    _scrollTo(_notesScroll);
  }

  @override
  void dispose() {
    _timer.cancel();
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    _textCtrl.dispose();
    _noteCtrl.dispose();
    _scroll.dispose();
    _notesScroll.dispose();
    _patientScroll.dispose();
    _messagesSub?.cancel();
    super.dispose();
  }

  String get _elapsedStr {
    final h = _elapsed.inHours;
    final m = _elapsed.inMinutes % 60;
    final s = _elapsed.inSeconds % 60;
    return h > 0
        ? '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
        : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _dominantMood {
    final analyzed = _patientEntries.where((e) => e.mood != null).toList();
    if (analyzed.isEmpty) return 'neutral';
    final freq = <String, int>{};
    for (final e in analyzed) {
      freq[e.mood!.primaryMood] = (freq[e.mood!.primaryMood] ?? 0) + 1;
    }
    return freq.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  List<String> get _allThemes {
    final set = <String>{};
    for (final e in _patientEntries) {
      if (e.mood != null) set.addAll(e.mood!.themes);
    }
    return set.toList();
  }

  void _scrollTo(ScrollController ctrl) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (ctrl.hasClients) {
        ctrl.animateTo(
          ctrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _submitText() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _therapistResponses.add(SessionResponse(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: text,
        emotion: _detectedEmotion,
        timestamp: DateTime.now(),
      ));
      _textCtrl.clear();
      _detectedEmotion = EmotionTag.neutral;
    });
    _scrollTo(_scroll);
    SessionService.sendMessage(
      sessionId: widget.sessionId,
      text: text,
      sender: 'therapist',
    );
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      _recordingTimer?.cancel();
      final dur = _recordingDuration;
      final filePath = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
      });
      if (filePath != null) {
        _transcribeAndSend(filePath, dur);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording failed — no audio captured')),
        );
      }
    } else {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission required')),
          );
        }
        return;
      }
      final dir = await getTemporaryDirectory();
      _recordingPath =
          '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.wav';
      try {
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: _recordingPath!,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cannot start recording: $e')),
          );
        }
        return;
      }
      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _recordingDuration += const Duration(seconds: 1));
      });
    }
  }

  Future<void> _transcribeAndSend(String filePath, Duration dur) async {
    setState(() => _isTranscribing = true);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    late String audioUrl;
    try {
      final storageRef = FirebaseStorage.instance
          .ref('sessions/${widget.sessionId}/voice/$timestamp.wav');
      try {
        await storageRef.putFile(File(filePath));
        audioUrl = await storageRef.getDownloadURL();
      } catch (e) {
        throw 'Upload failed — check your connection.\n$e';
      }

      // Write to Firestore immediately so Unity gets the URL without waiting
      // for transcription — transcription is optional metadata only.
      try {
        await SessionService.sendVoiceMessage(
          sessionId: widget.sessionId,
          audioUrl: audioUrl,
          transcript: null,
        );
      } catch (e) {
        throw 'Session save failed — message may not reach patient.\n$e';
      }

      if (mounted) {
        setState(() {
          _therapistResponses.add(SessionResponse(
            id: timestamp.toString(),
            content: '🎤 Voice message sent',
            emotion: _detectedEmotion,
            isVoice: true,
            voiceDuration: dur,
            timestamp: DateTime.now(),
          ));
          _detectedEmotion = EmotionTag.neutral;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice message sent to patient'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );
        _scrollTo(_scroll);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTranscribing = false);
    }

    // Best-effort transcription — runs after delivery so it never blocks it.
    // The local file is deleted only after the transcription attempt finishes
    // so the transcription service can still read it.
    CloudSpeechService.transcribeWav(filePath).then((transcript) {
      if (transcript == null || transcript.isEmpty || !mounted) return;
      setState(() {
        final idx = _therapistResponses
            .indexWhere((r) => r.id == timestamp.toString() && r.isVoice);
        if (idx < 0) return;
        final old = _therapistResponses[idx];
        _therapistResponses[idx] = SessionResponse(
          id: old.id,
          content: transcript,
          emotion: old.emotion,
          isVoice: true,
          voiceDuration: old.voiceDuration,
          timestamp: old.timestamp,
        );
      });
    }).catchError((_) {}).whenComplete(() {
      try { File(filePath).deleteSync(); } catch (_) {}
    });
  }

  Future<void> _writeBackToPatient({
    required String dominantMood,
    required List<String> themes,
    required List<String> allRiskFlags,
  }) async {
    if (widget.patientId.isEmpty) return;
    if (_patientEntries.every((e) => e.mood == null)) return;

    final summaryMood = MoodResult(
      primaryMood: dominantMood,
      intensity: 0,
      indicators: const [],
      riskLevel: _sessionRisk,
      riskFlags: allRiskFlags,
      themes: themes,
      clinicalNote: '',
    );
    final now = DateTime.now();
    final dateKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final tag = dominantMood.isEmpty
        ? null
        : '${dominantMood[0].toUpperCase()}${dominantMood.substring(1)}';

    await FirestoreService.logMoodFor(
      widget.patientId,
      dateKey,
      summaryMood.faceIndex,
      tag: tag,
      extra: {
        'source': 'session',
        'primaryMood': dominantMood,
        'riskLevel': _sessionRisk.name,
        if (allRiskFlags.isNotEmpty) 'riskFlags': allRiskFlags,
        if (themes.isNotEmpty) 'themes': themes,
      },
    );

    final noteLines = [
      'Dominant mood: ${tag ?? dominantMood}',
      if (themes.isNotEmpty) 'Themes: ${themes.join(', ')}',
      if (allRiskFlags.isNotEmpty) 'Flagged: ${allRiskFlags.join('; ')}',
    ];
    await FirestoreService.addJournalEntryFor(
      widget.patientId,
      JournalEntry(
        date: now,
        title: 'Session Reflection',
        content: noteLines.join('\n'),
      ),
    );
  }

  void _endSession() {
    final analyzed = _patientEntries.where((e) => e.mood != null).toList();
    final moodTimeline = analyzed.map((e) => e.mood!).toList();
    final allRiskFlags =
        analyzed.expand((e) => e.mood!.riskFlags).toSet().toList();
    final themes = _allThemes;
    final dominant = _dominantMood;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('End Session?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _SummaryRow(
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    value: _elapsedStr),
                _SummaryRow(
                    icon: Icons.chat_bubble_outline,
                    label: 'Patient responses',
                    value: '${_patientEntries.length}'),
                _SummaryRow(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Therapist responses',
                    value: '${_therapistResponses.length}'),
                _SummaryRow(
                    icon: Icons.note_alt_outlined,
                    label: 'Session notes',
                    value: '${_sessionNotes.length}'),

                if (_patientEntries.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  Text('Session Mood',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGray)),
                  const SizedBox(height: 8),

                  if (moodTimeline.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children: moodTimeline
                          .map((m) => Text(m.emoji,
                              style: const TextStyle(fontSize: 20)))
                          .toList(),
                    ),

                  const SizedBox(height: 6),
                  Text(
                    'Dominant: ${dominant[0].toUpperCase()}${dominant.substring(1)}',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppColors.darkGray),
                  ),

                  if (_sessionRisk != RiskLevel.none) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _sessionRisk.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color:
                                _sessionRisk.color.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(_sessionRisk.icon,
                              color: _sessionRisk.color, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            _sessionRisk.label,
                            style: GoogleFonts.poppins(
                                color: _sessionRisk.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    if (allRiskFlags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      ...allRiskFlags.map((f) => Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text('"$f"',
                                style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: AppColors.darkGray,
                                    fontStyle: FontStyle.italic)),
                          )),
                    ],
                  ],

                  if (themes.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: themes
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('#$t',
                                    style: GoogleFonts.poppins(
                                        color: AppColors.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500)),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppColors.darkGray)),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(30),
            ),
            child: ElevatedButton(
              onPressed: () async {
                final nav = Navigator.of(context);
                await _writeBackToPatient(
                  dominantMood: dominant,
                  themes: themes,
                  allRiskFlags: allRiskFlags,
                );
                await SessionService.endSession(widget.sessionId);
                nav.pop();
                nav.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: Text('End Session',
                  style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          if (_sessionRisk.index >= RiskLevel.moderate.index)
            _buildRiskBanner(),
          _buildModeSwitcher(),
          if (_mode == SessionMode.notes) _buildNotesModeContent(),
          if (_mode == SessionMode.responses) _buildResponsesModeContent(),
          if (_mode == SessionMode.vr) _buildLiveModeContent(),
          _buildInputArea(),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final analyzed = _patientEntries.where((e) => e.mood != null).toList();
    final lastMood = analyzed.isNotEmpty ? analyzed.last.mood : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _endSession,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                child: Text(
                  widget.patientInitials,
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.patientName,
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      widget.sessionType,
                      style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (lastMood != null) ...[
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(lastMood.emoji,
                          style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(
                        lastMood.primaryMood[0].toUpperCase() +
                            lastMood.primaryMood.substring(1),
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _LiveBadge(pulse: _pulseAnim),
                  const SizedBox(height: 4),
                  Text(
                    _elapsedStr,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _endSession,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('End',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Risk banner ───────────────────────────────────────────────────────────

  Widget _buildRiskBanner() {
    final isHigh = _sessionRisk == RiskLevel.high;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: _sessionRisk.color.withValues(alpha: isHigh ? 0.15 : 0.1),
      child: Row(
        children: [
          Icon(_sessionRisk.icon, color: _sessionRisk.color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isHigh
                  ? '🚨 HIGH RISK — Patient may be in danger. Consider immediate intervention.'
                  : '⚠️ Moderate risk detected — Review flagged patient statements below.',
              style: GoogleFonts.poppins(
                color: _sessionRisk.color,
                fontSize: 11,
                fontWeight:
                    isHigh ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mode switcher ─────────────────────────────────────────────────────────

  Widget _buildModeSwitcher() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _ModeButton(
            icon: Icons.view_in_ar_rounded,
            label: 'VR',
            active: _mode == SessionMode.vr,
            onTap: () => setState(() => _mode = SessionMode.vr),
          ),
          const SizedBox(width: 10),
          _ModeButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Responses',
            active: _mode == SessionMode.responses,
            onTap: () => setState(() => _mode = SessionMode.responses),
          ),
          const SizedBox(width: 10),
          _ModeButton(
            icon: Icons.edit_note_rounded,
            label: 'Notes',
            active: _mode == SessionMode.notes,
            onTap: () => setState(() => _mode = SessionMode.notes),
          ),
          const Spacer(),
          Text(
            '${_patientEntries.length} patient · ${_therapistResponses.length} resp',
            style:
                GoogleFonts.poppins(color: AppColors.darkGray, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ── Notes mode ────────────────────────────────────────────────────────────

  Widget _buildNotesModeContent() {
    final items = <Widget>[
      ..._moodNotes.map((n) => _MoodHistoryCard(note: n)),
      ..._aiNotes.map((n) => _AiNoteCard(note: n)),
      ..._sessionNotes.map((n) => _SessionNoteCard(note: n)),
    ];
    if (!_moodLoaded) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2),
              SizedBox(height: 12),
              Text('Loading mood history…'),
            ],
          ),
        ),
      );
    }
    return Expanded(
      child: items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.note_alt_outlined,
                      color: AppColors.lightGray, size: 48),
                  const SizedBox(height: 10),
                  Text(
                    'No notes yet.\nAdd a note below to log your observations.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: AppColors.lightGray, fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView(
              controller: _notesScroll,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              children: items,
            ),
    );
  }

  // ── Responses mode ────────────────────────────────────────────────────────

  Widget _buildResponsesModeContent() {
    return Expanded(
      child: _therapistResponses.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      color: AppColors.lightGray, size: 48),
                  const SizedBox(height: 10),
                  Text(
                    'No responses yet.\nType or record below to respond to the patient.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: AppColors.lightGray, fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              itemCount: _therapistResponses.length,
              itemBuilder: (_, i) =>
                  _ResponseCard(response: _therapistResponses[i]),
            ),
    );
  }

  // ── VR live mode ──────────────────────────────────────────────────────────

  Widget _buildLiveModeContent() {
    return Expanded(
      child: Column(
        children: [
          const SizedBox(height: 10),
          // VR preview card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CardWithShadow(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    Container(
                      height: 130,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.view_in_ar_rounded,
                              color: Colors.white.withValues(alpha: 0.3),
                              size: 36,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'VR Session Active',
                              style: GoogleFonts.poppins(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12),
                            ),
                            Text(
                              widget.patientName,
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                        top: 10,
                        left: 12,
                        child: _LiveBadge(pulse: _pulseAnim)),
                    Positioned(
                      top: 10,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _elapsedStr,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Patient responses panel
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Patient Responses',
                        style: GoogleFonts.poppins(
                            color: AppColors.darkGray,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_patientEntries.length}',
                          style: GoogleFonts.poppins(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: _patientEntries.isEmpty
                      ? Center(
                          child: Text(
                            'Listening for patient to speak…\nResponses will appear here automatically.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: AppColors.lightGray, fontSize: 12),
                          ),
                        )
                      : ListView.builder(
                          controller: _patientScroll,
                          padding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          itemCount: _patientEntries.length,
                          itemBuilder: (_, i) =>
                              _PatientEntryCard(entry: _patientEntries[i]),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Input area ────────────────────────────────────────────────────────────

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(height: 10),

          if (_mode == SessionMode.notes) ...[
            // Notes mode: add-note input
            _buildNoteInput(),
          ] else if (_isTranscribing) ...[
            _buildTranscribingIndicator(),
          ] else if (_isRecording) ...[
            _buildRecordingIndicator(),
          ] else ...[
            // Response to avatar: show auto-detected emotion + text/voice input
            _buildAutoEmotionRow(),
            const SizedBox(height: 8),
            _buildTextInput(),
          ],
        ],
      ),
    );
  }

  Widget _buildAutoEmotionRow() {
    final e = _detectedEmotion;
    return Row(
      children: [
        const Icon(Icons.auto_awesome_rounded, size: 13, color: AppColors.darkGray),
        const SizedBox(width: 5),
        Text('Detected:',
            style: GoogleFonts.poppins(color: AppColors.darkGray, fontSize: 11)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: e.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: e.color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e.emoji, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(e.label,
                  style: GoogleFonts.poppins(
                      color: e.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoteInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 110),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: TextField(
              controller: _noteCtrl,
              maxLines: null,
              style: GoogleFonts.poppins(color: AppColors.black, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Add a session note or observation…',
                hintStyle: GoogleFonts.poppins(
                    color: AppColors.lightGray, fontSize: 13),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _addNote(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _addNote,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.note_add_rounded,
                color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildTextInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 110),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _textCtrl,
              maxLines: null,
              style:
                  GoogleFonts.poppins(color: AppColors.black, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Write your response to the avatar…',
                hintStyle: GoogleFonts.poppins(
                    color: AppColors.lightGray, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _toggleRecording,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.lightGray),
            ),
            child: const Icon(Icons.mic_none_rounded,
                color: AppColors.primary, size: 22),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _submitText,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.send_rounded,
                color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildTranscribingIndicator() {
    return Row(
      children: [
        const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Text(
          'Uploading voice & sending to patient…',
          style:
              GoogleFonts.poppins(color: AppColors.darkGray, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildRecordingIndicator() {
    final secs = _recordingDuration.inSeconds;
    final label =
        '${(secs ~/ 60).toString().padLeft(2, '0')}:${(secs % 60).toString().padLeft(2, '0')}';
    return Row(
      children: [
        ScaleTransition(
          scale: _pulseAnim,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE53935).withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE53935), width: 2),
            ),
            child: const Icon(Icons.mic_rounded,
                color: Color(0xFFE53935), size: 22),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _AnimatedWaveform(controller: _waveCtrl)),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFFE53935),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _toggleRecording,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
                color: Color(0xFFE53935), shape: BoxShape.circle),
            child:
                const Icon(Icons.stop_rounded, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _LiveBadge extends StatelessWidget {
  final Animation<double> pulse;
  const _LiveBadge({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: pulse,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              'LIVE',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: active ? AppColors.primaryGradient : null,
          color: active ? null : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: active ? Colors.white : AppColors.darkGray,
                size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: active ? Colors.white : AppColors.darkGray,
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientEntryCard extends StatelessWidget {
  final PatientEntry entry;
  const _PatientEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final time =
        '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CardWithShadow(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text('Patient',
                        style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                Text(time,
                    style: GoogleFonts.poppins(
                        color: AppColors.lightGray, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entry.text,
              style: GoogleFonts.poppins(
                  color: AppColors.black, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 10),

            if (entry.isAnalyzing)
              Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Text('Analyzing with Claude…',
                      style: GoogleFonts.poppins(
                          color: AppColors.darkGray, fontSize: 11)),
                ],
              )
            else if (entry.mood != null) ...[
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: entry.mood!.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: entry.mood!.color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(entry.mood!.emoji,
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          entry.mood!.primaryMood[0].toUpperCase() +
                              entry.mood!.primaryMood.substring(1),
                          style: GoogleFonts.poppins(
                              color: entry.mood!.color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.mood!.intensity}/10',
                          style: GoogleFonts.poppins(
                              color: entry.mood!.color.withValues(alpha: 0.7),
                              fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  if (entry.mood!.riskLevel != RiskLevel.none)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: entry.mood!.riskLevel.color
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: entry.mood!.riskLevel.color
                                .withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(entry.mood!.riskLevel.icon,
                              color: entry.mood!.riskLevel.color, size: 11),
                          const SizedBox(width: 3),
                          Text(
                            entry.mood!.riskLevel.label,
                            style: GoogleFonts.poppins(
                                color: entry.mood!.riskLevel.color,
                                fontSize: 10,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (entry.mood!.clinicalNote.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  entry.mood!.clinicalNote,
                  style: GoogleFonts.poppins(
                      color: AppColors.darkGray,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      height: 1.4),
                ),
              ],
              if (entry.mood!.themes.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: entry.mood!.themes
                      .map((t) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('#$t',
                                style: GoogleFonts.poppins(
                                    color: AppColors.primary,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500)),
                          ))
                      .toList(),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ResponseCard extends StatelessWidget {
  final SessionResponse response;
  const _ResponseCard({required this.response});

  @override
  Widget build(BuildContext context) {
    final e = response.emotion;
    final time =
        '${response.timestamp.hour.toString().padLeft(2, '0')}:${response.timestamp.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CardWithShadow(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: e.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: e.color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(e.emoji, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 5),
                      Text(
                        e.label,
                        style: GoogleFonts.poppins(
                            color: e.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (response.isVoice)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(Icons.mic_rounded,
                            color: AppColors.primary, size: 13),
                      ),
                    Text(time,
                        style: GoogleFonts.poppins(
                            color: AppColors.lightGray, fontSize: 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (response.isVoice)
              _VoiceNoteDisplay(duration: response.voiceDuration)
            else
              Text(
                response.content,
                style: GoogleFonts.poppins(
                    color: AppColors.black, fontSize: 13, height: 1.55),
              ),
          ],
        ),
      ),
    );
  }
}

class _SessionNoteCard extends StatelessWidget {
  final SessionResponse note;
  const _SessionNoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final time =
        '${note.timestamp.hour.toString().padLeft(2, '0')}:${note.timestamp.minute.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CardWithShadow(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.note_alt_rounded,
                  color: AppColors.primary, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Session Note',
                          style: GoogleFonts.poppins(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                      Text(time,
                          style: GoogleFonts.poppins(
                              color: AppColors.lightGray, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(note.content,
                      style: GoogleFonts.poppins(
                          color: AppColors.black, fontSize: 13, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceNoteDisplay extends StatelessWidget {
  final Duration duration;
  const _VoiceNoteDisplay({required this.duration});

  @override
  Widget build(BuildContext context) {
    final secs = duration.inSeconds;
    final label =
        '${(secs ~/ 60).toString().padLeft(2, '0')}:${(secs % 60).toString().padLeft(2, '0')}';
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient, shape: BoxShape.circle),
          child: const Icon(Icons.play_arrow_rounded,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  value: 0,
                  backgroundColor: AppColors.lightGray,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 3,
                ),
              ),
              const SizedBox(height: 4),
              Text('Voice note · $label',
                  style: GoogleFonts.poppins(
                      color: AppColors.darkGray, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.darkGray),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.poppins(
                  color: AppColors.darkGray, fontSize: 12)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.poppins(
                  color: AppColors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MoodHistoryCard extends StatelessWidget {
  final SessionResponse note;
  const _MoodHistoryCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CardWithShadow(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.mood_rounded,
                      color: AppColors.primary, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  'Patient Mood History',
                  style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              note.content,
              style: GoogleFonts.poppins(
                color: AppColors.black,
                fontSize: 12,
                height: 1.65,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiNoteCard extends StatelessWidget {
  final AiNoteEntry note;
  const _AiNoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final time =
        '${note.timestamp.month}/${note.timestamp.day} ${note.timestamp.hour.toString().padLeft(2, '0')}:${note.timestamp.minute.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CardWithShadow(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F89E9).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.psychology_alt_outlined,
                      color: Color(0xFF7F89E9), size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AI Chat Indicator',
                    style: GoogleFonts.poppins(
                        color: const Color(0xFF7F89E9),
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Text(time,
                    style: GoogleFonts.poppins(
                        color: AppColors.lightGray, fontSize: 11)),
              ],
            ),
            if (note.analysisResult.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(note.analysisResult,
                  style: GoogleFonts.poppins(
                      color: AppColors.black, fontSize: 12, height: 1.5)),
            ],
            if (note.diagnosticSuggestion.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF7F89E9).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(note.diagnosticSuggestion,
                    style: GoogleFonts.poppins(
                        color: const Color(0xFF5768D4),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        height: 1.4)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnimatedWaveform extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedWaveform({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(18, (i) {
            final offset = (i / 18) * 2 * 3.14159;
            final v = (0.3 +
                    0.7 *
                        ((controller.value * 2 * 3.14159 + offset).abs() %
                                    (2 * 3.14159) <
                                3.14159
                            ? 1 -
                                (controller.value * 2 * 3.14159 + offset) %
                                    3.14159 /
                                    3.14159
                            : (controller.value * 2 * 3.14159 + offset) %
                                3.14159 /
                                3.14159))
                .clamp(0.15, 1.0);
            return Container(
              width: 3,
              height: 28 * v,
              decoration: BoxDecoration(
                color:
                    const Color(0xFFE53935).withValues(alpha: 0.7 + 0.3 * v),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
