import 'package:flutter/material.dart';

/// A custom ThemeExtension carrying Scholar's palette. Using Flutter's own
/// ThemeExtension mechanism (rather than static color constants) means
/// colors are resolved at runtime through Theme.of(context), which is what
/// actually makes light/dark mode possible — a widget tree that reads
/// hardcoded static constants can never respond to a theme change.
@immutable
class ScholarPalette extends ThemeExtension<ScholarPalette> {
  final Color bgBase;
  final Color glassBg;
  final Color glassBorder;
  final Color glassShine;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color accentSoft;
  final Color surfaceOverlay25;
  final Color surfaceOverlay30;
  final Color surfaceOverlay40;
  final Color shadowColor;

  final Color physics;
  final Color chemistry;
  final Color mathematics;
  final Color english;
  final Color it;
  final Color sanskrit;
  final Color general;

  final Color statusNotStarted;
  final Color statusInProgress;
  final Color statusRevision;
  final Color statusMastered;

  final List<Color> dayBorderColors;

  const ScholarPalette({
    required this.bgBase,
    required this.glassBg,
    required this.glassBorder,
    required this.glassShine,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentSoft,
    required this.surfaceOverlay25,
    required this.surfaceOverlay30,
    required this.surfaceOverlay40,
    required this.shadowColor,
    required this.physics,
    required this.chemistry,
    required this.mathematics,
    required this.english,
    required this.it,
    required this.sanskrit,
    required this.general,
    required this.statusNotStarted,
    required this.statusInProgress,
    required this.statusRevision,
    required this.statusMastered,
    required this.dayBorderColors,
  });

  /// Warm cream palette, matching the original website exactly.
  static const light = ScholarPalette(
    bgBase: Color(0xFFE8E2D9),
    glassBg: Color(0x8FFFFFFF),
    glassBorder: Color(0x99FFFFFF),
    glassShine: Color(0x80FFFFFF),
    textPrimary: Color(0xFF1C1917),
    textSecondary: Color(0xFF574F49),
    textMuted: Color(0xFF6B6259),
    accent: Color(0xFFB3916E),
    accentSoft: Color(0x1AB3916E),
    surfaceOverlay25: Color(0x40FFFFFF),
    surfaceOverlay30: Color(0x4DFFFFFF),
    surfaceOverlay40: Color(0x66FFFFFF),
    shadowColor: Color(0xFF000000),
    physics: Color(0xFF1565C0),
    chemistry: Color(0xFF2E7D32),
    mathematics: Color(0xFFC2185B),
    english: Color(0xFF00796B),
    it: Color(0xFF7B1FA2),
    sanskrit: Color(0xFFFF8F00),
    general: Color(0xFF9C9490),
    statusNotStarted: Color(0xFF9C9490),
    statusInProgress: Color(0xFFB3916E),
    statusRevision: Color(0xFFE65100),
    statusMastered: Color(0xFF2E7D32),
    dayBorderColors: [
      Color(0xFF1565C0),
      Color(0xFF2E7D32),
      Color(0xFFC2185B),
      Color(0xFFE65100),
      Color(0xFF7B1FA2),
      Color(0xFF00796B),
      Color(0xFFB3916E),
    ],
  );

  /// Dark variant: a warm charcoal (not pure black, which crushes the
  /// glassmorphism effect and reads harshly) with the same accent hue
  /// brightened slightly for sufficient contrast on a dark surface, and
  /// subject colors lifted in luminance so they stay legible.
  static const dark = ScholarPalette(
    bgBase: Color(0xFF1A1714),
    glassBg: Color(0x33FFFFFF),
    glassBorder: Color(0x26FFFFFF),
    glassShine: Color(0x1AFFFFFF),
    textPrimary: Color(0xFFF2EEE9),
    textSecondary: Color(0xFFC9C2B9),
    textMuted: Color(0xFF9C948A),
    accent: Color(0xFFD8B48D),
    accentSoft: Color(0x26D8B48D),
    surfaceOverlay25: Color(0x1FFFFFFF),
    surfaceOverlay30: Color(0x26FFFFFF),
    surfaceOverlay40: Color(0x33FFFFFF),
    shadowColor: Color(0xFF000000),
    physics: Color(0xFF64B5F6),
    chemistry: Color(0xFF81C784),
    mathematics: Color(0xFFF06292),
    english: Color(0xFF4DB6AC),
    it: Color(0xFFBA68C8),
    sanskrit: Color(0xFFFFB74D),
    general: Color(0xFFAFA79D),
    statusNotStarted: Color(0xFFAFA79D),
    statusInProgress: Color(0xFFD8B48D),
    statusRevision: Color(0xFFFF8A65),
    statusMastered: Color(0xFF81C784),
    dayBorderColors: [
      Color(0xFF64B5F6),
      Color(0xFF81C784),
      Color(0xFFF06292),
      Color(0xFFFF8A65),
      Color(0xFFBA68C8),
      Color(0xFF4DB6AC),
      Color(0xFFD8B48D),
    ],
  );

  @override
  ScholarPalette copyWith() => this;

  @override
  ScholarPalette lerp(ThemeExtension<ScholarPalette>? other, double t) {
    if (other is! ScholarPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return ScholarPalette(
      bgBase: c(bgBase, other.bgBase),
      glassBg: c(glassBg, other.glassBg),
      glassBorder: c(glassBorder, other.glassBorder),
      glassShine: c(glassShine, other.glassShine),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textMuted: c(textMuted, other.textMuted),
      accent: c(accent, other.accent),
      accentSoft: c(accentSoft, other.accentSoft),
      surfaceOverlay25: c(surfaceOverlay25, other.surfaceOverlay25),
      surfaceOverlay30: c(surfaceOverlay30, other.surfaceOverlay30),
      surfaceOverlay40: c(surfaceOverlay40, other.surfaceOverlay40),
      shadowColor: c(shadowColor, other.shadowColor),
      physics: c(physics, other.physics),
      chemistry: c(chemistry, other.chemistry),
      mathematics: c(mathematics, other.mathematics),
      english: c(english, other.english),
      it: c(it, other.it),
      sanskrit: c(sanskrit, other.sanskrit),
      general: c(general, other.general),
      statusNotStarted: c(statusNotStarted, other.statusNotStarted),
      statusInProgress: c(statusInProgress, other.statusInProgress),
      statusRevision: c(statusRevision, other.statusRevision),
      statusMastered: c(statusMastered, other.statusMastered),
      dayBorderColors: List.generate(
        dayBorderColors.length,
        (i) => c(dayBorderColors[i], other.dayBorderColors[i]),
      ),
    );
  }
}

/// Convenience accessor so widgets can write `context.palette.accent`
/// instead of the more verbose Theme.of(context).extension<...>() call.
extension ScholarPaletteX on BuildContext {
  ScholarPalette get palette => Theme.of(this).extension<ScholarPalette>()!;
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

  // Elevation shadow presets, parameterized by the theme's own shadow color
  // so dark mode can use a pure-black shadow while light mode does too but
  // at different opacities suited to each surface brightness.
  static List<BoxShadow> elevation1(Color shadowColor, {bool isDark = false}) => [
        BoxShadow(color: shadowColor.withOpacity(isDark ? 0.24 : 0.04), blurRadius: 4, offset: const Offset(0, 1)),
        BoxShadow(color: shadowColor.withOpacity(isDark ? 0.18 : 0.03), blurRadius: 2, offset: const Offset(0, 1)),
      ];
  static List<BoxShadow> elevation2(Color shadowColor, {bool isDark = false}) => [
        BoxShadow(color: shadowColor.withOpacity(isDark ? 0.32 : 0.06), blurRadius: 12, offset: const Offset(0, 4)),
        BoxShadow(color: shadowColor.withOpacity(isDark ? 0.22 : 0.04), blurRadius: 4, offset: const Offset(0, 1)),
      ];
  static List<BoxShadow> elevation3(Color shadowColor, {bool isDark = false}) => [
        BoxShadow(color: shadowColor.withOpacity(isDark ? 0.40 : 0.09), blurRadius: 28, offset: const Offset(0, 10)),
        BoxShadow(color: shadowColor.withOpacity(isDark ? 0.26 : 0.04), blurRadius: 6, offset: const Offset(0, 2)),
      ];
}

/// Font families are bundled directly as assets (see pubspec.yaml) rather
/// than fetched over the network via google_fonts. This guarantees the
/// correct typeface renders every time, even offline or on first launch —
/// a network-dependent approach would silently fall back to the system
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
    required Color color,
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
    required Color color,
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

  static ThemeData get light => _build(ScholarPalette.light, Brightness.light);
  static ThemeData get dark => _build(ScholarPalette.dark, Brightness.dark);

  static ThemeData _build(ScholarPalette palette, Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: palette.bgBase,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: palette.accent,
        onPrimary: brightness == Brightness.dark ? Colors.black : Colors.white,
        secondary: palette.accent,
        onSecondary: brightness == Brightness.dark ? Colors.black : Colors.white,
        surface: palette.bgBase,
        onSurface: palette.textPrimary,
        error: palette.statusRevision,
        onError: Colors.white,
      ),
      fontFamily: 'Montserrat',
      extensions: [palette],
      textTheme: TextTheme(
        displayLarge: ScholarStyles.serif(fontSize: 72, fontWeight: FontWeight.w500, letterSpacing: -0.03, height: 1.1, color: palette.textPrimary),
        displayMedium: ScholarStyles.serif(fontSize: 56, fontWeight: FontWeight.w500, letterSpacing: -0.03, height: 1.1, color: palette.textPrimary),
        headlineLarge: ScholarStyles.serif(fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.01, color: palette.textPrimary),
        headlineMedium: ScholarStyles.serif(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.01, color: palette.textPrimary),
        titleLarge: ScholarStyles.serif(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.01, color: palette.textPrimary),
        titleMedium: ScholarStyles.serif(fontSize: 20, fontWeight: FontWeight.w600, color: palette.textPrimary),
        bodyLarge: ScholarStyles.sans(fontSize: 16, fontWeight: FontWeight.w300, color: palette.textSecondary),
        bodyMedium: ScholarStyles.sans(fontSize: 14, fontWeight: FontWeight.w400, color: palette.textPrimary),
        bodySmall: ScholarStyles.sans(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 2.5, color: palette.textSecondary),
        labelSmall: ScholarStyles.sans(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 4, color: palette.accent),
      ),
    );
  }
}
