import 'package:flutter/material.dart';
import '../theme.dart';

/// A themed replacement for the default AlertDialog. The stock Material
/// dialog renders in plain white with the system font — visually jarring
/// against the app's warm glass/serif aesthetic. This wraps the same
/// AlertDialog API but applies Scholar's colors, fonts, and rounded shape.
Future<T?> showScholarDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required List<Widget> actions,
}) {
  return showDialog<T>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: ScholarColors.bgBase,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: ScholarColors.glassBorder),
      ),
      title: Text(
        title,
        style: ScholarStyles.serif(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      content: Text(
        content,
        style: ScholarStyles.sans(fontSize: 14, color: ScholarColors.textSecondary, height: 1.5),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actions: actions,
    ),
  );
}

/// A themed cancel/confirm text button pair for use inside showScholarDialog.
class ScholarDialogAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isDestructiveOrPrimary;

  const ScholarDialogAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.isDestructiveOrPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isDestructiveOrPrimary ? ScholarColors.accent : ScholarColors.textMuted,
      ),
      child: Text(
        label,
        style: ScholarStyles.sans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDestructiveOrPrimary ? ScholarColors.accent : ScholarColors.textMuted,
        ),
      ),
    );
  }
}
