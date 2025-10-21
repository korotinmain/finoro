import 'package:flutter/material.dart';

/// Centralized color constants for consistent theming across the app
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const primaryPurple = Color(0xFF6D4AFF);
  static const primaryBlue = Color(0xFF5B7CFF);
  static const lightBlue = Color(0xFF3EA7FF);
  static const deepPurple = Color(0xFF7D48FF);
  static const vibrantPurple = Color(0xFF505BFF);
  static const lightPurple = Color(0xFF8B5CF6);
  static const cyan = Color(0xFF22D3EE);

  // Background Colors
  static const darkBackground = Color(0xFF0D0E12);
  static const darkSecondary = Color(0xFF181A23);
  static const cardBackground = Color(0xFF141519);
  static const glassBackground = Color(0xFF1F2126);
  static const navBarBackground = Color(0xFF121317);

  // Gradient Colors
  static const gradientStart1 = Color(0xFF0D0F19);
  static const gradientMid1 = Color(0xFF0B0E15);
  static const gradientEnd1 = Color(0xFF0A0B12);

  // Status Colors
  static const statusVerified = Colors.greenAccent;
  static const statusUnverified = Colors.orangeAccent;
  static const badgeVerified = Colors.lightGreenAccent;
  static const badgeUnverified = Colors.amberAccent;

  // Opacity helpers
  static Color white(double alpha) => Colors.white.withValues(alpha: alpha);
  static Color black(double alpha) => Colors.black.withValues(alpha: alpha);

  // Common Gradients
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [vibrantPurple, deepPurple],
  );

  static const buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, primaryBlue],
  );

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkBackground, darkSecondary],
  );

  static const authBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart1, gradientMid1, gradientEnd1],
  );
}
