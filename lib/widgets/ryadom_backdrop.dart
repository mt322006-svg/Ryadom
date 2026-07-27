import 'package:flutter/material.dart';

import '../theme/ryadom_palette.dart';

/// Soft ambient depth behind screens (radar glow + vignette).
class RyadomBackdrop extends StatelessWidget {
  const RyadomBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = RyadomColors.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.55),
              radius: 1.15,
              colors: [
                colors.radarGlow.withValues(alpha: 0.10),
                colors.palette.background,
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.palette.background.withValues(alpha: 0),
                colors.palette.background.withValues(alpha: 0.92),
              ],
              stops: const [0.72, 1],
            ),
          ),
        ),
        child,
      ],
    );
  }
}