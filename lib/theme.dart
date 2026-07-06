import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScholarColors {
  ScholarColors._();

  static const Color bgBase = Color(0xFFe8e2d9);
  static const Color glassBg = Color(0x26FFFFFF);
  static const Color glassBorder = Color(0x99FFFFFF);
  static const Color glassBorderHover = Color(0xD9FFFFFF);
  static const Color glassShadow = Color(0x0F000000);
  static const Color glassShadowHover = Color(0x1A000000);
  static const Color textPrimary = Color(0xFF1c1917);
  static const Color textSecondary = Color(0xFF6b6460);
  static const Color textMuted = Color(0xFF9c9490);
  static const Color accent = Color(0xFFb3916e);
  static const Color accentSoft = Color(0x1Ab3916e);
  static const Color white25 = Color(0x40FFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color white40 = Color(0x66FFFFFF);
  static const Color white50 = Color(0x80FFFFFF);

  static const Color physics = Color(0xFF1565c0);
  static const Color chemistry = Color(0xFF2e7d32);
  static const Color mathematics = Color(0xFFc2185b);
  static const Color english = Color(0xFF00796b);
  static const Color it = Color(0xFF7b1fa2);
  static const Color sanskrit = Color(0xFFff8f00);
  static const Color general = Color(0xFF9c9490);

  static const Color statusNotStarted = Color(0xFF9c9490);
  static const Color statusInProgress = Color(0xFFb3916e);
  static const Color statusRevision = Color(0xFFe65100);
  static const Color statusMastered = Color(0xFF2e7d32);

  static const List<Color> dayBorderColors = [
    Color(0xFF1565c0),
    Color(0xFF2e7d32),
    Color(0xFFc2185b),
    Color(0xFFe65100),
    Color(0xFF7b1fa2),
    Color(0xFF00796b),
    Color(0xFFb3916e),
  ];
}

class ScholarStyles {
  ScholarStyles._();

  static TextStyle serif({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    double? letterSpacing,
    double? height,
    Color color = ScholarColors.textPrimary,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
      fontStyle: fontStyle,
    );
  }

  static TextStyle sans({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    double? letterSpacing,
    double? height,
    Color color = ScholarColors.textPrimary,
    FontStyle fontStyle = FontStyle.normal,
    TextDecoration decoration = TextDecoration.none,
  }) {
    return GoogleFonts.montserrat(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }
}

class ScholarTheme {
  ScholarTheme._();

  static ThemeData get theme {
    final baseTextTheme = ThemeData.light().textTheme;
    return ThemeData(
      scaffoldBackgroundColor: ScholarColors.bgBase,
      colorScheme: ColorScheme.light(
        primary: ScholarColors.accent,
        secondary: ScholarColors.accent,
        surface: ScholarColors.glassBg,
      ),
      fontFamily: GoogleFonts.montserrat().fontFamily,
      textTheme: GoogleFonts.playfairDisplayTextTheme(baseTextTheme).copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 72,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.03,
          height: 1.1,
          color: ScholarColors.textPrimary,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 56,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.03,
          height: 1.1,
          color: ScholarColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.01,
          color: ScholarColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.01,
          color: ScholarColors.textPrimary,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.01,
          color: ScholarColors.textPrimary,
        ),
        titleMedium: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ScholarColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w300,
          color: ScholarColors.textSecondary,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: ScholarColors.textPrimary,
        ),
        bodySmall: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 2.5,
          color: ScholarColors.textSecondary,
        ),
        labelSmall: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 4,
          color: ScholarColors.accent,
        ),
      ),
    );
  }
}
