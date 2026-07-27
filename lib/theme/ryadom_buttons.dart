import 'dart:ui';

import 'package:flutter/material.dart';

/// Shared button metrics and glass styling for «Мы Рядом».
abstract final class RyadomButtons {
  static const double height = 52;
  static const double heightCompact = 44;
  static const BorderRadius radius = BorderRadius.all(Radius.circular(16));
  static const double blurSigma = 14;

  static Widget label(String text, {TextAlign? align, Color? color}) {
    return Text(
      text,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.fade,
      textAlign: align,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.15,
        fontSize: 15,
        color: color,
      ),
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      ),
    );
  }
}

enum RyadomGlassVariant { primary, secondary, ghost }

/// Frosted-glass surface (blur + tint + highlight border).
class RyadomGlassSurface extends StatelessWidget {
  const RyadomGlassSurface({
    super.key,
    required this.child,
    this.variant = RyadomGlassVariant.secondary,
    this.borderRadius = RyadomButtons.radius,
    this.blur = true,
    this.accentOverride,
  });

  final Widget child;
  final RyadomGlassVariant variant;
  final BorderRadius borderRadius;
  final bool blur;
  final Color? accentOverride;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = accentOverride ?? theme.colorScheme.primary;
    final decoration = _glassDecoration(
      variant: variant,
      isDark: isDark,
      accent: accent,
    );

    Widget layer = DecoratedBox(decoration: decoration, child: child);

    if (blur) {
      layer = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: RyadomButtons.blurSigma,
          sigmaY: RyadomButtons.blurSigma,
        ),
        child: layer,
      );
    }

    return ClipRRect(borderRadius: borderRadius, child: layer);
  }

  static BoxDecoration _glassDecoration({
    required RyadomGlassVariant variant,
    required bool isDark,
    required Color accent,
  }) {
    final highlight = isDark
        ? Colors.white.withValues(alpha: 0.34)
        : Colors.white.withValues(alpha: 0.72);
    final shadow = isDark
        ? Colors.black.withValues(alpha: 0.28)
        : Colors.black.withValues(alpha: 0.10);

    switch (variant) {
      case RyadomGlassVariant.primary:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    accent.withValues(alpha: 0.42),
                    accent.withValues(alpha: 0.18),
                  ]
                : [
                    accent.withValues(alpha: 0.88),
                    accent.withValues(alpha: 0.62),
                  ],
          ),
          border: Border.all(
            color: highlight.withValues(alpha: isDark ? 0.45 : 0.55),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: isDark ? 0.22 : 0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(color: shadow, blurRadius: 10, offset: const Offset(0, 4)),
          ],
        );
      case RyadomGlassVariant.secondary:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.white.withValues(alpha: 0.14),
                    Colors.white.withValues(alpha: 0.04),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.62),
                    Colors.white.withValues(alpha: 0.28),
                  ],
          ),
          border: Border.all(
            color: highlight.withValues(alpha: isDark ? 0.22 : 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(color: shadow, blurRadius: 12, offset: const Offset(0, 4)),
          ],
        );
      case RyadomGlassVariant.ghost:
        return BoxDecoration(
          color: accent.withValues(alpha: isDark ? 0.10 : 0.08),
          border: Border.all(
            color: accent.withValues(alpha: isDark ? 0.28 : 0.22),
            width: 1,
          ),
        );
    }
  }
}

class RyadomGlassButton extends StatelessWidget {
  const RyadomGlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = RyadomGlassVariant.primary,
    this.compact = false,
    this.expand = false,
    this.icon,
  });

  const RyadomGlassButton.icon({
    super.key,
    required this.label,
    required this.onPressed,
    required this.icon,
    this.variant = RyadomGlassVariant.primary,
    this.compact = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final RyadomGlassVariant variant;
  final bool compact;
  final bool expand;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final h = compact ? RyadomButtons.heightCompact : RyadomButtons.height;
    final enabled = onPressed != null;

    final textColor = switch (variant) {
      RyadomGlassVariant.primary => isDark
          ? theme.colorScheme.onPrimary
          : Colors.white,
      RyadomGlassVariant.secondary => theme.colorScheme.onSurface,
      RyadomGlassVariant.ghost => theme.colorScheme.primary,
    };

    final content = icon == null
        ? RyadomButtons.label(label, color: enabled ? textColor : textColor.withValues(alpha: 0.45))
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: enabled ? textColor : textColor.withValues(alpha: 0.45)),
              const SizedBox(width: 8),
              Flexible(
                child: RyadomButtons.label(
                  label,
                  color: enabled ? textColor : textColor.withValues(alpha: 0.45),
                ),
              ),
            ],
          );

    final button = Opacity(
      opacity: enabled ? 1 : 0.55,
      child: RyadomGlassSurface(
        variant: variant,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: RyadomButtons.radius,
            splashColor: Colors.white.withValues(alpha: 0.12),
            highlightColor: Colors.white.withValues(alpha: 0.06),
            child: SizedBox(
              height: h,
              width: expand ? double.infinity : null,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class RyadomGlassIconButton extends StatelessWidget {
  const RyadomGlassIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = 44,
    this.tint,
    this.busy = false,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final double size;
  final Color? tint;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = tint ?? theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? theme.colorScheme.onPrimary : Colors.white;

    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: RyadomGlassSurface(
        variant: RyadomGlassVariant.primary,
        accentOverride: accent,
        borderRadius: BorderRadius.circular(size / 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: size,
              height: size,
              child: Center(
                child: busy
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: iconColor,
                        ),
                      )
                    : Icon(icon, color: iconColor, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Primary + secondary actions for sheets (full-width glass stack).
class RyadomSheetActions extends StatelessWidget {
  const RyadomSheetActions({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.extra,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (extra != null) ...[extra!, const SizedBox(height: 12)],
        RyadomGlassButton(
          label: primaryLabel,
          onPressed: onPrimary,
          expand: true,
        ),
        if (secondaryLabel != null && onSecondary != null) ...[
          const SizedBox(height: 10),
          RyadomGlassButton(
            label: secondaryLabel!,
            onPressed: onSecondary,
            variant: RyadomGlassVariant.secondary,
            expand: true,
          ),
        ],
      ],
    );
  }
}

/// Segmented filter control with glass chips.
class RyadomSegmentChip extends StatelessWidget {
  const RyadomSegmentChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RyadomGlassSurface(
      variant: selected
          ? RyadomGlassVariant.primary
          : RyadomGlassVariant.secondary,
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      blur: !selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          child: SizedBox(
            height: RyadomButtons.heightCompact,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected
                        ? (theme.brightness == Brightness.dark
                              ? theme.colorScheme.onPrimary
                              : Colors.white)
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}