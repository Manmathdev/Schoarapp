import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../theme.dart';

/// Glass-morphism card matching the website's `.glass` utility class, with
/// slightly boosted depth cues (stronger shadow, inner highlight) since the
/// subtle web version reads as flat on a small, brighter phone screen.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: ScholarColors.glassBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: ScholarColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                // A very faint vertical gradient inside the glass itself
                // gives the card a sense of catching light from above,
                // instead of reading as a single flat translucent block.
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.10),
                      Colors.white.withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.3],
                  ),
                ),
                padding: padding ?? const EdgeInsets.all(40),
                child: child,
              ),
            ),
            // Top shine line, matching the website's `.glass::before`.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Color(0x80FFFFFF),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        splashColor: ScholarColors.accentSoft,
        highlightColor: ScholarColors.accentSoft,
        child: card,
      ),
    );
  }
}

class GlassCardSmall extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const GlassCardSmall({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ScholarColors.white25,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: ScholarColors.white30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: child,
      ),
    );
  }
}
