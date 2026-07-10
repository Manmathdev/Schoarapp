import 'package:flutter/material.dart';

/// A thin wrapper around the standard AlertDialog. With Material 3's
/// dialogTheme configured globally (see theme.dart), the default
/// AlertDialog already renders with Scholar's seed-derived colors, shape,
/// and typography — no manual restyling needed here anymore.
Future<T?> showScholarDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required List<Widget> actions,
}) {
  return showDialog<T>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actions: actions,
    ),
  );
}

/// A cancel/confirm text button pair for use inside showScholarDialog.
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
    final colors = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isDestructiveOrPrimary ? colors.primary : colors.onSurfaceVariant,
      ),
      child: Text(label),
    );
  }
}
