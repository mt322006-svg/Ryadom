import 'package:flutter/material.dart';

import '../theme/ryadom_buttons.dart';
import '../theme/ryadom_tokens.dart';

/// Unified list/sheet surface — glass secondary + tap ripple.
class RyadomSurfaceCard extends StatelessWidget {
  const RyadomSurfaceCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(RyadomTokens.cardPadding),
    this.margin,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(RyadomTokens.radiusCard);

    Widget body = RyadomGlassSurface(
      variant: RyadomGlassVariant.secondary,
      borderRadius: radius,
      child: Padding(padding: padding, child: child),
    );

    if (onTap != null) {
      body = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: Colors.white.withValues(alpha: 0.08),
          child: body,
        ),
      );
    }

    if (margin != null) {
      return Padding(padding: margin!, child: body);
    }

    return body;
  }
}