import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home/home_screen.dart';
import 'chat/ai_chat_conversation.dart';
import 'therapists/therapists_screen.dart';
import 'hub/hub_screen.dart';
import 'profile/profile_screen.dart';

class PatientShell extends StatefulWidget {
  const PatientShell({super.key});

  @override
  State<PatientShell> createState() => _PatientShellState();
}

class _PatientShellState extends State<PatientShell> {
  int _index = 2;    // Home is centre
  int _prevIndex = 2; // last non-chat tab, restored on Chat back-button press

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
          AiChatConversation(
            onBack: () => setState(() => _index = _prevIndex),
          ),
          const TherapistsScreen(),
          HomeScreen(
            onChatRequested: () => _onNavTap(0),
            onProfileRequested: () => _onNavTap(4),
          ),
          const HubScreen(),
          const PatientProfileScreen(),
        ],
      ),
      // Hide nav bar on Chat tab — the green user card is the footer there.
      // Extend the gray color into the bottom safe area via a Column.
      bottomNavigationBar: _index == 0
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FancyNavBar(currentIndex: _index, onTap: _onNavTap),
                if (bottomPad > 0)
                  Container(height: bottomPad, color: const Color(0xFFD2D5DE)),
              ],
            ),
    );
  }
}

// ─── Figma-accurate animated nav bar (node 1801:6833) ─────────────────────────
//
// Total height: 100 × s
//   0 → 20s   : transparent gap — gradient circle protrudes into this band
//   20s → 100s : gray (#D2D5DE) bar, rounded-tl/tr 10px, with a semicircular
//                notch that follows the selected tab's gradient circle.
//
// The gradient circle (58×58px) moves between tabs; the notch tracks it.
// Circle center x per tab (Figma @ 430px): [58, 129, 215, 290, 368]
// Notch half-width = 51.5px; arc radius = 52px → depth ≈ 45px.

class _FancyNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FancyNavBar({required this.currentIndex, required this.onTap});

  @override
  State<_FancyNavBar> createState() => _FancyNavBarState();
}

class _FancyNavBarState extends State<_FancyNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Tween<double> _cxTween;
  late Animation<double> _cxAnim;

  // Circle center x per tab (Figma canvas @ 430px).
  static const _circleCx = [58.0, 129.0, 215.0, 290.0, 368.0];

  // Passive item layout: left edge, top, bottom, width (Figma canvas @ 430px).
  // Derived from Figma insets; Home is centered (left = 215 - 36/2 = 197).
  static const _passiveLeft = [31.0, 98.0, 197.0, 273.0, 362.0];
  static const _passiveTop  = [40.0, 41.0,  41.0,  43.0,  41.0];
  static const _passiveBot  = [19.0, 19.0,  19.0,  21.0,  19.0];
  static const _passiveW    = [30.0, 60.0,  36.0,  50.0,  37.0];

  static const _icons = [
    Icons.chat_bubble_outline_rounded,
    Icons.people_outline_rounded,
    Icons.home_outlined,
    Icons.layers_outlined,
    Icons.person_outline_rounded,
  ];
  static const _activeIcons = [
    Icons.chat_bubble_rounded,
    Icons.people_rounded,
    Icons.home_rounded,
    Icons.layers_rounded,
    Icons.person_rounded,
  ];
  static const _labels    = ['Chat', 'Therapists', 'Home', 'Our Hub', 'Profile'];
  static const _iconSizes = [15.0,   18.0,          18.0,  18.0,      18.0];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    final cx = _circleCx[widget.currentIndex];
    _cxTween = Tween(begin: cx, end: cx);
    _cxAnim  = _cxTween.animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_FancyNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      // Animate from wherever the circle currently is (handles rapid switches).
      _cxTween = Tween(
        begin: _cxAnim.value,
        end:   _circleCx[widget.currentIndex],
      );
      _cxAnim = _cxTween.animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
      );
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
        final cx = _cxAnim.value * s; // circle center x in screen pixels

        return SizedBox(
          height: 100 * s,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Gray bar with animated notch ────────────────────────
              CustomPaint(
                size: Size(w, 100 * s),
                painter: _NavBarPainter(s: s, notchCX: cx),
              ),

              // ── 4 passive nav items (all except currently selected) ──
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
                      // Align+min prevents the Column from ever overflowing
                      // the fractional-pixel height of the Positioned area.
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _icons[i],
                              color: const Color(0xFF6C6F75),
                              size: _iconSizes[i] * s,
                            ),
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

              // ── Animated gradient circle with selected tab's icon ────
              Positioned(
                left: cx - 29 * s,
                top:  0,
                child: GestureDetector(
                  onTap: () => widget.onTap(widget.currentIndex),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width:  58 * s,
                    height: 58 * s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end:   Alignment.centerRight,
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

// Draws the gray bar (from y=20s) with a semicircular notch at notchCX.
// notchCX is the horizontal centre of the notch in screen pixels (already ×s).
// Handles edge cases where the notch overlaps the left or right corners.
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
    final double cr   = 10 * s;        // corner radius
    final double nHW  = 51.5 * s;      // notch half-width
    final double nL   = (notchCX - nHW).clamp(0.0, size.width);
    final double nR   = (notchCX + nHW).clamp(0.0, size.width);

    final path = Path();

    // Top-left corner — skip curve if notch overlaps it
    if (nL < cr) {
      path.moveTo(0, barY);
    } else {
      path.moveTo(0, barY + cr);
      path.quadraticBezierTo(0, barY, cr, barY);
    }

    // Top edge to notch, then downward arc, then rest of top edge
    path.lineTo(nL, barY);
    if (nR > nL) {
      path.arcToPoint(
        Offset(nR, barY),
        radius: Radius.circular(52 * s),
        clockwise: true,
      );
    }

    // Top-right corner — skip curve if notch overlaps it
    if (nR > size.width - cr) {
      path.lineTo(size.width, barY);
    } else {
      path.lineTo(size.width - cr, barY);
      path.quadraticBezierTo(size.width, barY, size.width, barY + cr);
    }

    // Right side → bottom → left side → close
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
