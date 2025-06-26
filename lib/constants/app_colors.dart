import 'package:flutter/material.dart';

/// App color scheme following the Hopin brand guidelines
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF2563EB); // Blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // Secondary Colors
  static const Color secondary = Color(0xFF059669); // Green
  static const Color secondaryLight = Color(0xFF10B981);
  static const Color secondaryDark = Color(0xFF047857);

  // Accent Colors
  static const Color accent = Color(0xFFDC2626); // Red
  static const Color accentLight = Color(0xFFEF4444);
  static const Color accentDark = Color(0xFFB91C1C);

  // Surface Colors
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color background = Color(0xFFF8FAFC); // Light gray
  static const Color backgroundDark = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textLight = Color(0xFFCBD5E1);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDEF7FF);

  // Ride Status Colors
  static const Color rideActive = secondary;
  static const Color rideFull = Color(0xFFEA580C); // Orange
  static const Color rideCompleted = Color(0xFF6B7280); // Gray
  static const Color rideCancelled = accent;

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);

  // Border Colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);
  static const Color borderDark = Color(0xFF94A3B8);

  // Location Type Colors (for location picker)
  static const Color locationCampus = primary;
  static const Color locationResidence = secondary;
  static const Color locationAcademic = Color(0xFF7C3AED); // Purple
  static const Color locationShopping = Color(0xFFEA580C); // Orange
  static const Color locationTransport = Color(0xFF0891B2); // Cyan
  static const Color locationRestaurant = accent;
  static const Color locationOther = Color(0xFF6B7280); // Gray

  // Rating Colors
  static const Color ratingGold = Color(0xFFFBBF24);
  static const Color ratingBackground = Color(0xFFF3F4F6);

  // Interactive Colors
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = surface;
  static const Color buttonDisabled = Color(0xFFE5E7EB);
  static const Color textOnPrimary = surface;
  static const Color textOnSecondary = textPrimary;

  // Input Colors
  static const Color inputBackground = surface;
  static const Color inputBorder = borderLight;
  static const Color inputFocus = primary;
  static const Color inputError = error;

  /// Get color scheme for Material Theme
  static ColorScheme get colorScheme => const ColorScheme.light(
        primary: primary,
        primaryContainer: Color(0xFFE0E7FF),
        secondary: secondary,
        secondaryContainer: Color(0xFFD1FAE5),
        surface: surface,
        background: background,
        error: error,
        onPrimary: surface,
        onSecondary: surface,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: surface,
        brightness: Brightness.light,
      );

  /// Get dark color scheme for Material Theme
  static ColorScheme get darkColorScheme => const ColorScheme.dark(
        primary: primaryLight,
        primaryContainer: Color(0xFF1E3A8A),
        secondary: secondaryLight,
        secondaryContainer: Color(0xFF065F46),
        surface: Color(0xFF1E293B),
        background: Color(0xFF0F172A),
        error: errorLight,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: Color(0xFFF1F5F9),
        onBackground: Color(0xFFF1F5F9),
        onError: textPrimary,
        brightness: Brightness.dark,
      );

  /// Get Material Theme data
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: surface,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: inputFocus, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: inputError),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: inputBackground,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: surface,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Color(0xFFF3F4F6),
          selectedColor: primary.withOpacity(0.1),
          disabledColor: Color(0xFFE5E7EB),
          labelStyle: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        dividerColor: borderLight,
        scaffoldBackgroundColor: background,
      );

  /// Get dark theme data
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      );
}