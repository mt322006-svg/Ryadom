import 'package:flutter/material.dart';

import '../l10n/l10n_ext.dart';
import '../theme/ryadom_palette.dart';

/// Branded launch while theme and stores initialize.
class RyadomStartupGate extends StatelessWidget {
  const RyadomStartupGate({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = RyadomPalette.night;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: palette.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.85,
                colors: [
                  palette.radarGlow.withValues(alpha: 0.22),
                  palette.background,
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        palette.accent.withValues(alpha: 0.35),
                        palette.accent.withValues(alpha: 0.08),
                      ],
                    ),
                    border: Border.all(
                      color: palette.accent.withValues(alpha: 0.45),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: palette.accent.withValues(alpha: 0.25),
                        blurRadius: 28,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.radar_rounded,
                    size: 44,
                    color: palette.accent,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  l10n.appTitle,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: palette.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.appTagline,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: palette.muted,
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: palette.accent.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}