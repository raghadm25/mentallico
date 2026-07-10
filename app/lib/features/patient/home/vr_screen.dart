import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../services/app_state.dart';
import '../../../services/session_service.dart';
import '../vr/active_vr_session_screen.dart';

class VrScreen extends StatelessWidget {
  const VrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 430;
    final safeTop = MediaQuery.of(context).padding.top;
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0F27),
      body: Stack(
        children: [
          // Background wave
          Positioned(
            top: screenH * 0.2134,
            bottom: screenH * 0.3705,
            left: -screenW * 0.4295,
            right: -screenW * 0.3942,
            child: Transform.rotate(
              angle: -9.66 * math.pi / 180,
              child: Image.asset(
                'assets/images/vr_wave.png',
                fit: BoxFit.fill,
                errorBuilder: (ctx, err, st) => const SizedBox.shrink(),
              ),
            ),
          ),

          // Dot pattern
          Positioned.fill(child: CustomPaint(painter: _DotPatternPainter())),

          // Colour glow
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.026, 0.566, 1.0],
                    colors: [
                      const Color(0xFF7F89E9).withValues(alpha: 0.21),
                      const Color(0xFFA87CC7).withValues(alpha: 0.21),
                      const Color(0xFF658852).withValues(alpha: 0.21),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // VR headset image
          Positioned(
            top: 192 * s,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 395 * s,
                height: 395 * s,
                child: Image.asset(
                  'assets/images/vr_headset.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Description
          Positioned(
            top: 610 * s,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 35 * s),
                child: Text(
                  'Put your VR glasses on and get ready for the full therapy experience in your space.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14 * s,
                    color: const Color(0xFFF0F0F0),
                    letterSpacing: -0.8 * s,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),

          // Available therapist sessions + AI button
          Positioned(
            top: 690 * s,
            left: 22 * s,
            right: 22 * s,
            bottom: 20 * s,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AvailableSessionsBanner(s: s),
                  SizedBox(height: 12 * s),
                  _AiSessionButton(s: s),
                  SizedBox(height: 20 * s),
                ],
              ),
            ),
          ),

          // Back button
          Positioned(
            top: safeTop + 16 * s,
            left: 20 * s,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40 * s,
                height: 40 * s,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20 * s),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Available therapist sessions ──────────────────────────────────────────────

class _AvailableSessionsBanner extends StatelessWidget {
  final double s;
  const _AvailableSessionsBanner({required this.s});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: SessionService.availableSessionsStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8 * s),
            child: const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Color(0xFF7F89E9), strokeWidth: 2),
              ),
            ),
          );
        }

        final sessions = snap.data?.docs ?? [];
        if (sessions.isEmpty) {
          return Container(
            padding: EdgeInsets.all(14 * s),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14 * s),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                Icon(Icons.person_search_rounded,
                    color: Colors.white54, size: 20 * s),
                SizedBox(width: 10 * s),
                Expanded(
                  child: Text(
                    'No therapists are live right now.\nCheck back soon or start an AI session.',
                    style: GoogleFonts.poppins(
                        color: Colors.white54, fontSize: 12 * s, height: 1.4),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Therapist is ready — join now',
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13 * s,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3 * s,
              ),
            ),
            SizedBox(height: 8 * s),
            ...sessions.map((doc) {
              final data = doc.data();
              final therapistName =
                  data['therapistName'] as String? ?? 'Therapist';
              return _SessionJoinCard(
                s: s,
                sessionId: doc.id,
                therapistName: therapistName,
              );
            }),
            SizedBox(height: 6 * s),
            Divider(
                color: Colors.white.withValues(alpha: 0.15), thickness: 1),
            SizedBox(height: 4 * s),
            Text(
              'Or start your own AI session below:',
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 11 * s,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SessionJoinCard extends StatefulWidget {
  final double s;
  final String sessionId;
  final String therapistName;

  const _SessionJoinCard({
    required this.s,
    required this.sessionId,
    required this.therapistName,
  });

  @override
  State<_SessionJoinCard> createState() => _SessionJoinCardState();
}

class _SessionJoinCardState extends State<_SessionJoinCard> {
  bool _joining = false;

  Future<void> _join() async {
    if (_joining) return;
    setState(() => _joining = true);

    // Capture nav + data BEFORE any await — the Firestore write will cause
    // the StreamBuilder above us to rebuild and unmount this widget, so
    // we must not rely on `context` or `mounted` after the first await.
    final nav           = Navigator.of(context);
    final sessionId     = widget.sessionId;
    final therapistName = widget.therapistName;
    final myName        = AppState.instance.userName;

    try {
      await Permission.microphone.request();
      await SessionService.joinSession(sessionId, patientName: myName);

      // Use the saved NavigatorState — widget may be unmounted by now.
      nav.push(MaterialPageRoute(
        builder: (_) => ActiveVrSessionScreen(
          sessionId: sessionId,
          therapistName: therapistName,
          sessionType: 'therapist',
        ),
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not join: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    return Container(
      margin: EdgeInsets.only(bottom: 8 * s),
      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 12 * s),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14 * s),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38 * s,
            height: 38 * s,
            decoration: BoxDecoration(
              color: const Color(0xFF7F89E9).withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.person_rounded, color: Colors.white, size: 20 * s),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.therapistName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6 * s,
                      height: 6 * s,
                      decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50), shape: BoxShape.circle),
                    ),
                    SizedBox(width: 5 * s),
                    Text(
                      'Live — waiting for you',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 10 * s,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _joining ? null : _join,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)]),
                borderRadius: BorderRadius.circular(20 * s),
              ),
              child: _joining
                  ? SizedBox(
                      width: 14 * s,
                      height: 14 * s,
                      child: const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text('Join',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── AI start button ───────────────────────────────────────────────────────────

class _AiSessionButton extends StatefulWidget {
  final double s;
  const _AiSessionButton({required this.s});

  @override
  State<_AiSessionButton> createState() => _AiSessionButtonState();
}

class _AiSessionButtonState extends State<_AiSessionButton> {
  bool _loading = false;

  Future<void> _start() async {
    if (_loading) return;
    setState(() => _loading = true);

    final nav         = Navigator.of(context);
    final patientName = AppState.instance.userName;

    try {
      await Permission.microphone.request();
      final sessionId = await SessionService.createAISession(patientName: patientName);

      nav.push(MaterialPageRoute(
        builder: (_) => ActiveVrSessionScreen(
          sessionId: sessionId,
          therapistName: 'AI Therapist',
          sessionType: 'ai',
        ),
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not start session: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    return GestureDetector(
      onTap: _loading ? null : _start,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16 * s),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const [0.0, 0.505, 1.0],
            colors: [
              const Color(0xFF7F89E9).withValues(alpha: 0.46),
              const Color(0xFFA87CC7).withValues(alpha: 0.46),
              const Color(0xFF658852).withValues(alpha: 0.46),
            ],
          ),
          borderRadius: BorderRadius.circular(20 * s),
        ),
        child: Center(
          child: _loading
              ? SizedBox(
                  width: 22 * s,
                  height: 22 * s,
                  child: const CircularProgressIndicator(
                      color: Color(0xFFF0F0F0), strokeWidth: 2))
              : Text(
                  'Start AI VR Session',
                  style: GoogleFonts.poppins(
                    fontSize: 18 * s,
                    color: const Color(0xFFF0F0F0),
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.8 * s,
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Dot grid painter ──────────────────────────────────────────────────────────

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;
    const spacing = 8.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
