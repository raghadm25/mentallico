import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/app_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotController;
  int _activeDot = 0;

  // Returns [opacity for dot0, dot1, dot2]
  // Active dot = 1.0, just-passed dot = 0.50, upcoming dot = 0.75
  // Matches Figma frame 0: [1.0, 0.75, 0.50]
  List<double> get _opacities {
    return List.generate(3, (i) {
      if (i == _activeDot) return 1.0;
      if (i == (_activeDot - 1 + 3) % 3) return 0.50;
      return 0.75;
    });
  }

  @override
  void initState() {
    super.initState();

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _activeDot = (_activeDot + 1) % 3);
          _dotController.reset();
          _dotController.forward();
        }
      });
    _dotController.forward();

    Future.delayed(const Duration(milliseconds: 2700), () async {
      if (!mounted) return;
      final user = AuthService.currentUser;
      if (user != null) {
        final role = await AuthService.getRole();
        await AppState.instance.loadForUser();
        if (!mounted) return;
        Navigator.pushReplacementNamed(
            context, role == 'therapist' ? '/therapist-home' : '/patient-home');
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ops = _opacities;

    return Scaffold(
      backgroundColor: const Color(0xFF7F89E9),
      body: SizedBox.expand(
        child: Stack(
          children: [
            // "Mentallico" — exact Figma position scaled to screen
            Positioned(
              left: size.width * (73 / 430),
              top: size.height * (428 / 932),
              child: Text(
                'Mentallico',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFF0F0F0),
                  fontSize: 64,
                  fontWeight: FontWeight.w600,
                  height: 1.21,
                  letterSpacing: -6.40,
                ),
              ),
            ),
            // Loading dots — exact Figma position scaled to screen
            Positioned(
              left: size.width * (190 / 430),
              top: size.height * (750 / 932),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  return Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 8.0 : 0),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: ops[i],
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: const ShapeDecoration(
                          color: Color(0xFFF0F0F0),
                          shape: OvalBorder(),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
