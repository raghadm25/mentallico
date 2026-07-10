import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/mentallico_api_service.dart';
import '../../../services/session_service.dart';
import '../../../services/unity_bridge.dart';

class ActiveVrSessionScreen extends StatefulWidget {
  final String sessionId;
  final String therapistName;

  /// 'therapist' — real therapist, 'ai' — AI mode
  final String sessionType;

  const ActiveVrSessionScreen({
    super.key,
    required this.sessionId,
    required this.therapistName,
    this.sessionType = 'therapist',
  });

  @override
  State<ActiveVrSessionScreen> createState() => _ActiveVrSessionScreenState();
}

class _ActiveVrSessionScreenState extends State<ActiveVrSessionScreen> {
  // Session state
  bool _sessionActive = false; // true when status == 'active'
  DateTime? _startedAt;

  // Unity state
  bool _showUnity = false;
  bool _unityReady = false;
  final bool _unityFailed = false;
  bool _aiResponding = false;
  final List<String> _pendingUnityMessages = [];
  final List<MentallicoAnalysisResult> _doctorNotes = [];
  final VrAiChatSession _vrChatSession = VrAiChatSession();
  bool _showDoctorNotes = false;

  // Subscriptions / timers
  StreamSubscription? _sessionSub;
  StreamSubscription? _messagesSub;
  late Timer _elapsedTimer;
  Timer? _unityTimeout;
  Timer? _unityShowDelay;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startedAt != null && mounted) {
        setState(() => _elapsed = DateTime.now().difference(_startedAt!));
      }
    });

    if (widget.sessionType == 'ai') {
      // AI sessions have no Firestore document — start Unity immediately.
      _sessionActive = true;
      _startedAt = DateTime.now();
      _startUnityWithDelay();
    } else {
      // Therapist sessions: watch the session doc for status changes.
      _sessionSub = SessionService.sessionStream(widget.sessionId).listen(
        (doc) async {
          if (!doc.exists || !mounted) return;
          final data = doc.data()!;
          final status = data['status'] as String? ?? 'waiting';
          if (status == 'active' && !_sessionActive) {
            _sessionActive = true;
            _startedAt = DateTime.now();
            // Grant RECORD_AUDIO to the process before Unity loads so that
            // Microphone.devices is non-empty when SpeechInputManager runs.
            await Permission.microphone.request();
            if (!mounted) return;
            _startUnityWithDelay();
          }
          if (status == 'ended') {
            _elapsedTimer.cancel();
            _showSessionEndedDialog();
          }
        },
        onError: (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Session error: $e')),
            );
          }
        },
      );
    }

    // Listen for therapist messages
    if (widget.sessionType == 'therapist') {
      _messagesSub =
          SessionService.messagesStream(widget.sessionId).listen(
        (snap) {
          for (final change in snap.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data()!;
              if ((data['sender'] as String?) == 'therapist') {
                final msgType = data['type'] as String? ?? 'text';
                if (msgType == 'voice') {
                  final url = data['audioUrl'] as String? ?? '';
                  if (url.isNotEmpty) _sendToUnity('therapist_voice_url', url);
                } else {
                  final text = data['text'] as String? ?? '';
                  if (text.isNotEmpty) _sendToUnity('therapist_text', text);
                }
              }
            }
          }
        },
        onError: (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Session stream error: $e')),
            );
          }
        },
      );
    }
  }

  void _startUnityWithDelay() {
    // Request landscape immediately so the OS has the full 2500 ms to settle
    // the rotation before Unity tries to detach its primary window.
    // Doing orientation + surface-grab in the same frame causes a race with
    // Android's compositor that produces the "Timeout (2000 ms) while
    // detaching primary window" black screen.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _unityShowDelay = Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      // Orientation is already settled — just hand the surface to Unity.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _showUnity = true);
        // 15 s fallback: Unity → Flutter messages are unreliable on some
        // builds (SendToFlutter.Send may not reach onMessageFromUnity), so
        // we force-start the session rather than showing a dead black screen.
        _unityTimeout = Timer(const Duration(seconds: 15), () {
          if (mounted && !_unityReady) _onUnityReady();
        });
      });
    });
  }

  void _sendToUnity(String type, String payload) {
    final json = jsonEncode({'type': type, 'payload': payload});
    if (_unityReady) {
      sendToUnity('FlutterBridge', 'OnFlutterMessage', json);
    } else {
      _pendingUnityMessages.add(json);
    }
  }

  void _onUnityReady() {
    if (!mounted) return;
    // Always resend set_session_mode — handles the case where the first send
    // was dropped because Unity wasn't fully initialised yet (e.g. timeout
    // fired early), and Unity's retry signal comes in afterwards.
    sendToUnity('FlutterBridge', 'OnFlutterMessage',
        jsonEncode({'type': 'set_session_mode', 'payload': widget.sessionType}));

    if (_unityReady) return; // rest of init only runs once
    setState(() => _unityReady = true);

    if (widget.sessionType == 'therapist') {
      // Send session config so Unity can write patient speech directly to Firestore,
      // bypassing the Unity→Flutter bridge (which has startup timing unreliability).
      _sendSessionConfig();

      for (final json in _pendingUnityMessages) {
        sendToUnity('FlutterBridge', 'OnFlutterMessage', json);
      }
    }
    _pendingUnityMessages.clear();
  }

  Future<void> _sendSessionConfig() async {
    try {
      final token =
          await FirebaseAuth.instance.currentUser?.getIdToken(true) ?? '';
      _sendToUnity(
        'session_config',
        jsonEncode({'sessionId': widget.sessionId, 'authToken': token}),
      );
    } catch (_) {
      // session_config is a best-effort optimisation; failure is non-fatal
    }
  }

  Future<void> _handleAiUserInput(String userInput) async {
    if (userInput.isEmpty || _aiResponding) return;
    setState(() => _aiResponding = true);
    try {
      // One call per turn, on the same running session — the backend
      // returns the reply text and the diagnostic signal together.
      final result = await _vrChatSession.handleUserInput(
        vrSessionId: widget.sessionId,
        userInput: userInput,
      );
      if (mounted) setState(() => _doctorNotes.add(result));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI response error: $e'),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _aiResponding = false);
    }
  }

  Future<void> _forwardPatientSpeech(String transcript) async {
    if (transcript.isEmpty) return;
    try {
      await SessionService.sendMessage(
        sessionId: widget.sessionId,
        text: transcript,
        sender: 'patient',
      );
    } catch (e) {
      // Show briefly so the patient knows their speech wasn't recorded.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save response: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _elapsedTimer.cancel();
    _unityTimeout?.cancel();
    _unityShowDelay?.cancel();
    _sessionSub?.cancel();
    _messagesSub?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Restore portrait when leaving VR
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  String get _elapsedStr {
    final m = _elapsed.inMinutes % 60;
    final s = _elapsed.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _showSessionEndedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Session Ended',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('Your therapy session has ended. Take care!',
            style: GoogleFonts.poppins(
                color: AppColors.darkGray, fontSize: 13)),
        actions: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(30),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: Text('Back to Home',
                  style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmEndSession() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('End Session?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('This will end the session for both sides.',
            style: GoogleFonts.poppins(
                color: AppColors.darkGray, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppColors.darkGray)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
            onPressed: () => Navigator.pop(context, true),
            child: Text('End',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      if (widget.sessionType == 'ai') {
        if (mounted) Navigator.pop(context);
      } else {
        await SessionService.endSession(widget.sessionId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d1a40),
      body: Stack(
        children: [
          // ── Main content ─────────────────────────────────────────────────
          if (_unityFailed)
            _buildVrFailedScreen()
          else if (!_sessionActive)
            _buildWaitingForTherapistScreen()
          else if (_showUnity)
            _buildUnityView()
          else
            _buildLoadingBackground(),

          // ── Loading overlay (Unity starting) ──────────────────────────
          if (_sessionActive && !_unityReady && !_unityFailed)
            _buildLoadingOverlay(),

          // ── Top bar (once Unity is ready) ─────────────────────────────
          if (_unityReady)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                color: Colors.black.withValues(alpha: 0.45),
                child: Row(
                  children: [
                    Text(
                      widget.sessionType == 'ai'
                          ? 'AI Therapy Session'
                          : 'Session with ${widget.therapistName}',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(_elapsedStr,
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => setState(
                          () => _showDoctorNotes = !_showDoctorNotes),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.note_alt_outlined,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text('Doctor Notes (${_doctorNotes.length})',
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _confirmEndSession,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
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
              ),
            ),

          if (_aiResponding)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Color(0xFF7F89E9),
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'AI is responding…',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_showDoctorNotes) _buildDoctorNotesPanel(),
        ],
      ),
    );
  }

  Widget _buildDoctorNotesPanel() {
    return Positioned(
      top: 48,
      right: 12,
      bottom: 60,
      width: 320,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text('Doctor Notes',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _showDoctorNotes = false),
                    child: const Icon(Icons.close,
                        color: Colors.white54, size: 18),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: _doctorNotes.isEmpty
                  ? Center(
                      child: Text(
                        'No AI notes yet.\nNotes appear as the patient talks.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            color: Colors.white38, fontSize: 12),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _doctorNotes.length,
                      separatorBuilder: (_, _) =>
                          const Divider(color: Colors.white12, height: 20),
                      itemBuilder: (context, index) {
                        final note =
                            _doctorNotes[_doctorNotes.length - 1 - index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(note.analysisResult,
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                    height: 1.4)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF7F89E9).withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(note.diagnosticSuggestion,
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xFFB8C0FF),
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic)),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Loading helpers ───────────────────────────────────────────────────────

  static const _bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1a1040), Color(0xFF0d1a40)],
  );

  Widget _buildLoadingBackground() {
    return Container(decoration: const BoxDecoration(gradient: _bgGradient));
  }

  Widget _buildLoadingOverlay() {
    return Container(
      decoration: const BoxDecoration(gradient: _bgGradient),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                color: Color(0xFF7F89E9),
                strokeWidth: 4,
                backgroundColor: Color(0x337F89E9),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Mentallico VR',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading your session…',
              style: GoogleFonts.poppins(
                  color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              'Put on your VR headset',
              style: GoogleFonts.poppins(
                  color: AppColors.primary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ── Pre-session: waiting for therapist to connect ─────────────────────────

  Widget _buildWaitingForTherapistScreen() {
    return Container(
      decoration: const BoxDecoration(gradient: _bgGradient),
      child: Column(
        children: [
          const Spacer(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F89E9).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: Color(0xFF7F89E9), size: 36),
                ),
                const SizedBox(height: 20),
                Text(
                  'Waiting for therapist…',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'The VR session will start automatically\nonce ${widget.therapistName} joins.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      color: Colors.white54, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 28),
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                      color: Color(0xFF7F89E9), strokeWidth: 2),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: TextButton(
              onPressed: () {
                SessionService.endSession(widget.sessionId);
                Navigator.pop(context);
              },
              child: Text('Cancel',
                  style: GoogleFonts.poppins(
                      color: Colors.white38, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Unity view (with crash protection) ───────────────────────────────────

  Widget _buildUnityView() {
    return SizedBox.expand(
      child: EmbedUnity(
        onMessageFromUnity: (msg) {
          String? type;
          String payload = '';

          try {
            final decoded = jsonDecode(msg) as Map<String, dynamic>;
            type = decoded['type'] as String?;
            payload = decoded['payload'] as String? ?? '';
          } catch (_) {
            // Legacy plain-string format from older Unity builds
            if (msg == 'unity_ready') {
              type = 'unity_ready';
            } else if (msg.startsWith('patient_speech:')) {
              type = 'patient_spoke';
              payload = msg.substring('patient_speech:'.length).trim();
            }
          }

          if (type == 'unity_ready') {
            _onUnityReady();
          } else if (type == 'patient_spoke' &&
              widget.sessionType == 'therapist') {
            _forwardPatientSpeech(payload);
          } else if (type == 'patient_spoke' &&
              widget.sessionType == 'ai') {
            _handleAiUserInput(payload);
          } else if (type == 'voice_error') {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Voice playback error: $payload'),
                  backgroundColor: Colors.red.shade700,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        },
      ),
    );
  }

  // ── VR failed screen ──────────────────────────────────────────────────────

  Widget _buildVrFailedScreen() {
    return Container(
      decoration: const BoxDecoration(gradient: _bgGradient),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.view_in_ar_outlined,
                  color: Colors.white30, size: 56),
              const SizedBox(height: 16),
              Text('VR could not load',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Text(
                'The VR environment failed to start on this device.\nYou can continue the session in text mode.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    color: Colors.white54, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7F89E9),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back',
                    style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
