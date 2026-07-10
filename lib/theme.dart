import 'package:flutter/material.dart';

/// Scholar's Material 3 seed color — a growth/study-themed green, from
/// which the entire tonal palette (light and dark) is algorithmically
/// derived via ColorScheme.fromSeed. This is the actual "Material You"
/// mechanism: one seed color generates a full harmonized palette rather
/// than hand-picked individual colors.
const Color scholarSeedColor = Color(0xFF2E7D5B);

/// Subject tag colors are a fixed, deliberately distinct set (so Physics
/// vs Chemistry vs Math are always visually distinguishable) rather than
/// derived from the seed — M3 seed derivation is for the *system* surfaces
/// and primary/secondary/tertiary roles, not for arbitrary category tags.
@immutable
class ScholarSubjectColors extends ThemeExtension<ScholarSubjectColors> {
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

  const ScholarSubjectColors({
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

  static const light = ScholarSubjectColors(
    physics: Color(0xFF1565C0),
    chemistry: Color(0xFF2E7D32),
    mathematics: Color(0xFFC2185B),
    english: Color(0xFF00796B),
    it: Color(0xFF7B1FA2),
    sanskrit: Color(0xFFEF6C00),
    general: Color(0xFF6D6A64),
    statusNotStarted: Color(0xFF6D6A64),
    statusInProgress: Color(0xFF2E7D5B),
    statusRevision: Color(0xFFB3261E),
    statusMastered: Color(0xFF2E7D32),
    dayBorderColors: [
      Color(0xFF1565C0),
      Color(0xFF2E7D32),
      Color(0xFFC2185B),
      Color(0xFFEF6C00),
      Color(0xFF7B1FA2),
      Color(0xFF00796B),
      Color(0xFF2E7D5B),
    ],
  );

  static const dark = ScholarSubjectColors(
    physics: Color(0xFF9ECAFF),
    chemistry: Color(0xFF8DD79A),
    mathematics: Color(0xFFF3A9C6),
    english: Color(0xFF80CBC4),
    it: Color(0xFFD4A6E0),
    sanskrit: Color(0xFFFFB870),
    general: Color(0xFFC9C5BD),
    statusNotStarted: Color(0xFFC9C5BD),
    statusInProgress: Color(0xFF9BD9AE),
    statusRevision: Color(0xFFFFB4AB),
    statusMastered: Color(0xFF8DD79A),
    dayBorderColors: [
      Color(0xFF9ECAFF),
      Color(0xFF8DD79A),
      Color(0xFFF3A9C6),
      Color(0xFFFFB870),
      Color(0xFFD4A6E0),
      Color(0xFF80CBC4),
      Color(0xFF9BD9AE),
    ],
  );

  @override
  ScholarSubjectColors copyWith() => this;

  @override
  ScholarSubjectColors lerp(ThemeExtension<ScholarSubjectColors>? other, double t) {
    if (other is! ScholarSubjectColors) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return ScholarSubjectColors(
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
      dayBorderColors: List.generate(dayBorderColors.length, (i) => c(dayBorderColors[i], other.dayBorderColors[i])),
    );
  }
}

/// Convenience accessors so widgets can write `context.colors.primary`
/// and `context.subjectColors.physics` instead of the more verbose
/// Theme.of(context) calls.
extension ScholarThemeX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  ScholarSubjectColors get subjectColors => Theme.of(this).extension<ScholarSubjectColors>()!;
}

/// Design tokens for spacing, touch targets, motion, and Material 3's
/// shape scale (extra-small through extra-large corner radii).
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

  // Minimum interactive touch target (Material 48dp / HIG 44pt).
  static const double minTouchTarget = 48;

  // Motion — M3 standard easing and durations.
  static const Duration motionFast = Duration(milliseconds: 150);
  static const Duration motionMedium = Duration(milliseconds: 220);
  static const Duration motionSlow = Duration(milliseconds: 320);
  static const Curve motionCurve = Curves.easeOutCubic;
  static const Curve motionEmphasized = Cubic(0.2, 0.0, 0, 1.0);

  // M3 shape scale (corner radii).
  static const double shapeXS = 4;
  static const double shapeSM = 8;
  static const double shapeMD = 12;
  static const double shapeLG = 16;
  static const double shapeXL = 28;
  static const double shapeFull = 999;
}

class ScholarTheme {
  ScholarTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: scholarSeedColor,
      brightness: brightness,
    );
    final subjectColors = brightness == Brightness.dark ? ScholarSubjectColors.dark : ScholarSubjectColors.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      fontFamily: 'RobotoFlex',
      extensions: [subjectColors],
      textTheme: _textTheme(colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 3,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.secondaryContainer,
        surfaceTintColor: Colors.transparent,
        height: ScholarTokens.minTouchTarget + 18,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ScholarTokens.shapeLG)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, ScholarTokens.minTouchTarget),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ScholarTokens.shapeFull)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, ScholarTokens.minTouchTarget),
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ScholarTokens.shapeFull)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, ScholarTokens.minTouchTarget),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ScholarTokens.shapeFull)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        selectedColor: colorScheme.secondaryContainer,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        secondaryLabelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ScholarTokens.shapeFull)),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(ScholarTokens.shapeSM), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(ScholarTokens.shapeSM), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(ScholarTokens.shapeSM), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ScholarTokens.shapeXL)),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant, space: 1),
    );
  }

  /// Material 3's type scale: display, headline, title, body, label — each
  /// with small/medium/large variants, all in Roboto Flex.
  static TextTheme _textTheme(ColorScheme colorScheme) {
    final base = TextTheme(
      displayLarge: const TextStyle(fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25, height: 1.12),
      displayMedium: const TextStyle(fontSize: 45, fontWeight: FontWeight.w400, height: 1.16),
      displaySmall: const TextStyle(fontSize: 36, fontWeight: FontWeight.w400, height: 1.22),
      headlineLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, height: 1.25),
      headlineMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, height: 1.29),
      headlineSmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1.33),
      titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.27),
      titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15, height: 1.5),
      titleSmall: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1, height: 1.43),
      bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5, height: 1.5),
      bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25, height: 1.43),
      bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4, height: 1.33),
      labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1, height: 1.43),
      labelMedium: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5, height: 1.33),
      labelSmall: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5, height: 1.45),
    ).apply(
      fontFamily: 'RobotoFlex',
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
    return base;
  }
}
