import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../theme.dart';

/// Branding top bar. Primary navigation between sections now lives in the
/// native bottom tab bar (see AppShell), so this header keeps only the
/// Scholar wordmark — matching the site's visual identity without
/// duplicating navigation controls on a small screen.
class ScholarHeader extends StatelessWidget {
  final String currentRoute;

  const ScholarHeader({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ScholarColors.glassBg,
        border: Border(
          bottom: BorderSide(color: ScholarColors.glassBorder),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Center(
              child: Text(
                'Scholar',
                style: ScholarStyles.serif(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.02,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
