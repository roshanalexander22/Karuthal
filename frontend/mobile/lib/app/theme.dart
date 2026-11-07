import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sahaayi Design System — Minimalist, Elderly-Friendly, High-Contrast Palette.
///
/// Palette specifications:
/// - Background:     #F8FAFC (Soft off-white / slate tint)
/// - Primary:        #4EAD91 (Mint green / emerald)
/// - Primary Dark:   #3B8973
/// - Secondary:      #DFF3EC (Light mint pastel)
/// - Accent:         #DCEBFA (Soft pastel blue)
/// - Card Surface:   #FFFFFF (Pure crisp white)
/// - Text Main:      #263238 (Dark charcoal)
/// - Text Secondary: #718096 (Slate grey)
/// - Lavender:       #EDE9FE (Subtle soft purple)
/// - Rose/Alert:     #FEE2E2 (Soft warning/emergency tint)
abstract final class SahaayiColors {
  static const Color background = Color(0xFFF8FAFC);
  static const Color primary = Color(0xFF4EAD91);
  static const Color primaryDark = Color(0xFF3B8973);
  static const Color secondary = Color(0xFFDFF3EC);
  static const Color accent = Color(0xFFDCEBFA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textMain = Color(0xFF263238);
  static const Color textSecondary = Color(0xFF718096);
  static const Color border = Color(0xFFE2E8F0);
  static const Color lavender = Color(0xFFEDE9FE);
  static const Color rose = Color(0xFFFEE2E2);
  static const Color emergency = Color(0xFFE53E3E);
  static const Color success = Color(0xFF38A169);
  static const Color warning = Color(0xFFDD6B20);
}

abstract final class SahaayiTheme {
  static TextTheme _buildTextTheme() {
    TextStyle font(double size, FontWeight weight, Color color) {
      return GoogleFonts.notoSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: 0.15,
      );
    }

    return TextTheme(
      displayLarge: font(32, FontWeight.w700, SahaayiColors.textMain),
      displayMedium: font(28, FontWeight.w700, SahaayiColors.textMain),
      displaySmall: font(24, FontWeight.w600, SahaayiColors.textMain),

      headlineLarge: font(26, FontWeight.w700, SahaayiColors.textMain),
      headlineMedium: font(24, FontWeight.w600, SahaayiColors.textMain),
      headlineSmall: font(22, FontWeight.w600, SahaayiColors.textMain),

      titleLarge: font(22, FontWeight.w700, SahaayiColors.textMain),
      titleMedium: font(20, FontWeight.w600, SahaayiColors.textMain),
      titleSmall: font(18, FontWeight.w500, SahaayiColors.textMain),

      // Elderly-accessible body minimum size >= 18sp
      bodyLarge: font(18, FontWeight.w500, SahaayiColors.textMain),
      bodyMedium: font(16, FontWeight.w400, SahaayiColors.textMain),
      bodySmall: font(14, FontWeight.w400, SahaayiColors.textSecondary),

      labelLarge: font(18, FontWeight.w600, SahaayiColors.textMain),
      labelMedium: font(16, FontWeight.w500, SahaayiColors.textSecondary),
      labelSmall: font(13, FontWeight.w500, SahaayiColors.textSecondary),
    );
  }

  static ThemeData get lightTheme {
    final textTheme = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: SahaayiColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: SahaayiColors.primary,
        onPrimary: Colors.white,
        primaryContainer: SahaayiColors.secondary,
        onPrimaryContainer: SahaayiColors.primaryDark,
        secondary: SahaayiColors.accent,
        onSecondary: SahaayiColors.textMain,
        secondaryContainer: SahaayiColors.accent,
        onSecondaryContainer: SahaayiColors.textMain,
        tertiary: SahaayiColors.lavender,
        onTertiary: SahaayiColors.textMain,
        error: SahaayiColors.emergency,
        onError: Colors.white,
        surface: SahaayiColors.card,
        onSurface: SahaayiColors.textMain,
        surfaceContainerHighest: SahaayiColors.secondary,
        outline: SahaayiColors.border,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: SahaayiColors.background,
        foregroundColor: SahaayiColors.textMain,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: SahaayiColors.textMain,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: SahaayiColors.textMain,
          size: 26,
        ),
      ),
      cardTheme: CardThemeData(
        color: SahaayiColors.card,
        elevation: 1.5,
        shadowColor: const Color(0x14000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: SahaayiColors.border, width: 1.2),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SahaayiColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(120, 56), // Accessible >= 56dp height
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SahaayiColors.primaryDark,
          minimumSize: const Size(120, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: const BorderSide(color: SahaayiColors.primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            color: SahaayiColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SahaayiColors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle:
            textTheme.bodyMedium?.copyWith(color: SahaayiColors.textSecondary),
        labelStyle:
            textTheme.bodyLarge?.copyWith(color: SahaayiColors.textMain),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: SahaayiColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: SahaayiColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide:
              const BorderSide(color: SahaayiColors.primary, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide:
              const BorderSide(color: SahaayiColors.emergency, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SahaayiColors.card,
        selectedItemColor: SahaayiColors.primary,
        unselectedItemColor: SahaayiColors.textSecondary,
        selectedLabelStyle:
            TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        unselectedLabelStyle:
            TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // Fallback to light theme to enforce single consistent light design system
  static ThemeData get darkTheme => lightTheme;
}
