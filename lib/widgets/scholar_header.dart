import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme_controller.dart';

/// Branding top bar built on Flutter's standard AppBar (Material 3) rather
/// than a hand-rolled container — this gets correct status-bar contrast,
/// scroll-elevation behavior, and semantics for free. Primary navigation
/// lives in the bottom NavigationBar (see AppShell), so this bar carries
/// just the brand title, centered, plus the light/dark toggle action.
class ScholarHeader extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;

  const ScholarHeader({super.key, required this.currentRoute});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Scholar'),
      centerTitle: true,
      actions: const [_ThemeToggleButton(), SizedBox(width: 4)],
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => RotationTransition(
              turns: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              key: ValueKey(isDark),
            ),
          ),
        );
      },
    );
  }
}
