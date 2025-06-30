import 'package:flutter/material.dart';

/// App color palette for Hopin based on the UI specification
class AppColors {
  // Primary colors from the UI specification
  static const Color primary = Color(0xFF2563EB);       // Blue
  static const Color secondary = Color(0xFF059669);     // Green
  static const Color accent = Color(0xFFDC2626);        // Red
  static const Color surface = Color(0xFFFFFFFF);       // White
  static const Color background = Color(0xFFF8FAFC);    // Light Gray
  
  // Text colors
  static const Color textPrimary = Color(0xFF0F172A);   // Dark Gray
  static const Color textSecondary = Color(0xFF64748B); // Medium Gray
  
  // Status colors
  static const Color success = Color(0xFF059669);       // Green
  static const Color warning = Color(0xFFD97706);       // Orange
  static const Color error = Color(0xFFDC2626);         // Red
  
  // Additional UI colors
  static const Color border = Color(0xFFE2E8F0);        // Light border
  static const Color divider = Color(0xFFCBD5E1);       // Divider
  static const Color disabled = Color(0xFF94A3B8);      // Disabled state
  static const Color shadow = Color(0x1A000000);        // Shadow overlay
  
  // Ride status colors
  static const Color rideActive = Color(0xFF059669);    // Green
  static const Color ridePending = Color(0xFFD97706);   // Orange
  static const Color rideCompleted = Color(0xFF6B7280); // Gray
  static const Color rideCancelled = Color(0xFFDC2626); // Red
  
  // Verification badge colors
  static const Color verified = Color(0xFF059669);      // Green
  static const Color unverified = Color(0xFF6B7280);    // Gray
  static const Color pending = Color(0xFFD97706);       // Orange
  
  // Button colors
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = Color(0xFFE2E8F0);
  static const Color buttonText = Color(0xFFFFFFFF);
  static const Color buttonTextSecondary = textPrimary;
  
  // Input field colors
  static const Color inputBorder = Color(0xFFD1D5DB);
  static const Color inputFocus = primary;
  static const Color inputError = error;
  static const Color inputBackground = surface;
  
  // Navigation colors
  static const Color navActive = primary;
  static const Color navInactive = Color(0xFF9CA3AF);
  static const Color navBackground = surface;
  
  // Card colors
  static const Color cardBackground = surface;
  static const Color cardBorder = border;
  static const Color cardShadow = shadow;
  
  // Rating colors
  static const Color ratingStar = Color(0xFFFABF2A);
  static const Color ratingStarEmpty = Color(0xFFD1D5DB);
  
  // Map colors
  static const Color mapPickup = secondary;
  static const Color mapDestination = accent;
  static const Color mapRoute = primary;
  
  // Price colors
  static const Color priceHigh = Color(0xFFDC2626);     // Red for expensive
  static const Color priceMedium = Color(0xFFD97706);   // Orange for medium
  static const Color priceLow = Color(0xFF059669);      // Green for cheap
  
  // Avatar colors (for default avatars)
  static const List<Color> avatarColors = [
    Color(0xFF3B82F6), // Blue
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF8B5CF6), // Violet
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFF84CC16), // Lime
  ];
  
  /// Get color for ride status
  static Color getRideStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return rideActive;
      case 'pending':
        return ridePending;
      case 'completed':
        return rideCompleted;
      case 'cancelled':
        return rideCancelled;
      default:
        return textSecondary;
    }
  }
  
  /// Get color for verification status
  static Color getVerificationColor(bool isVerified) {
    return isVerified ? verified : unverified;
  }
  
  /// Get color for price range (relative to max price)
  static Color getPriceColor(double price, double maxPrice) {
    final ratio = price / maxPrice;
    if (ratio <= 0.33) return priceLow;
    if (ratio <= 0.66) return priceMedium;
    return priceHigh;
  }
  
  /// Get avatar color based on user ID
  static Color getAvatarColor(String userId) {
    final index = userId.hashCode % avatarColors.length;
    return avatarColors[index.abs()];
  }
}