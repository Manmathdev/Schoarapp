import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../theme.dart';

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
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
                  child: Text(
                    'Scholar',
                    style: ScholarStyles.serif(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.02,
                    ),
                  ),
                ),
                const Spacer(),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _navItem(context, 'Dashboard', '/', currentRoute == '/'),
                      const SizedBox(width: 40),
                      _navItem(context, 'Curriculum', '/curriculum', currentRoute == '/curriculum'),
                      const SizedBox(width: 40),
                      _navItem(context, 'Planner', '/planner', currentRoute == '/planner'),
                      const SizedBox(width: 40),
                      _navItem(context, 'Resources', '/resources', currentRoute == '/resources'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, String label, String route, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (route != currentRoute) {
          Navigator.pushNamed(context, route);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: ScholarStyles.sans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 2.5,
              color: isActive ? ScholarColors.textPrimary : ScholarColors.textSecondary,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 1.5,
              width: label.length * 8.0,
              color: ScholarColors.accent,
            ),
        ],
      ),
    );
  }
}
