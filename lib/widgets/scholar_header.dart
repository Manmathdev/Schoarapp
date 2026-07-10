import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../theme_controller.dart';

/// Branding top bar. Primary navigation between sections lives in the
/// native bottom tab bar (see AppShell), so this header keeps the Scholar
/// wordmark centered plus a light/dark mode toggle — matching the site's
/// visual identity without duplicating navigation controls on a small
/// screen.
class ScholarHeader extends StatelessWidget {
  final String currentRoute;

  const ScholarHeader({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: palette.glassBg,
        border: Border(
          bottom: BorderSide(color: palette.glassBorder),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SizedBox(
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'Scholar',
                    style: ScholarStyles.serif(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.02,
                      color: palette.textPrimary,
                    ),
                  ),
                  const Positioned(right: 4, child: _ThemeToggleButton()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = context.palette;
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return IconButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            themeController.toggle();
          },
          tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
          icon: AnimatedSwitcher(
            duration: ScholarTokens.motionMedium,
            transitionBuilder: (child, animation) => RotationTransition(
              turns: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              key: ValueKey(isDark),
              size: 20,
              color: palette.accent,
            ),
          ),
        );
      },
    );
  }
}
