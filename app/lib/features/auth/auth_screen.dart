import 'dart:ui' show lerpDouble;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/app_state.dart';

class AuthScreen extends StatefulWidget {
  final int initialPage; // 0 = login, 1 = signup
  const AuthScreen({super.key, this.initialPage = 0});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageCtrl;
  late final AnimationController _tabAnim;
  int _currentPage = 0;
  String _role = 'patient';
  bool _loading = false;
  String _error = '';

  final _loginEmailCtrl    = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  final _signupNameCtrl    = TextEditingController();
  final _signupEmailCtrl   = TextEditingController();
  final _signupPassCtrl    = TextEditingController();
  final _signupConfirmCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageCtrl = PageController(initialPage: widget.initialPage);
    _tabAnim  = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      value: widget.initialPage.toDouble(),
    );
    // Mirror the PageController's fractional position into _tabAnim.
    // animateToPage() drives _pageCtrl.page continuously, so the pill
    // follows the eased curve frame-by-frame.
    _pageCtrl.addListener(() {
      final p = _pageCtrl.page;
      if (p != null) _tabAnim.value = p.clamp(0.0, 1.0);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _role = ModalRoute.of(context)?.settings.arguments as String? ?? 'patient';
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _tabAnim.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _signupNameCtrl.dispose();
    _signupEmailCtrl.dispose();
    _signupPassCtrl.dispose();
    _signupConfirmCtrl.dispose();
    super.dispose();
  }

  void _switchTo(int page) {
    if (_currentPage == page) return;
    setState(() => _currentPage = page);
    _pageCtrl.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _login() async {
    final email = _loginEmailCtrl.text.trim();
    final pass  = _loginPasswordCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    setState(() { _loading = true; _error = ''; });
    try {
      final role = await AuthService.signIn(email, pass);
      await AppState.instance.loadForUser();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
          context, role == 'therapist' ? '/therapist-home' : '/patient-home');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _authError(e.code));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signUp() async {
    final name    = _signupNameCtrl.text.trim();
    final email   = _signupEmailCtrl.text.trim();
    final pass    = _signupPassCtrl.text;
    final confirm = _signupConfirmCtrl.text;
    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    if (pass != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    setState(() { _loading = true; _error = ''; });
    try {
      final role = await AuthService.signUp(
          name: name, email: email, password: pass, role: _role);
      await AppState.instance.loadForUser();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
          context, role == 'therapist' ? '/therapist-home' : '/patient-home');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _authError(e.code));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final role = await AuthService.signInWithGoogle(role: _role);
      await AppState.instance.loadForUser();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
          context, role == 'therapist' ? '/therapist-home' : '/patient-home');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _authError(e.code));
    } catch (e) {
      final msg = e.toString();
      if (!msg.contains('cancelled')) {
        setState(() => _error = 'Google sign-in failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _authError(String code) => switch (code) {
    'user-not-found'     => 'No account found for this email.',
    'wrong-password'     => 'Incorrect password.',
    'invalid-email'      => 'Invalid email address.',
    'email-already-in-use' => 'An account already exists with this email.',
    'weak-password'      => 'Password must be at least 6 characters.',
    'invalid-credential' => 'Invalid email or password.',
    _                    => 'Something went wrong. Please try again.',
  };

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s    = size.width / 430;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(children: [
        Column(
          children: [
            // Header stays fixed — does NOT scroll
            _buildHeader(s, size.width),
            SizedBox(height: 38 * s),
            Center(child: _buildTabBar(s)),
            // Both form pages scroll independently inside Expanded
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _currentPage = i),
                // Disable swipe — only the tab bar triggers page changes
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildLoginPage(s),
                  _buildSignupPage(s),
                ],
              ),
            ),
          ],
        ),
        if (_loading)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF7F89E9)),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Header (shared, identical on both pages) ─────────────────────────────────
  Widget _buildHeader(double s, double w) {
    return SizedBox(
      width: w,
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
              text: TextSpan(children: [
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
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Animated tab bar ──────────────────────────────────────────────────────────
  //
  // The pill slides and resizes between two Figma-defined widths:
  //   Login  pill: left=0,              w=52.68% of 298 (from Figma inset right=47.32%)
  //   Signup pill: left=39.93% of 298,  w=60.07% of 298 (from Figma inset left=39.93%)
  //
  // Container bg is always #A3ABFF (lighter); pill is always #7F89E9 (darker).
  // _tabAnim.value = 0 → login state, 1 → signup state (fractional during animation).
  Widget _buildTabBar(double s) {
    final tabW        = 298 * s;
    final tabH        = 47 * s;
    final loginPillW  = tabW * 0.5268;
    final signupPillW = tabW * 0.6007;
    final signupLeft  = tabW * 0.3993; // = tabW - signupPillW

    final labelStyle = GoogleFonts.poppins(
      color: const Color(0xFFF0F0F0),
      fontSize: 20 * s,
      fontWeight: FontWeight.w400,
      height: 1.208,
      letterSpacing: -1.0 * s,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(30 * s),
      child: SizedBox(
        width: tabW,
        height: tabH,
        child: ColoredBox(
          color: const Color(0xFFA3ABFF),
          child: AnimatedBuilder(
            animation: _tabAnim,
            builder: (_, __) {
              final v = _tabAnim.value;
              final left  = lerpDouble(0,           signupLeft,  v)!;
              final width = lerpDouble(loginPillW,  signupPillW, v)!;

              return Stack(
                children: [
                  // Sliding pill
                  Positioned(
                    left: left,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: width,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7F89E9),
                        borderRadius: BorderRadius.circular(30 * s),
                      ),
                    ),
                  ),

                  // "Log In" tap zone — left half (non-overlapping with Sign Up)
                  Positioned(
                    left: 0,
                    top: 0,
                    right: tabW * 0.4732,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () => _switchTo(0),
                      behavior: HitTestBehavior.opaque,
                      child: Center(child: Text('Log In', style: labelStyle)),
                    ),
                  ),

                  // "Sign Up" tap zone — right portion
                  Positioned(
                    left: tabW * 0.3993,
                    top: 0,
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () => _switchTo(1),
                      behavior: HitTestBehavior.opaque,
                      child: Center(child: Text('Sign Up', style: labelStyle)),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Login page ───────────────────────────────────────────────────────────────
  // Top padding = 64s so the form lands at Figma's 361px (tab bottom 297 + 64 = 361).
  Widget _buildLoginPage(double s) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 64 * s),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 36 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('Email', s),
                SizedBox(height: 6 * s),
                _InputField(
                  controller: _loginEmailCtrl,
                  hint: 'Enter Your Email',
                  icon: Icons.mail_outline_rounded,
                  radius: 15 * s,
                  keyboardType: TextInputType.emailAddress,
                  s: s,
                ),
                SizedBox(height: 25 * s),
                _FieldLabel('Password', s),
                SizedBox(height: 6 * s),
                _InputField(
                  controller: _loginPasswordCtrl,
                  hint: 'Enter Your Password',
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                  radius: 20 * s,
                  s: s,
                ),
              ],
            ),
          ),
          if (_error.isNotEmpty && _currentPage == 0) ...[
            SizedBox(height: 16 * s),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 36 * s),
              child: Text(_error,
                  style: GoogleFonts.poppins(
                      color: Colors.redAccent, fontSize: 12 * s)),
            ),
          ],
          SizedBox(height: _error.isNotEmpty && _currentPage == 0 ? 16 * s : 224 * s),
          Padding(
            padding: EdgeInsets.only(left: 35 * s, right: 37 * s),
            child: _ActionButton(
              label: 'Log In',
              fontSize: 22 * s,
              onTap: _loading ? () {} : _login,
              s: s,
            ),
          ),
          SizedBox(height: 25 * s),
          Center(child: _SocialIcons(s: s, onGoogleTap: _loading ? null : _signInWithGoogle)),
          SizedBox(height: 68 * s),
        ],
      ),
    );
  }

  // ── Signup page ──────────────────────────────────────────────────────────────
  // Top padding = 29s so form lands at Figma's 324px (tab bottom 295 + 29 = 324).
  Widget _buildSignupPage(double s) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 29 * s),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 33 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('Name', s),
                SizedBox(height: 6 * s),
                _InputField(
                  controller: _signupNameCtrl,
                  hint: 'Enter Your Name',
                  icon: Icons.person_outline_rounded,
                  radius: 20 * s,
                  s: s,
                ),
                SizedBox(height: 25 * s),
                _FieldLabel('Email', s),
                SizedBox(height: 6 * s),
                _InputField(
                  controller: _signupEmailCtrl,
                  hint: 'Enter Your Email',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  radius: 20 * s,
                  s: s,
                ),
                SizedBox(height: 25 * s),
                _FieldLabel('Password', s),
                SizedBox(height: 6 * s),
                _InputField(
                  controller: _signupPassCtrl,
                  hint: 'Enter Your Password',
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                  radius: 20 * s,
                  s: s,
                ),
                SizedBox(height: 25 * s),
                _FieldLabel('Confirm Password', s),
                SizedBox(height: 14 * s), // Figma: 14px for confirm, not 6px
                _InputField(
                  controller: _signupConfirmCtrl,
                  hint: 'Confirm Your Password',
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                  radius: 20 * s,
                  s: s,
                ),
                SizedBox(height: 25 * s),
                if (_error.isNotEmpty && _currentPage == 1) ...[
                  Text(_error,
                      style: GoogleFonts.poppins(
                          color: Colors.redAccent, fontSize: 12 * s)),
                  SizedBox(height: 10 * s),
                ],
                _ActionButton(
                  label: 'Sign Up',
                  fontSize: 24 * s,
                  onTap: _loading ? () {} : _signUp,
                  s: s,
                ),
                SizedBox(height: 25 * s),
                Center(child: _SocialIcons(s: s, onGoogleTap: _loading ? null : _signInWithGoogle)),
              ],
            ),
          ),
          SizedBox(height: 59 * s),
        ],
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  final double s;
  const _FieldLabel(this.text, this.s);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.poppins(
          color: const Color(0xFF424242),
          fontSize: 20 * s,
          fontWeight: FontWeight.w500,
        ),
      );
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
    return Container(
      height: 47 * s,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF424242)),
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
            prefixIconConstraints:
                BoxConstraints(minWidth: 42 * s, minHeight: 47 * s),
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

class _ActionButton extends StatelessWidget {
  final String label;
  final double fontSize;
  final VoidCallback onTap;
  final double s;

  const _ActionButton({
    required this.label,
    required this.fontSize,
    required this.onTap,
    required this.s,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
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
              label,
              style: GoogleFonts.poppins(
                color: const Color(0xFFF0F0F0),
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
}

class _SocialIcons extends StatelessWidget {
  final double s;
  final VoidCallback? onGoogleTap;
  const _SocialIcons({required this.s, this.onGoogleTap});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF7F89E9);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onGoogleTap,
          child: Opacity(
            opacity: onGoogleTap == null ? 0.4 : 1.0,
            child: Icon(Icons.g_mobiledata_rounded, color: color, size: 28 * s),
          ),
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
