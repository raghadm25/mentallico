import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF7F89E9);
  static const Color secondary = Color(0xFFA87CC7);
  static const Color background = Color(0xFFF0F0F0);
  static const Color black = Color(0xFF292929);
  static const Color darkGray = Color(0xFF595959);
  static const Color lightGray = Color(0xFFD2D5DE);
  static const Color white = Color(0xFFFFFFFF);
  static const Color green = Color(0xFF658852);
  static const Color darkGreen = Color(0xFF1A2E12);
  static const Color error = Color(0xFFE57373);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)],
  );
}
