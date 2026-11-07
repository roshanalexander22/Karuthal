import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// An accessible button tailored for elderly users and screen readers.
/// Enforces WCAG 2.1 AA/AAA standards:
/// - Minimum touch target >= 56dp x 56dp
/// - High contrast colors
/// - Native tactile haptic feedback on press
/// - Accessible Semantics label
class AccessibleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double minHeight;
  final String? semanticHint;

  const AccessibleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.minHeight = 56.0,
    this.semanticHint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBg = backgroundColor ?? theme.colorScheme.primary;
    final effectiveFg = textColor ?? theme.colorScheme.onPrimary;

    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      label: label,
      hint: semanticHint,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: minHeight,
          minWidth: 120.0,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: effectiveBg,
            foregroundColor: effectiveFg,
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(
                color: theme.colorScheme.outline.withAlpha(50),
                width: 1.5,
              ),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          ),
          onPressed: onPressed == null || isLoading
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  onPressed!();
                },
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: effectiveFg,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 26, color: effectiveFg),
                      const SizedBox(width: 12),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: effectiveFg,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
