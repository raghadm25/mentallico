import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../services/app_state.dart';

class TherapistHomeScreen extends StatefulWidget {
  const TherapistHomeScreen({super.key});

  @override
  State<TherapistHomeScreen> createState() => _TherapistHomeScreenState();
}

class _TherapistHomeScreenState extends State<TherapistHomeScreen> {
  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_rebuild);
    super.dispose();
  }

  String get _name => AppState.instance.userName;

  @override
  Widget build(BuildContext context) {
    final s        = MediaQuery.of(context).size.width / 430;
    final safeTop  = MediaQuery.of(context).padding.top;
    final hour     = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    final weekdays = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    final months   = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final now      = DateTime.now();
    final dateStr  = '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gradient header ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(22 * s, safeTop + 20 * s, 22 * s, 28 * s),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(30 * s),
                  bottomRight: Radius.circular(30 * s),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(greeting,
                            style: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 14 * s, letterSpacing: -0.3 * s)),
                        SizedBox(height: 2 * s),
                        Text(_name,
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 22 * s,
                                fontWeight: FontWeight.w700, letterSpacing: -0.7 * s)),
                        SizedBox(height: 4 * s),
                        Text(dateStr,
                            style: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 13 * s, letterSpacing: -0.4 * s)),
                        SizedBox(height: 14 * s),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(20 * s),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7 * s, height: 7 * s,
                                decoration: const BoxDecoration(
                                    color: Color(0xFF4CAF50), shape: BoxShape.circle),
                              ),
                              SizedBox(width: 6 * s),
                              Text('Available',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white, fontSize: 12 * s,
                                      fontWeight: FontWeight.w500, letterSpacing: -0.4 * s)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16 * s),
                  UserAvatar(
                    radius: 34 * s,
                    borderWidth: 2 * s,
                    borderColor: Colors.white.withValues(alpha: 0.6),
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                  ),
                ],
              ),
            ),

            SizedBox(height: 22 * s),

            // ── Reminder card ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 22 * s),
              child: Container(
                padding: EdgeInsets.all(18 * s),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15 * s),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFF7F89E9).withValues(alpha: 0.24),
                      const Color(0xFFA87CC7).withValues(alpha: 0.24),
                    ],
                  ),
                  border: Border.all(color: const Color(0xFFD2D5DE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Today's Reminder:",
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF595959), fontSize: 13 * s,
                            fontWeight: FontWeight.w600, letterSpacing: -0.3 * s)),
                    SizedBox(height: 6 * s),
                    Text(
                      '"Check in with yourself before each session. Your presence is your most powerful therapeutic tool."',
                      style: GoogleFonts.inter(
                          color: const Color(0xFF1A2E12), fontSize: 13 * s,
                          fontStyle: FontStyle.italic, height: 1.35),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24 * s),

            // ── Quick tips ────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 22 * s),
              child: Text('Session Tips',
                  style: GoogleFonts.poppins(
                      fontSize: 16 * s, fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A2E12), letterSpacing: -0.5 * s)),
            ),
            SizedBox(height: 10 * s),
            ..._tips.map((tip) => Padding(
                  padding: EdgeInsets.only(left: 22 * s, right: 22 * s, bottom: 10 * s),
                  child: Container(
                    padding: EdgeInsets.all(14 * s),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14 * s),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF000000).withValues(alpha: 0.05),
                          blurRadius: 6 * s, offset: Offset(0, 2 * s),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36 * s, height: 36 * s,
                          decoration: BoxDecoration(
                            color: tip['color'] as Color,
                            borderRadius: BorderRadius.circular(10 * s),
                          ),
                          child: Icon(tip['icon'] as IconData,
                              color: Colors.white, size: 18 * s),
                        ),
                        SizedBox(width: 12 * s),
                        Expanded(
                          child: Text(tip['text'] as String,
                              style: GoogleFonts.poppins(
                                  fontSize: 13 * s, color: const Color(0xFF292929),
                                  height: 1.35)),
                        ),
                      ],
                    ),
                  ),
                )),

            SizedBox(height: 32 * s),
          ],
        ),
      ),
    );
  }

  static const _tips = [
    {
      'icon': Icons.mic_none_rounded,
      'text': 'Speak slowly and clearly — patients hear your actual voice via audio.',
      'color': Color(0xFF7F89E9),
    },
    {
      'icon': Icons.view_in_ar_outlined,
      'text': 'Open a VR session from the Dashboard, then wait for the patient to join.',
      'color': Color(0xFFA87CC7),
    },
    {
      'icon': Icons.record_voice_over_outlined,
      'text': 'Use the TTS relay to communicate as the VR character during sessions.',
      'color': Color(0xFF658852),
    },
  ];
}
