import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'accessible_button.dart';

/// An accessible confirmation dialog designed specifically for elderly users.
/// Requires explicit confirmation for sensitive actions (e.g., smart autofill, deleting personal documents).
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'ശരി, തുടരുക (Confirm)',
    this.cancelLabel = 'വേണ്ട, റദ്ദാക്കുക (Cancel)',
    required this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'ശരി, തുടരുക (Confirm)',
    String cancelLabel = 'വേണ്ട, റദ്ദാക്കുക (Cancel)',
    bool isDestructive = false,
  }) {
    HapticFeedback.heavyImpact();
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
        side: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      actionsPadding: const EdgeInsets.all(20),
      title: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 19, height: 1.4),
      ),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AccessibleButton(
              label: confirmLabel,
              backgroundColor: isDestructive
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
              textColor: isDestructive
                  ? theme.colorScheme.onError
                  : theme.colorScheme.onPrimary,
              onPressed: onConfirm,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                side: BorderSide(color: theme.colorScheme.outline, width: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: onCancel ?? () => Navigator.of(context).pop(),
              child: Text(
                cancelLabel,
                style:
                    TextStyle(fontSize: 18, color: theme.colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
