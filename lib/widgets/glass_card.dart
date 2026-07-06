import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double? width;
  final double? height;
  final bool hasHover;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.width,
    this.height,
    this.hasHover = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: ScholarColors.glassBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: ScholarColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: ScholarColors.glassShadow,
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(40),
            child: child,
          ),
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
    return Container(
      decoration: BoxDecoration(
        color: ScholarColors.white25,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: ScholarColors.white30),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: child,
      ),
    );
  }
}
