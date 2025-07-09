import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFFEAB308);
  static const Color primaryDark = Color(0xFF10182B);
  
  // Dark theme colors
  static const Color backgroundPrimary = Color(0xFF1E293B);
  static const Color backgroundSecondary = Color(0xFF10182B);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.grey;
  static const Color borderPrimary = Color(0xFFEAB308);
  static const Color borderSecondary = Colors.grey;
  static const Color overlayLight = Color(0x1AFFFFFF); // 10% white
  static const Color overlayPrimary = Color(0x1AEAB308); // 10% primary
  
  // Light theme colors
  static const Color lightBackgroundPrimary = Color(0xFFF8FAFC);
  static const Color lightBackgroundSecondary = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorderPrimary = Color(0xFFEAB308);
  static const Color lightBorderSecondary = Color(0xFFCBD5E1);
  static const Color lightOverlayLight = Color(0x1A000000); // 10% black
  static const Color lightOverlayPrimary = Color(0x1AEAB308); // 10% primary

  // Additional Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color green = Color(0xFF4CAF50);
  static const Color red = Color(0xFFF44336);
  static const Color black = Color(0xFF000000);

  // Helper methods for colors with alpha/opacity
  static Color whiteWithAlpha(double alpha) => white.withOpacity(alpha);
  static Color greyWithAlpha(double alpha) => grey.withOpacity(alpha);
  static Color primaryWithAlpha(double alpha) => primary.withOpacity(alpha);
  static Color orangeWithAlpha(double alpha) => Colors.orange.withOpacity(alpha);
  static Color withAlpha(Color color, double alpha) => color.withOpacity(alpha);
  static Color withOpacity(Color color, double opacity) => color.withOpacity(opacity);
} 