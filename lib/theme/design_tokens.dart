import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Color Palette Tokens ---
  static const Color primaryAccent = Color(0xFFFF5722);
  static const Color primaryGradientStart = Color(0xFFFF8A00);
  static const Color primaryGradientEnd = Color(0xFFFF3D00);
  
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningGold = Color(0xFFFFC107);
  static const Color errorRed = Color(0xFFFF5252);
  
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceElevated = Color(0xFF2C2C2C);
  static const Color darkBorder = Color(0xFF383838);
  
  static const Color textPrimary = Color(0xffffffff);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textMuted = Color(0xFF757575);

  static const Color glassBackground = Color(0xC01E1E1E); // rgba(30, 30, 30, 0.75)
  static const Color glassBorder = Color(0x14FFFFFF); // rgba(255, 255, 255, 0.08)

  // --- Gradients ---
  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryGradientStart, primaryGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient glassGlowGradient = LinearGradient(
    colors: [Color(0x264CAF50), Color(0x0D4CAF50)], // green glow
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Border Radii ---
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;

  static BorderRadius get borderSmall => BorderRadius.circular(radiusSmall);
  static BorderRadius get borderMedium => BorderRadius.circular(radiusMedium);
  static BorderRadius get borderLarge => BorderRadius.circular(radiusLarge);

  // --- Shadows ---
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 30,
      offset: const Offset(0, 8),
    )
  ];

  static List<BoxShadow> get glassShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.37),
      blurRadius: 32,
      offset: const Offset(0, 8),
    )
  ];

  // --- ThemeData Definition ---
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryAccent,
        secondary: successGreen,
        surface: darkSurface,
        background: darkBackground,
        error: errorRed,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: textMuted,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: borderMedium),
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: borderLarge),
      ),
    );
  }
}
