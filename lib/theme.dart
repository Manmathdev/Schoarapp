import 'package:flutter/material.dart';

class ScholarColors {
  ScholarColors._();

  static const Color bgBase = Color(0xFFe8e2d9);
  static const Color glassBg = Color(0x8FFFFFFF);
  static const Color glassBorder = Color(0x99FFFFFF);
  static const Color glassBorderHover = Color(0xD9FFFFFF);
  static const Color glassShadow = Color(0x0F000000);
  static const Color glassShadowHover = Color(0x1A000000);
  static const Color textPrimary = Color(0xFF1c1917);
  static const Color textSecondary = Color(0xFF574F49);
  static const Color textMuted = Color(0xFF6B6259);
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

/// Design tokens enforcing common platform standards:
/// - Spacing on a 4pt grid (Material spacing system)
/// - Minimum touch targets of 48x48dp (Material) / 44x44pt (HIG) — we use
///   the stricter 48dp everywhere so both platforms are comfortably covered
/// - A consistent elevation/shadow scale instead of one-off shadow values
/// - Shared motion durations/curves instead of arbitrary per-widget numbers
class ScholarTokens {
  ScholarTokens._();

  // 4pt spacing scale
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;
  static const double space12 = 48;

  // Minimum interactive touch target (Material 48dp / HIG 44pt — using the
  // larger of the two so both platforms are satisfied).
  static const double minTouchTarget = 48;

  // Motion
  static const Duration motionFast = Duration(milliseconds: 150);
  static const Duration motionMedium = Duration(milliseconds: 220);
  static const Duration motionSlow = Duration(milliseconds: 320);
  static const Curve motionCurve = Curves.easeOutCubic;

  // Elevation shadow presets (Material-style: ambient + key light layering)
  static List<BoxShadow> elevation1 = [
    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1)),
    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 2, offset: const Offset(0, 1)),
  ];
  static List<BoxShadow> elevation2 = [
    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1)),
  ];
  static List<BoxShadow> elevation3 = [
    BoxShadow(color: Colors.black.withOpacity(0.09), blurRadius: 28, offset: const Offset(0, 10)),
    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
  ];
}

/// Font families are bundled directly as assets (see pubspec.yaml) rather
/// than fetched over the network via google_fonts. This guarantees the
/// correct typeface renders every time, even offline or on first launch —
/// the earlier network-dependent approach silently fell back to the system
/// font (Roboto) when the device had no connectivity at first load.
class ScholarStyles {
  ScholarStyles._();

  static const String _serifFamily = 'PlayfairDisplay';
  static const String _sansFamily = 'Montserrat';

  static TextStyle serif({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    double? letterSpacing,
    double? height,
    Color color = ScholarColors.textPrimary,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return TextStyle(
      fontFamily: _serifFamily,
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
    return TextStyle(
      fontFamily: _sansFamily,
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
    return ThemeData(
      scaffoldBackgroundColor: ScholarColors.bgBase,
      colorScheme: ColorScheme.light(
        primary: ScholarColors.accent,
        secondary: ScholarColors.accent,
        surface: ScholarColors.glassBg,
      ),
      fontFamily: 'Montserrat',
      textTheme: TextTheme(
        displayLarge: ScholarStyles.serif(
          fontSize: 72,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.03,
          height: 1.1,
        ),
        displayMedium: ScholarStyles.serif(
          fontSize: 56,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.03,
          height: 1.1,
        ),
        headlineLarge: ScholarStyles.serif(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.01,
        ),
        headlineMedium: ScholarStyles.serif(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.01,
        ),
        titleLarge: ScholarStyles.serif(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.01,
        ),
        titleMedium: ScholarStyles.serif(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: ScholarStyles.sans(
          fontSize: 16,
          fontWeight: FontWeight.w300,
          color: ScholarColors.textSecondary,
        ),
        bodyMedium: ScholarStyles.sans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: ScholarStyles.sans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 2.5,
          color: ScholarColors.textSecondary,
        ),
        labelSmall: ScholarStyles.sans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 4,
          color: ScholarColors.accent,
        ),
      ),
    );
  }
}
