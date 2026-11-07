import 'package:flutter/material.dart';
import '../../app/theme.dart';

/// An accessible card container with strong border definition, high-contrast surface,
/// large padding, and optional tap action with haptics.
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final BorderSide? border;

  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(20.0),
    this.elevation = 1.0,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = border ??
        const BorderSide(
          color: SahaayiColors.border,
          width: 1.2,
        );

    final cardContent = Card(
      elevation: elevation,
      color: backgroundColor ?? SahaayiColors.card,
      shadowColor: const Color(0x10000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: effectiveBorder,
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
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
