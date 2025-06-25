import 'package:flutter/material.dart';

/// App color constants following the Hopin design system
/// Based on the UI specification with student-friendly, modern colors
class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF2563EB);      // #2563EB (Blue)
  static const Color secondary = Color(0xFF059669);    // #059669 (Green)  
  static const Color accent = Color(0xFFDC2626);       // #DC2626 (Red)
  
  // Surface Colors
  static const Color surface = Color(0xFFFFFFFF);      // #FFFFFF (White)
  static const Color background = Color(0xFFF8FAFC);   // #F8FAFC (Light Gray)
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);   // #0F172A (Dark Slate)
  static const Color textSecondary = Color(0xFF64748B); // #64748B (Slate)
  
  // Status Colors
  static const Color success = Color(0xFF059669);      // #059669 (Green)
  static const Color warning = Color(0xFFD97706);      // #D97706 (Orange)
  static const Color error = Color(0xFFDC2626);        // #DC2626 (Red)
  
  // Additional UI Colors
  static const Color divider = Color(0xFFE2E8F0);      // Light divider
  static const Color disabled = Color(0xFF94A3B8);     // Disabled elements
  static const Color overlay = Color(0x80000000);      // Semi-transparent overlay
  
  // Gradient Colors for modern UI
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2563EB),
      Color(0xFF1D4ED8),
    ],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF059669),
      Color(0xFF047857),
    ],
  );
  
  // Student-focused accent colors
  static const Color studentBlue = Color(0xFF3B82F6);   // Friendly blue
  static const Color campusGreen = Color(0xFF10B981);   // Campus green
  static const Color safetyOrange = Color(0xFFF59E0B);  // Safety warnings
  
  // Verification badge colors
  static const Color verified = Color(0xFF059669);      // Green for verified
  static const Color pending = Color(0xFFD97706);       // Orange for pending
  static const Color unverified = Color(0xFF64748B);    // Gray for unverified
}

/// Extension to add opacity methods to colors
extension AppColorsExtension on Color {
  Color withOpacityValue(double opacity) {
    return withOpacity(opacity.clamp(0.0, 1.0));
  }
}