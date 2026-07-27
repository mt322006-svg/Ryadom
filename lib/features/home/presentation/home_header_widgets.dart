import 'package:flutter/material.dart';

import '../../../l10n/l10n_ext.dart';
import '../../../l10n/ryadom_l10n_helpers.dart';
import '../../../theme/ryadom_buttons.dart';
import '../../nostr/data/we_ryadom_nostr_gateway.dart';
import 'home_models.dart';

class HomeRadarHeader extends StatelessWidget {
  const HomeRadarHeader({
    super.key,
    required this.onCreateRequest,
    required this.onOpenSettings,
    required this.onOpenNostrSettings,
    required this.onOpenGeoSettings,
    required this.onPickRadius,
    required this.isNostrLoading,
    required this.nostrStatus,
    required this.isLocationEnabled,
    required this.isLocationLoading,
    required this.locationLabel,
    required this.radiusLabel,
  });

  final VoidCallback onCreateRequest;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenNostrSettings;
  final VoidCallback onOpenGeoSettings;
  final VoidCallback onPickRadius;
  final bool isNostrLoading;
  final NostrConnectionStatus nostrStatus;
  final bool isLocationEnabled;
  final bool isLocationLoading;
  final String locationLabel;
  final String radiusLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final nostrLabel = l10n.nostrConnectionStatus(nostrStatus);

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
            IconButton(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings_outlined),
              tooltip: l10n.tooltipSettings,
            ),
            IconButton(
              onPressed: onCreateRequest,
              icon: const Icon(Icons.campaign_rounded),
              tooltip: l10n.tooltipNeedHelp,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            HomeHeaderPill(
              icon: isNostrLoading
                  ? Icons.sync_rounded
                  : nostrStatus == NostrConnectionStatus.online
                  ? Icons.wifi_tethering_rounded
                  : Icons.portable_wifi_off_rounded,
              label: l10n.compactHeaderLabel(
                nostrLabel,
                fallback: l10n.headerConnection,
              ),
              onTap: onOpenNostrSettings,
            ),
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

class RadarFilterBar extends StatelessWidget {
  const RadarFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onSelected,
  });

  final RadarFilter selectedFilter;
  final ValueChanged<RadarFilter> onSelected;

  /// Only filters that currently have content (people/signals are not live yet).
  static const visibleFilters = [RadarFilter.all, RadarFilter.requests];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        for (var i = 0; i < visibleFilters.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: RyadomSegmentChip(
              label: l10n.radarFilterLabel(visibleFilters[i]),
              selected: visibleFilters[i] == selectedFilter,
              onTap: () => onSelected(visibleFilters[i]),
            ),
          ),
        ],
      ],
    );
  }
}

