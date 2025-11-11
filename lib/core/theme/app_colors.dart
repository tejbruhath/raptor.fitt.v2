import 'package:flutter/material.dart';

class AppColors {
  // Base colors
  static const Color background = Color(0xFF0A0A0A);  // Pure black
  static const Color surface = Color(0xFF1A1A1A);     // Dark grey cards
  static const Color surfaceVariant = Color(0xFF2A2A2A);
  
  // Primary colors (Neon purple/blue gradient)
  static const Color primary = Color(0xFF6B5FED);      // Electric purple
  static const Color primaryLight = Color(0xFF8B7FFF);
  static const Color primaryDark = Color(0xFF5344D9);
  
  // Secondary colors
  static const Color secondary = Color(0xFF7C3AED);    // Deep purple
  static const Color secondaryLight = Color(0xFF9D5AFF);
  
  // Accent colors
  static const Color accent = Color(0xFF3B82F6);       // Electric blue
  static const Color accentLight = Color(0xFF60A5FA);
  static const Color accentDark = Color(0xFF2563EB);
  
  // Neon colors
  static const Color neonGreen = Color(0xFF10F4B4);
  static const Color neonPink = Color(0xFFFF3D7F);
  static const Color neonBlue = Color(0xFF3EDFFF);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);
  
  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6B5FED), Color(0xFF8B7FFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B7FFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient neonGradient = LinearGradient(
    colors: [Color(0xFF10F4B4), Color(0xFF3EDFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Chart colors
  static const Color chartBlue = Color(0xFF3B82F6);
  static const Color chartPurple = Color(0xFF8B7FFF);
  static const Color chartGreen = Color(0xFF10B981);
  static const Color chartYellow = Color(0xFFF59E0B);
  static const Color chartRed = Color(0xFFEF4444);
  
  // UI elements
  static const Color divider = Color(0xFF2A2A2A);
  static const Color overlay = Color(0x80000000);
  static const Color shadow = Color(0x40000000);
  
  // Opacity variations
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
