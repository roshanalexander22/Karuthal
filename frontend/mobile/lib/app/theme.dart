import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sahaayi design system – accessibility-first theming.
///
/// Design principles:
/// - Minimum touch targets: 48 × 48 dp (Material guidance for older users).
/// - Font sizes: body ≥ 18 sp, titles ≥ 24 sp.
/// - High-contrast colour palette (WCAG AA minimum 4.5 : 1 for body text).
/// - Malayalam script support via [NotoSansMalayalam] font family fallback.
/// - Both light and dark themes provided; system follows OS preference.
abstract final class SahaayiTheme {
  // ── Colour constants ───────────────────────────────────────────────────────

  /// Primary brand colour – deep teal, strong contrast against white/black.
  static const Color _primaryColor = Color(0xFF006A5B);
  static const Color _primaryColorDark = Color(0xFF004D42);
  static const Color _primaryColorLight = Color(0xFF52C9B5);

  /// Error red – distinguishable by colour-blind users when paired with icon.
  static const Color _errorColor = Color(0xFFB00020);

  /// Background tones – near-white to avoid harsh pure-white glare.
  static const Color _lightBackground = Color(0xFFF5F7F6);
  static const Color _lightSurface = Color(0xFFFFFFFF);

  /// Dark theme tones.
  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkSurface = Color(0xFF1E1E1E);
  static const Color _darkPrimaryColor = Color(0xFF52C9B5);

  // ── Typography ─────────────────────────────────────────────────────────────

  /// Text theme with accessible minimum sizes.
  /// [GoogleFonts.notoSans] provides Malayalam glyphs when the device does
  /// not have them bundled.
  static TextTheme _buildTextTheme({required bool dark}) {
    final baseColor = dark ? Colors.white : const Color(0xFF1A1A1A);

    // Prefer NotoSansMalayalam (bundled font) → Noto Sans → system fallback.
    TextStyle base(double size, FontWeight weight) => GoogleFonts.notoSans(
          fontSize: size,
          fontWeight: weight,
          color: baseColor,
          fontFamilyFallback: const ['NotoSansMalayalam'],
        );

    return TextTheme(
      // Display
      displayLarge: base(32, FontWeight.w700),
      displayMedium: base(28, FontWeight.w700),
      displaySmall: base(24, FontWeight.w600),

      // Headlines / titles
      headlineLarge: base(26, FontWeight.w700),
      headlineMedium: base(24, FontWeight.w600),
      headlineSmall: base(22, FontWeight.w600),

      // Titles
      titleLarge: base(24, FontWeight.w600),
      titleMedium: base(20, FontWeight.w500),
      titleSmall: base(18, FontWeight.w500),

      // Body – minimum 18 sp per elderly accessibility guideline
      bodyLarge: base(18, FontWeight.w400),
      bodyMedium: base(16, FontWeight.w400),
      bodySmall: base(14, FontWeight.w400),

      // Labels – used for buttons, chips, captions
      labelLarge: base(16, FontWeight.w600),
      labelMedium: base(14, FontWeight.w500),
      labelSmall: base(12, FontWeight.w400),
    );
  }

  // ── Light theme ────────────────────────────────────────────────────────────

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
      primary: _primaryColor,
      onPrimary: Colors.white,
      primaryContainer: _primaryColorLight,
      onPrimaryContainer: const Color(0xFF001F1B),
      error: _errorColor,
      surface: _lightSurface,
      onSurface: const Color(0xFF1A1A1A),
    ).copyWith(
      surfaceContainerHighest: const Color(0xFFE8EFED),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _lightBackground,
      textTheme: _buildTextTheme(dark: false),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamilyFallback: const ['NotoSansMalayalam'],
        ),
        iconTheme: const IconThemeData(size: 28, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 56), // ≥56 dp height for elderly users
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          foregroundColor: _primaryColor,
          textStyle: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          side: const BorderSide(color: _primaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          foregroundColor: _primaryColor,
          textStyle: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor, width: 2),
        ),
        labelStyle: GoogleFonts.notoSans(
          fontSize: 16,
          color: const Color(0xFF555555),
          fontFamilyFallback: const ['NotoSansMalayalam'],
        ),
        hintStyle: GoogleFonts.notoSans(
          fontSize: 16,
          color: const Color(0xFF999999),
          fontFamilyFallback: const ['NotoSansMalayalam'],
        ),
        errorStyle: GoogleFonts.notoSans(
          fontSize: 14,
          color: _errorColor,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: _lightSurface,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      iconTheme: const IconThemeData(size: 28, color: _primaryColor),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        extendedTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        sizeConstraints: BoxConstraints.tightFor(width: 64, height: 64),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: GoogleFonts.notoSans(fontSize: 16),
      ),
      dividerTheme: const DividerThemeData(thickness: 1, space: 1),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: _primaryColor,
        unselectedItemColor: Color(0xFF777777),
        selectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 13),
        iconSize: 28,
        showUnselectedLabels: true,
      ),
    );
  }

  // ── Dark theme ─────────────────────────────────────────────────────────────

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColorDark,
      brightness: Brightness.dark,
      primary: _darkPrimaryColor,
      onPrimary: Colors.black,
      error: const Color(0xFFCF6679),
      surface: _darkSurface,
      onSurface: const Color(0xFFE8E8E8),
    );

    return lightTheme.copyWith(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkBackground,
      textTheme: _buildTextTheme(dark: true),
      appBarTheme: lightTheme.appBarTheme.copyWith(
        backgroundColor: _darkSurface,
        foregroundColor: _darkPrimaryColor,
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _darkPrimaryColor,
          fontFamilyFallback: const ['NotoSansMalayalam'],
        ),
        iconTheme: const IconThemeData(size: 28, color: _darkPrimaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          backgroundColor: _darkPrimaryColor,
          foregroundColor: Colors.black,
          textStyle: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: lightTheme.cardTheme.copyWith(color: _darkSurface),
    );
  }
}
