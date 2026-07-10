import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  String _role = 'patient';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _role = ModalRoute.of(context)?.settings.arguments as String? ?? 'patient';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _signUp() {
    if (_role == 'therapist') {
      Navigator.pushReplacementNamed(context, '/therapist-home');
    } else {
      Navigator.pushReplacementNamed(context, '/patient-home');
    }
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, '/login', arguments: _role);
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
              _buildHeader(s, size.width),

              // gap: header(210) → tab top(248) = 38
              SizedBox(height: 38 * s),

              // ── Segmented tab (Sign Up active) ────────────────────────────
              // Figma: left=66, top=248, w=298, h=47
              Padding(
                padding: EdgeInsets.only(left: 66 * s),
                child: _buildTabBar(s),
              ),

              // gap: tab bottom(295) → form top(324) = 29
              SizedBox(height: 29 * s),

              // ── Form ──────────────────────────────────────────────────────
              // Figma: centered w=364, no inner px padding
              // margin = (430-364)/2 = 33px each side
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 33 * s),
                child: _buildForm(s),
              ),

              // gap: form bottom(873) → screen bottom(932) = 59
              SizedBox(height: 59 * s),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header — identical to login (same PNG, same title, same top=62) ────────
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

  // ── Tab bar — Sign Up variant (Sign Up active) ─────────────────────────────
  // Figma layering (bottom→top):
  //   1. Container bg #A3ABFF (full pill)
  //   2. Log In div: #A3ABFF, left 0→44.3% (inactive, blends with container)
  //   3. Sign Up div: #7F89E9, left 39.93%→100% (active, darker, on top)
  // Result: left 44.3% = #A3ABFF (Log In inactive), right 55.7% = #7F89E9 (Sign Up active)
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
          // 1. Container bg
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFA3ABFF),
              borderRadius: BorderRadius.circular(30 * s),
            ),
          ),

          // 2. Log In — same as container (#A3ABFF), left 0→44.3%, inactive
          Positioned(
            left: 0,
            top: 0,
            right: w * 0.557,
            bottom: 0,
            child: GestureDetector(
              onTap: _goToLogin,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFA3ABFF),
                  borderRadius: BorderRadius.circular(30 * s),
                ),
                child: Center(child: Text('Log In', style: textStyle)),
              ),
            ),
          ),

          // 3. Sign Up — #7F89E9, left 39.93%→100%, active, renders on top
          Positioned(
            left: w * 0.3993,
            top: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF7F89E9),
                borderRadius: BorderRadius.circular(30 * s),
              ),
              child: Center(child: Text('Sign Up', style: textStyle)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Form ────────────────────────────────────────────────────────────────────
  // Figma: w=364, gap=25 between field groups, all inputs radius=20
  // Confirm Password label→input gap is 14px (not 6px like the others)
  Widget _buildForm(double s) {
    const r = 20.0; // all inputs use radius=20 in Sign Up

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name
        _FieldLabel('Name', s),
        SizedBox(height: 6 * s),
        _InputField(
          controller: _nameCtrl,
          hint: 'Enter Your Name',
          icon: Icons.person_outline_rounded,
          radius: r * s,
          s: s,
        ),

        SizedBox(height: 25 * s),

        // Email
        _FieldLabel('Email', s),
        SizedBox(height: 6 * s),
        _InputField(
          controller: _emailCtrl,
          hint: 'Enter Your Email',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          radius: r * s,
          s: s,
        ),

        SizedBox(height: 25 * s),

        // Password
        _FieldLabel('Password', s),
        SizedBox(height: 6 * s),
        _InputField(
          controller: _passwordCtrl,
          hint: 'Enter Your Password',
          icon: Icons.lock_outline_rounded,
          obscure: true,
          radius: r * s,
          s: s,
        ),

        SizedBox(height: 25 * s),

        // Confirm Password — note: label→input gap is 14px, not 6px (Figma spec)
        _FieldLabel('Confirm Password', s),
        SizedBox(height: 14 * s),
        _InputField(
          controller: _confirmCtrl,
          hint: 'Confirm Your Password',
          icon: Icons.lock_outline_rounded,
          obscure: true,
          radius: r * s,
          s: s,
        ),

        SizedBox(height: 25 * s),

        // Sign Up button — Figma: w=full(364), h=55, gradient, radius=20, Medium 24px
        GestureDetector(
          onTap: _signUp,
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
                'Sign Up',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFF0F0F0),
                  fontSize: 24 * s,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 25 * s),

        // Social icons — centered, same as login screen
        Center(child: _buildSocialIcons(s)),
      ],
    );
  }

  Widget _buildSocialIcons(double s) {
    const color = Color(0xFF7F89E9);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {},
          child: Icon(Icons.g_mobiledata_rounded, color: color, size: 28 * s),
        ),
        SizedBox(width: 31 * s),
        GestureDetector(
          onTap: () {},
          child: Icon(Icons.facebook_rounded, color: color, size: 24 * s),
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
    // Figma: h=47, border 1px #424242, pl=42 (icon space), no fill (transparent)
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
