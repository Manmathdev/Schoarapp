import 'package:flutter/material.dart';
import '../theme.dart';

class ScholarFooter extends StatelessWidget {
  const ScholarFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year.toString();
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04)),
        ),
      ),
      child: Center(
        child: Text(
          '\u00a9 $year Scholar. All Rights Reserved. Created by Manmath.',
          style: ScholarStyles.sans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.5,
            color: palette.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
