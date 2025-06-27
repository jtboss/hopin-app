import 'package:flutter/material.dart';

/// Enhanced Uber-inspired color scheme for Hopin
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2563EB);      // Vibrant blue
  static const Color secondary = Color(0xFF059669);     // Success green
  static const Color accent = Color(0xFF DC2626);       // Alert red
  
  // Surface Colors
  static const Color surface = Color(0xFFFFFFFF);       // Pure white
  static const Color background = Color(0xFFF8FAFC);    // Subtle gray
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);   // Dark slate
  static const Color textSecondary = Color(0xFF64748B); // Medium slate
  static const Color textHint = Color(0xFF94A3B8);      // Light slate
  
  // Border Colors
  static const Color border = Color(0xFFE2E8F0);        // Light border
  static const Color borderLight = Color(0xFFF1F5F9);   // Very light border
  
  // Status Colors
  static const Color success = Color(0xFF10B981);       // Success green
  static const Color warning = Color(0xFFF59E0B);       // Warning amber
  static const Color error = Color(0xFFEF4444);         // Error red
  static const Color info = Color(0xFF3B82F6);          // Info blue
  
  // Uber-style gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF059669), Color(0xFF047857)],
  );
  
  // Shadow Colors
  static Color shadowLight = Colors.black.withOpacity(0.04);
  static Color shadowMedium = Colors.black.withOpacity(0.08);
  static Color shadowDark = Colors.black.withOpacity(0.12);
}