import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/onboarding_screen.dart';
import 'features/auth/role_selection_screen.dart';
import 'features/auth/auth_screen.dart';
import 'features/patient/patient_shell.dart';
import 'features/therapist/therapist_shell.dart';

class MentallicoApp extends StatelessWidget {
  const MentallicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mentallico',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/role-selection': (_) => const RoleSelectionScreen(),
        '/login': (_) => const AuthScreen(initialPage: 0),
        '/signup': (_) => const AuthScreen(initialPage: 1),
        '/patient-home': (_) => const PatientShell(),
        '/therapist-home': (_) => const TherapistShell(),
      },
    );
  }
}
