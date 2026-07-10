import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _role = 'patient';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _role = ModalRoute.of(context)?.settings.arguments as String? ?? 'patient';
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _login() {
    if (_role == 'therapist') {
      Navigator.pushReplacementNamed(context, '/therapist-home');
    } else {
      Navigator.pushReplacementNamed(context, '/patient-home');
    }
  }

  void _goToSignUp() {
    Navigator.pushReplacementNamed(context, '/signup', arguments: _role);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.width / 430;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              // Same pattern PNG as role selection. Title top=62 (not 45).
              _buildHeader(s, size.width),

              // gap: header(210) → tab bar top(250) = 40
              SizedBox(height: 40 * s),

              // ── Log In / Sign Up segmented tab ───────────────────────────
              // Figma: centered, w=298, h=47
              Center(child: _buildTabBar(s)),

              // gap: tab bottom(297) → form top(361) = 64
              SizedBox(height: 64 * s),

              // ── Form ──────────────────────────────────────────────────────
              // Figma: centered w=372, px=7, gap=25 between fields
              // inner left edge = (430-372)/2 + 7 = 36px from screen left
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 36 * s),
                child: _buildForm(s),
              ),

              // gap: form bottom(~540) → button top(764) = 224
              SizedBox(height: 224 * s),

              // ── Log In button ─────────────────────────────────────────────
              // Figma: left=35, w=358, h=55, gradient, radius=20
              Padding(
                padding: EdgeInsets.only(left: 35 * s, right: 37 * s),
                child: _buildLoginButton(s),
              ),

              // gap: button bottom(819) → social top(844) = 25
              SizedBox(height: 25 * s),

              // ── Social icons ──────────────────────────────────────────────
              // Figma: centered, w=87, h=20, Google G + Facebook f
              Center(child: _buildSocialButtons(s)),

              // gap: social bottom(864) → screen bottom(932) = 68
              SizedBox(height: 68 * s),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(double s, double screenWidth) {
    return SizedBox(
      width: screenWidth,
      height: 210 * s,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/role_selection_header_bg.png',
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
          // Title: top=62 (Figma), SemiBold 40px, w=347, centered
          Positioned(
            left: 41.5 * s,
            right: 41.5 * s,
            top: 62 * s,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Start your journey with ',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF424242),
                      fontSize: 40 * s,
                      fontWeight: FontWeight.w600,
                      height: 1.208,
                      letterSpacing: -2.0 * s,
                    ),
                  ),
                  TextSpan(
                    text: 'Mentallico',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFF0F0F0),
                      fontSize: 40 * s,
                      fontWeight: FontWeight.w600,
                      height: 1.208,
                      letterSpacing: -2.0 * s,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Segmented tab bar ───────────────────────────────────────────────────────
  // Figma layering (bottom→top):
  //   1. Container bg #7F89E9 (full pill)
  //   2. Sign Up div: #A3ABFF, left=39.93% → right (rendered below Log In)
  //   3. Log In div: #7F89E9, left=0 → right=47.32% (renders on top)
  // Result: left 52.68% = #7F89E9 (active/Log In), right 47.32% = #A3ABFF (inactive)
  Widget _buildTabBar(double s) {
    final w = 298 * s;
    final h = 47 * s;
    final textStyle = GoogleFonts.poppins(
      color: const Color(0xFFF0F0F0),
      fontSize: 20 * s,
      fontWeight: FontWeight.w400,
      height: 1.208,
      letterSpacing: -1.0 * s,
    );

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        children: [
          // Base fill (same as Log In active color)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF7F89E9),
              borderRadius: BorderRadius.circular(30 * s),
            ),
          ),

          // Sign Up — lighter #A3ABFF, right 60.07% (left from 39.93%)
          Positioned(
            left: w * 0.3993,
            top: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _goToSignUp,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFA3ABFF),
                  borderRadius: BorderRadius.circular(30 * s),
                ),
                child: Center(child: Text('Sign Up', style: textStyle)),
              ),
            ),
          ),

          // Log In — same purple, left 52.68% (right from 47.32%), renders on top
          Positioned(
            left: 0,
            top: 0,
            right: w * 0.4732,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF7F89E9),
                borderRadius: BorderRadius.circular(30 * s),
              ),
              child: Center(child: Text('Log In', style: textStyle)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Form ────────────────────────────────────────────────────────────────────
  Widget _buildForm(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email field — Figma: label Medium 20px #424242, input h=47, radius=15, border #424242
        _FieldLabel('Email', s),
        SizedBox(height: 6 * s),
        _InputField(
          controller: _emailCtrl,
          hint: 'Enter Your Email',
          icon: Icons.mail_outline_rounded,
          radius: 15 * s,
          keyboardType: TextInputType.emailAddress,
          s: s,
        ),

        // Gap between fields = 25 (Figma form gap)
        SizedBox(height: 25 * s),

        // Password field — Figma: same label, input h=47, radius=20 (different!)
        _FieldLabel('Password', s),
        SizedBox(height: 6 * s),
        _InputField(
          controller: _passwordCtrl,
          hint: 'Enter Your Password',
          icon: Icons.lock_outline_rounded,
          radius: 20 * s,
          obscure: true,
          s: s,
        ),
      ],
    );
  }

  // ── Log In button ───────────────────────────────────────────────────────────
  // Figma: w=358, h=55, gradient #7F89E9→#A87CC7, radius=20, Medium 22px
  Widget _buildLoginButton(double s) {
    return GestureDetector(
      onTap: _login,
      child: Container(
        width: double.infinity,
        height: 55 * s,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)],
          ),
          borderRadius: BorderRadius.circular(20 * s),
        ),
        child: Center(
          child: Text(
            'Log In',
            style: GoogleFonts.poppins(
              color: const Color(0xFFF0F0F0),
              fontSize: 22 * s,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ── Social icons ─────────────────────────────────────────────────────────────
  // Figma: w=87, h=20 — Google G and Facebook f, both #7F89E9
  // spacing: (87 - icon1_w - icon2_w) = gap between icons ≈ 47px at Figma scale
  Widget _buildSocialButtons(double s) {
    final iconColor = const Color(0xFF7F89E9);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {},
          child: Icon(Icons.g_mobiledata_rounded, color: iconColor, size: 28 * s),
        ),
        SizedBox(width: 31 * s),
        GestureDetector(
          onTap: () {},
          child: Icon(Icons.facebook_rounded, color: iconColor, size: 24 * s),
        ),
      ],
    );
  }
}

// ─── Shared field widgets ─────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  final double s;
  const _FieldLabel(this.text, this.s);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: const Color(0xFF424242),
        fontSize: 20 * s,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboardType;
  final double radius;
  final double s;

  const _InputField({
    this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    required this.radius,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    // Figma: border 1px #424242, h=47, pl=42 (icon occupies left 42px), no fill
    return Container(
      height: 47 * s,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF424242), width: 1),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(
            color: const Color(0xFF424242),
            fontSize: 14 * s,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: const Color(0xFF595959).withOpacity(0.6),
              fontSize: 14 * s,
            ),
            border: InputBorder.none,
            isDense: true,
            filled: false,
            // Icon occupies the Figma pl=42px space
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF595959).withOpacity(0.6),
              size: 20 * s,
            ),
            prefixIconConstraints: BoxConstraints(
              minWidth: 42 * s,
              minHeight: 47 * s,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 10 * s,
              horizontal: 10 * s,
            ),
          ),
        ),
      ),
    );
  }
}
