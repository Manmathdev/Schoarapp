import 'package:flutter/material.dart';
import '../theme.dart';

/// Standard Material 3 surface card: flat, tonal elevation via
/// surfaceContainer color roles rather than shadows or blur — this
/// replaces the earlier glass-morphism treatment as part of the move to
/// Material 3 Expressive. Named GlassCard still for now to avoid renaming
/// every call site across the app; it is a plain M3 card underneath.
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
    this.borderRadius = ScholarTokens.shapeLG,
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
    final colors = context.colors;

    final card = Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Padding(
        padding: widget.padding ?? const EdgeInsets.all(24),
        child: widget.child,
      ),
    );

    if (widget.onTap == null) return card;

    // Subtle press-scale feedback plus Material's own state-layer ripple
    // — standard M3 interactive surface behavior.
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        onTap: widget.onTap,
        onHighlightChanged: _setPressed,
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

/// A smaller nested surface, one tonal step up from GlassCard, used for
/// pills/rows inside a card (e.g. daily task rows, habit rows).
class GlassCardSmall extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const GlassCardSmall({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = ScholarTokens.shapeMD,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: child,
      ),
    );
  }
}
