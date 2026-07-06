import 'package:flutter/material.dart';
import '../theme.dart';

class ScholarFooter extends StatelessWidget {
  const ScholarFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year.toString();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.04)),
        ),
      ),
      child: Center(
        child: Text(
          '\u00a9 $year Scholar. All Rights Reserved. Created by Manmath.',
          style: ScholarStyles.sans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.5,
            color: ScholarColors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
