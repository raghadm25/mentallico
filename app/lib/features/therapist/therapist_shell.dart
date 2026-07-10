import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'messages/messages_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'home/therapist_home_screen.dart';
import 'hub/therapist_hub_screen.dart';
import 'profile/therapist_profile_screen.dart';

class TherapistShell extends StatefulWidget {
  const TherapistShell({super.key});

  @override
  State<TherapistShell> createState() => _TherapistShellState();
}

class _TherapistShellState extends State<TherapistShell> {
  int _index = 2;
  int _prevIndex = 2;

  void _onNavTap(int i) {
    setState(() {
      if (_index != 0) _prevIndex = _index;
      _index = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          TherapistMessagesScreen(
            onBack: () => setState(() => _index = _prevIndex),
          ),
          const TherapistDashboardScreen(),
          const TherapistHomeScreen(),
          const TherapistHubScreen(),
          const TherapistProfileScreen(),
        ],
      ),
      bottomNavigationBar: _index == 0
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TherapistNavBar(currentIndex: _index, onTap: _onNavTap),
                if (bottomPad > 0)
                  Container(height: bottomPad, color: const Color(0xFFD2D5DE)),
              ],
            ),
    );
  }
}

// ── Figma-accurate nav bar (node 1943-1318) ───────────────────────────────────
// Identical layout to patient nav bar — only tab 1 changes:
//   label "Dashboard" (was "Therapists"), grid-dashboard icon

class _TherapistNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _TherapistNavBar({required this.currentIndex, required this.onTap});

  @override
  State<_TherapistNavBar> createState() => _TherapistNavBarState();
}

class _TherapistNavBarState extends State<_TherapistNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Tween<double> _cxTween;
  late Animation<double> _cxAnim;

  static const _circleCx   = [58.0, 129.0, 215.0, 290.0, 368.0];
  static const _passiveLeft = [31.0,  98.0, 197.0, 273.0, 362.0];
  static const _passiveTop  = [40.0,  41.0,  41.0,  43.0,  41.0];
  static const _passiveBot  = [19.0,  19.0,  19.0,  21.0,  19.0];
  static const _passiveW    = [30.0,  60.0,  36.0,  50.0,  37.0];

  static const _icons = [
    Icons.chat_bubble_outline_rounded,
    Icons.space_dashboard_outlined,
    Icons.home_outlined,
    Icons.layers_outlined,
    Icons.person_outline_rounded,
  ];
  static const _activeIcons = [
    Icons.chat_bubble_rounded,
    Icons.space_dashboard_rounded,
    Icons.home_rounded,
    Icons.layers_rounded,
    Icons.person_rounded,
  ];
  static const _labels    = ['Chat', 'Dashboard', 'Home', 'Our Hub', 'Profile'];
  static const _iconSizes = [15.0, 20.0, 18.0, 18.0, 18.0];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    final cx = _circleCx[widget.currentIndex];
    _cxTween = Tween(begin: cx, end: cx);
    _cxAnim = _cxTween.animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_TherapistNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _cxTween = Tween(begin: _cxAnim.value, end: _circleCx[widget.currentIndex]);
      _cxAnim = _cxTween.animate(
          CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final s = w / 430;

    return AnimatedBuilder(
      animation: _cxAnim,
      builder: (context, _) {
        final cx = _cxAnim.value * s;
        return SizedBox(
          height: 100 * s,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(w, 100 * s),
                painter: _NavBarPainter(s: s, notchCX: cx),
              ),
              for (int i = 0; i < 5; i++)
                if (i != widget.currentIndex)
                  Positioned(
                    left:   _passiveLeft[i] * s,
                    top:    _passiveTop[i]  * s,
                    bottom: _passiveBot[i]  * s,
                    width:  _passiveW[i]    * s,
                    child: GestureDetector(
                      onTap: () => widget.onTap(i),
                      behavior: HitTestBehavior.opaque,
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_icons[i],
                                color: const Color(0xFF6C6F75),
                                size: _iconSizes[i] * s),
                            SizedBox(height: 3 * s),
                            Text(
                              _labels[i],
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF6C6F75),
                                fontSize: 12 * s,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              Positioned(
                left: cx - 29 * s,
                top: 0,
                child: GestureDetector(
                  onTap: () => widget.onTap(widget.currentIndex),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 58 * s,
                    height: 58 * s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7F89E9).withValues(alpha: 0.28),
                          blurRadius: 6 * s,
                          offset: Offset(0, 2 * s),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _activeIcons[widget.currentIndex],
                        color: Colors.white,
                        size: 26 * s,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavBarPainter extends CustomPainter {
  final double s;
  final double notchCX;
  const _NavBarPainter({required this.s, required this.notchCX});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD2D5DE)
      ..style = PaintingStyle.fill;

    final double barY = 20 * s;
    final double cr   = 10 * s;
    final double nHW  = 51.5 * s;
    final double nL   = (notchCX - nHW).clamp(0.0, size.width);
    final double nR   = (notchCX + nHW).clamp(0.0, size.width);

    final path = Path();

    if (nL < cr) {
      path.moveTo(0, barY);
    } else {
      path.moveTo(0, barY + cr);
      path.quadraticBezierTo(0, barY, cr, barY);
    }

    path.lineTo(nL, barY);
    if (nR > nL) {
      path.arcToPoint(
        Offset(nR, barY),
        radius: Radius.circular(52 * s),
        clockwise: true,
      );
    }

    if (nR > size.width - cr) {
      path.lineTo(size.width, barY);
    } else {
      path.lineTo(size.width - cr, barY);
      path.quadraticBezierTo(size.width, barY, size.width, barY + cr);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, nL < cr ? barY : barY + cr);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_NavBarPainter old) =>
      old.s != s || old.notchCX != notchCX;
}
