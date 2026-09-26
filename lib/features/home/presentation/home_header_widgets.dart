import 'package:flutter/material.dart';

import '../../../l10n/l10n_ext.dart';
import '../../../l10n/ryadom_l10n_helpers.dart';
import '../../../theme/ryadom_buttons.dart';
class HomeRadarHeader extends StatelessWidget {
  const HomeRadarHeader({
    super.key,
    required this.onOpenGeoSettings,
    required this.onPickRadius,
    required this.isLocationEnabled,
    required this.isLocationLoading,
    required this.locationLabel,
    required this.radiusLabel,
  });

  final VoidCallback onOpenGeoSettings;
  final VoidCallback onPickRadius;
  final bool isLocationEnabled;
  final bool isLocationLoading;
  final String locationLabel;
  final String radiusLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.radar_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.appTagline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            HomeHeaderPill(
              icon: isLocationLoading
                  ? Icons.location_searching_rounded
                  : isLocationEnabled
                  ? Icons.my_location_rounded
                  : Icons.location_disabled_outlined,
              label: l10n.compactHeaderLabel(
                locationLabel,
                fallback: l10n.headerGeo,
              ),
              onTap: onOpenGeoSettings,
            ),
            HomeHeaderPill(
              icon: Icons.tune_rounded,
              label: radiusLabel,
              onTap: onPickRadius,
            ),
          ],
        ),
      ],
    );
  }
}

class HomeHeaderPill extends StatelessWidget {
  const HomeHeaderPill({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 170),
      child: RyadomGlassSurface(
        variant: RyadomGlassVariant.secondary,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
        blur: false,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
