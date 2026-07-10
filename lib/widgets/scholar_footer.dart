import 'package:flutter/material.dart';

class ScholarFooter extends StatelessWidget {
  const ScholarFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year.toString();
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Center(
        child: Text(
          '\u00a9 $year Scholar. All Rights Reserved. Created by Manmath.',
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
