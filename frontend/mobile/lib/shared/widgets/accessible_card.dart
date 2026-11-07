import 'package:flutter/material.dart';

/// An accessible card container with strong border definition, high-contrast surface,
/// large padding, and optional tap action with haptics.
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final double elevation;

  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(20.0),
    this.elevation = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardContent = Card(
      elevation: elevation,
      color: backgroundColor ?? theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: theme.colorScheme.outline.withAlpha(80),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (semanticLabel != null) {
      return Semantics(
        label: semanticLabel,
        button: onTap != null,
        child: cardContent,
      );
    }
    return cardContent;
  }
}
