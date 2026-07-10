import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  static const _total = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _total - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/role-selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: const [
              _Page1(),
              _Page2(),
              _Page3(),
            ],
          ),

          // Bottom nav row — dots left, button right, always separated
          Positioned(
            left: 24,
            right: 24,
            top: size.height * (835 / 932),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ProgressDots(current: _currentPage, total: _total),
                if (_currentPage < _total - 1)
                  // Circle arrow button
                  GestureDetector(
                    onTap: _next,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const ShapeDecoration(
                        color: Color(0xFF7F89E9),
                        shape: OvalBorder(),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 47,
                          height: 47,
                          child: CustomPaint(painter: _ArrowPainter()),
                        ),
                      ),
                    ),
                  )
                else
                  // GET STARTED button
                  GestureDetector(
                    onTap: _next,
                    child: Container(
                      width: size.width * (210 / 430),
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7F89E9),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          'GET STARTED',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFF0F0F0),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.208,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared ellipses ──────────────────────────────────────────────────────────
// Positions are proportional to screen. Heights use screen-height proportion
// so the blob always covers the same visual fraction of the screen.

List<Widget> _buildEllipses(Size size) => [
      _Ellipse(w: size.width * (575 / 430), h: size.height * (569 / 932), left: size.width * (-75 / 430), top: size.height * (-114 / 932), color: const Color(0xFF939CFF)),
      _Ellipse(w: size.width * (491 / 430), h: size.height * (492 / 932), left: size.width * (-32 / 430), top: size.height * (-77 / 932),  color: const Color(0xFF99A1FF)),
      _Ellipse(w: size.width * (411 / 430), h: size.height * (412 / 932), left: size.width * (7 / 430),   top: size.height * (-37 / 932),  color: const Color(0xFF9EA5FF)),
      _Ellipse(w: size.width * (306 / 430), h: size.height * (305 / 932), left: size.width * (66 / 430),  top: size.height * (9 / 932),    color: const Color(0xFFA3AAFF)),
    ];

// ─── Shared text builders ─────────────────────────────────────────────────────
// Left margin reduced from Figma's 38/44px to 20px so text sits further left.
// Text container fills most of the screen width with balanced side margins.

const double _textLeft = 20.0;

Widget _buildHeading(Size size, {required String line1, required String gradientLine}) {
  final style = GoogleFonts.poppins(
    color: const Color(0xFF1A2E12),
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.208,
    letterSpacing: -0.8,
  );
  return Padding(
    padding: const EdgeInsets.only(left: _textLeft),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(line1, style: style),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF7F89E9), Color(0xFFA87CC7), Color(0xFF658852)],
            stops: [0.0, 0.565, 1.0],
          ).createShader(bounds),
          child: Text(gradientLine, style: style.copyWith(color: Colors.white)),
        ),
      ],
    ),
  );
}

Widget _buildDescription(Size size, String text) {
  return Padding(
    padding: const EdgeInsets.only(left: _textLeft),
    child: SizedBox(
      width: size.width - _textLeft * 2,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: const Color(0xFF595959),
          fontSize: 20,
          fontWeight: FontWeight.w400,
          height: 1.21,
          letterSpacing: -1.0,
        ),
      ),
    ),
  );
}

// ─── Page 1 ───────────────────────────────────────────────────────────────────
// Illustration: 415×368px (user-provided, pre-cropped, RGBA transparent)
// Height = width × (368/415) to preserve aspect ratio — no stretching.

class _Page1 extends StatelessWidget {
  const _Page1();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final illustW = size.width * (415 / 430);
    final illustH = illustW * (368 / 415); // aspect-ratio lock

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        ..._buildEllipses(size),
        Positioned.fill(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * (152 / 932)),
              Center(
                child: Image.asset(
                  'assets/images/onboarding_illustration_1.png',
                  width: illustW,
                  height: illustH,
                  fit: BoxFit.contain, // never distort
                  gaplessPlayback: true,
                ),
              ),
              const SizedBox(height: 10),
              _buildHeading(size, line1: 'Welcome to', gradientLine: 'Mentallico'),
              const SizedBox(height: 20),
              _buildDescription(size,
                  'A safe space to pause, reflect, and talk about how you feel — without judgment or pressure.'),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Page 2 ───────────────────────────────────────────────────────────────────
// Raw asset: 1248×832 (ratio 1.5:1). Figma clips a 414×367 window
// starting at left=-13.86%, top=0 of the image scaled to 136.16% width.
// All dimensions derived from screen WIDTH only — no separate height scaling
// so the image is never distorted regardless of screen proportions.

class _Page2 extends StatelessWidget {
  const _Page2();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Container: maintain Figma's 414:367 aspect ratio, width-based
    final containerW = size.width * (414 / 430);
    final containerH = containerW * (367 / 414);

    // Image fills 136.16% of container width, height preserves 1248×832 ratio
    final imgW    = containerW * 1.3616;
    final imgH    = imgW * (832 / 1248); // 1.5:1 → no distortion
    final imgLeft = -containerW * 0.1386;

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        ..._buildEllipses(size),
        Positioned.fill(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * (88 / 932)),
              Center(
                child: ClipRect(
                  child: SizedBox(
                    width: containerW,
                    height: containerH,
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Positioned(
                          left: imgLeft,
                          top: 0,
                          width: imgW,
                          height: imgH,
                          child: Image.asset(
                            'assets/images/onboarding_illustration_2.png',
                            fit: BoxFit.fill,
                            gaplessPlayback: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildHeading(size, line1: "You're always in", gradientLine: 'control'),
              const SizedBox(height: 20),
              _buildDescription(size,
                  'You choose what to share, save, or explore.\nEverything is designed to support you — without pressure.'),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Page 3 ───────────────────────────────────────────────────────────────────
// Raw asset: 1644×1644 (square). Figma clips a 407×399 window
// with image at 120% width, 122.31% height, offset left -10.81%, top -11.85%.
// All dimensions width-based for aspect-ratio safety.

class _Page3 extends StatelessWidget {
  const _Page3();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Container: maintain Figma's 407:399 aspect ratio, width-based
    final containerW = size.width * (407 / 430);
    final containerH = containerW * (399 / 407);

    // Square image scaled to 120% container width → also square (1:1 ratio)
    final imgW    = containerW * 1.20;
    final imgH    = imgW; // 1644×1644 is square
    final imgLeft = -containerW * 0.1081;
    final imgTop  = -containerH * 0.1185;

    final headingStyle = GoogleFonts.poppins(
      color: const Color(0xFF1A2E12),
      fontSize: 36,
      fontWeight: FontWeight.w600,
      height: 1.208,
      letterSpacing: -0.8,
    );

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        ..._buildEllipses(size),
        Positioned.fill(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * (67 / 932)),
              Center(
                child: ClipRect(
                  child: SizedBox(
                    width: containerW,
                    height: containerH,
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Positioned(
                          left: imgLeft,
                          top: imgTop,
                          width: imgW,
                          height: imgH,
                          child: Image.asset(
                            'assets/images/onboarding_illustration_3.png',
                            fit: BoxFit.fill,
                            gaplessPlayback: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // "You don't have to figure it out " + gradient "alone" inline
              Padding(
                padding: const EdgeInsets.only(left: _textLeft),
                child: SizedBox(
                  width: size.width - _textLeft * 2,
                  child: RichText(
                    text: TextSpan(
                      style: headingStyle,
                      children: [
                        const TextSpan(text: "You don't have to figure it out "),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xFF7F89E9), Color(0xFFA87CC7), Color(0xFF658852)],
                              stops: [0.0, 0.565, 1.0],
                            ).createShader(bounds),
                            child: Text('alone', style: headingStyle.copyWith(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _buildDescription(size,
                  'Your mental wellness companion, providing AI insights, VR experiences, and licensed therapists. Discover resources tailored to you.'),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _Ellipse extends StatelessWidget {
  final double w, h, left, top;
  final Color color;
  const _Ellipse({required this.w, required this.h, required this.left, required this.top, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: w,
        height: h,
        decoration: ShapeDecoration(color: color, shape: const OvalBorder()),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: isActive ? 69.0 : 9.0,
              height: 9.0,
              decoration: isActive
                  ? BoxDecoration(color: const Color(0xFF7F89E9), borderRadius: BorderRadius.circular(30))
                  : const ShapeDecoration(color: Color(0xFFD2D5DE), shape: OvalBorder()),
            ),
            if (i < total - 1) const SizedBox(width: 9),
          ],
        );
      }),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF0F0F0)
      ..style = PaintingStyle.fill;
    final sx = size.width / 47;
    final sy = size.height / 47;
    final path = Path()
      ..moveTo(18.2321 * sx, 13.1397 * sy)
      ..cubicTo(18.0505 * sx, 13.3209 * sy, 17.9065 * sx, 13.5361 * sy, 17.8082 * sx, 13.773 * sy)
      ..cubicTo(17.7099 * sx, 14.0099 * sy, 17.6594 * sx, 14.2639 * sy, 17.6594 * sx, 14.5204 * sy)
      ..cubicTo(17.6594 * sx, 14.7768 * sy, 17.7099 * sx, 15.0308 * sy, 17.8082 * sx, 15.2677 * sy)
      ..cubicTo(17.9065 * sx, 15.5046 * sy, 18.0505 * sx, 15.7198 * sy, 18.2321 * sx, 15.901 * sy)
      ..lineTo(25.8304 * sx, 23.4993 * sy)
      ..lineTo(18.2321 * sx, 31.0977 * sy)
      ..cubicTo(17.8659 * sx, 31.4638 * sy, 17.6602 * sx, 31.9604 * sy, 17.6602 * sx, 32.4783 * sy)
      ..cubicTo(17.6602 * sx, 32.9961 * sy, 17.8659 * sx, 33.4927 * sy, 18.2321 * sx, 33.8589 * sy)
      ..cubicTo(18.5982 * sx, 34.2251 * sy, 19.0949 * sx, 34.4308 * sy, 19.6127 * sx, 34.4308 * sy)
      ..cubicTo(20.1305 * sx, 34.4308 * sy, 20.6272 * sx, 34.2251 * sy, 20.9933 * sx, 33.8589 * sy)
      ..lineTo(29.9821 * sx, 24.8702 * sy)
      ..cubicTo(30.1636 * sx, 24.689 * sy, 30.3076 * sx, 24.4738 * sy, 30.4059 * sx, 24.2369 * sy)
      ..cubicTo(30.5042 * sx, 24.0 * sy, 30.5548 * sx, 23.746 * sy, 30.5548 * sx, 23.4895 * sy)
      ..cubicTo(30.5548 * sx, 23.233 * sy, 30.5042 * sx, 22.9791 * sy, 30.4059 * sx, 22.7422 * sy)
      ..cubicTo(30.3076 * sx, 22.5053 * sy, 30.1636 * sx, 22.2901 * sy, 29.9821 * sx, 22.1089 * sy)
      ..lineTo(20.9933 * sx, 13.1202 * sy)
      ..cubicTo(20.2491 * sx, 12.376 * sy, 18.9958 * sx, 12.376 * sy, 18.2321 * sx, 13.1397 * sy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
