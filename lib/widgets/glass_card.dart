import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../theme.dart';

/// Glass-morphism card matching the website's `.glass` utility class, with
/// slightly boosted depth cues (stronger shadow, inner highlight) since the
/// subtle web version reads as flat on a small, brighter phone screen.
/// Colors resolve from the current theme (light or dark) via context, so
/// this card automatically adapts when the user switches modes.
class GlassCard extends StatefulWidget {
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
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: palette.glassBg,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: palette.glassBorder),
        boxShadow: ScholarTokens.elevation3(palette.shadowColor, isDark: isDark),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                // A very faint vertical gradient inside the glass itself
                // gives the card a sense of catching light from above,
                // instead of reading as a single flat translucent block.
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(isDark ? 0.05 : 0.10),
                      Colors.white.withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.3],
                  ),
                ),
                padding: widget.padding ?? const EdgeInsets.all(40),
                child: widget.child,
              ),
            ),
            // Top shine line, matching the website's `.glass::before`.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      palette.glassShine,
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

    if (widget.onTap == null) return card;

    // Subtle press-scale feedback — a standard native interaction cue
    // (matches the depress behavior of iOS buttons and Material's own
    // state-layer conventions) so tappable cards feel responsive rather
    // than static.
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        onTap: widget.onTap,
        onHighlightChanged: _setPressed,
        splashColor: palette.accentSoft,
        highlightColor: palette.accentSoft,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1.0,
          duration: ScholarTokens.motionFast,
          curve: ScholarTokens.motionCurve,
          child: card,
        ),
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
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: palette.surfaceOverlay25,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: palette.surfaceOverlay30),
        boxShadow: ScholarTokens.elevation1(palette.shadowColor, isDark: isDark),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: child,
      ),
    );
  }
}
