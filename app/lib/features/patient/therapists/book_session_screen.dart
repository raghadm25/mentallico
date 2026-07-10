import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/vr_screen.dart';
import '../chat/therapist_chat_conversation.dart';

class BookSessionScreen extends StatelessWidget {
  final String doctorName;
  final String doctorSpecialty;
  final String doctorImage;

  const BookSessionScreen({
    super.key,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorImage,
  });

  String get _initials => doctorName
      .split(' ')
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0])
      .join();

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 430;
    return Scaffold(
      backgroundColor: const Color(0xFF7F89E9),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _ChevronPatternPainter())),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: _buildStack(context, s),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStack(BuildContext context, double s) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // ── Card ─────────────────────────────────────────────────────────────
        Container(
          margin: EdgeInsets.only(top: 98 * s),
          width: 360 * s,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(30 * s),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A2E12).withValues(alpha: 0.08),
                blurRadius: 4 * s,
                offset: Offset(0, 4 * s),
              ),
              BoxShadow(
                color: const Color(0xFF7F89E9).withValues(alpha: 0.43),
                blurRadius: 11.6 * s,
                offset: Offset(0, 4 * s),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(25 * s, 112 * s, 25 * s, 61 * s),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 17 * s,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF1A2E12),
                      letterSpacing: -0.85 * s,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: "You're booking a session with\n"),
                      TextSpan(
                        text: ' $doctorName',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18 * s),
                // Description
                SizedBox(
                  width: 216 * s,
                  child: Text(
                    'Pick the most suitable type of session that suits you. First Session is always free.',
                    style: GoogleFonts.poppins(
                      fontSize: 14 * s,
                      color: const Color(0xFF3D3D3D),
                      letterSpacing: -0.7 * s,
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 24 * s),
                // Virtual Reality Session
                _SessionButton(
                  icon: Icons.view_in_ar_rounded,
                  label: 'Virtual Reality Session',
                  type: _BtnType.vr,
                  iconTextGap: 14 * s,
                  s: s,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VrScreen()),
                  ),
                ),
                SizedBox(height: 12 * s),
                // Video Call Session
                _SessionButton(
                  icon: Icons.videocam_rounded,
                  label: 'Video Call Session',
                  type: _BtnType.video,
                  iconTextGap: 12 * s,
                  s: s,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TherapistChatConversation(
                        therapistName: doctorName,
                        specialty: doctorSpecialty,
                        initials: _initials,
                        color: const Color(0xFF7F89E9),
                        image: doctorImage,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12 * s),
                // Text & Voice Session
                _SessionButton(
                  icon: Icons.graphic_eq_rounded,
                  label: 'Text & Voice Session',
                  type: _BtnType.voice,
                  iconTextGap: 10 * s,
                  s: s,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TherapistChatConversation(
                        therapistName: doctorName,
                        specialty: doctorSpecialty,
                        initials: _initials,
                        color: const Color(0xFF7F89E9),
                        image: doctorImage,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 22 * s),
                // Cancel
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      fontSize: 11 * s,
                      color: const Color(0xFF595959),
                      letterSpacing: -0.55 * s,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // ── Doctor photo circle ───────────────────────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 196 * s,
              height: 196 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF7F89E9),
                  width: 10 * s,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7F89E9).withValues(alpha: 0.35),
                    blurRadius: 14 * s,
                    offset: Offset(0, 4 * s),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  doctorImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context0, err, stack) => Container(
                    color: const Color(0xFF9095D9),
                    child: Center(
                      child: Text(
                        _initials,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 44 * s,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Button type ───────────────────────────────────────────────────────────────

enum _BtnType { vr, video, voice }

// ── Session option button ─────────────────────────────────────────────────────

class _SessionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final _BtnType type;
  final double iconTextGap;
  final double s;
  final VoidCallback onTap;

  const _SessionButton({
    required this.icon,
    required this.label,
    required this.type,
    required this.iconTextGap,
    required this.s,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isVr = type == _BtnType.vr;
    final isVideo = type == _BtnType.video;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 216 * s,
        height: 40 * s,
        decoration: BoxDecoration(
          gradient: isVr
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.0, 0.505, 1.0],
                  colors: [
                    const Color(0xFF7F89E9).withValues(alpha: 0.54),
                    const Color(0xFFA87CC7).withValues(alpha: 0.54),
                    const Color(0xFF658852).withValues(alpha: 0.54),
                  ],
                )
              : null,
          color: isVr
              ? null
              : (isVideo ? const Color(0xFFD2D5DE) : const Color(0xFFF0F0F0)),
          borderRadius: BorderRadius.circular(30 * s),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A2E12).withValues(alpha: 0.08),
              blurRadius: 4 * s,
              offset: Offset(0, 4 * s),
            ),
            BoxShadow(
              color: const Color(0xFF7F89E9).withValues(alpha: 0.30),
              blurRadius: 11.6 * s,
              offset: Offset(0, 4 * s),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20 * s, color: const Color(0xFF1A2E12)),
            SizedBox(width: iconTextGap),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14 * s,
                color: const Color(0xFF1A2E12),
                letterSpacing: -0.7 * s,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Background chevron pattern ────────────────────────────────────────────────

class _ChevronPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const spacing = 36.0;
    const arrowSize = 12.0;

    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        final path = Path();
        path.moveTo(x - arrowSize / 2, y + arrowSize / 2);
        path.lineTo(x, y - arrowSize / 2);
        path.lineTo(x + arrowSize / 2, y + arrowSize / 2);
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
