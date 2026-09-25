import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../l10n/app_localizations.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../theme/ryadom_buttons.dart';
import '../../geo/domain/geo_privacy.dart';

Future<void> showHomeGeoSettingsSheet({
  required BuildContext context,
  required bool Function() isLoading,
  required bool Function() isEnabled,
  required Position? Function() currentPosition,
  required int Function() radiusMeters,
  required String Function(AppLocalizations l10n) detailsText,
  required String Function(AppLocalizations l10n) statusLabel,
  required String Function(AppLocalizations l10n) metaLabel,
  required Future<void> Function(VoidCallback onChanged) requestLocation,
  required void Function(VoidCallback onChanged) disableLocation,
  required Future<void> Function() openRadiusPicker,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final theme = Theme.of(context);
          final l10n = context.l10n;
          final mediaQuery = MediaQuery.of(context);
          final maxSheetHeight = mediaQuery.size.height * 0.88;
          final loading = isLoading();
          final enabled = isEnabled();
          final position = currentPosition();

          void refreshSheet() {
            if (context.mounted) {
              setModalState(() {});
            }
          }

          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxSheetHeight),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  4,
                  16,
                  20 + mediaQuery.viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.geoTitle, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(detailsText(l10n), style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        loading
                            ? Icons.location_searching_rounded
                            : enabled
                                ? Icons.my_location_rounded
                                : Icons.location_disabled_outlined,
                      ),
                      title: Text(statusLabel(l10n)),
                      subtitle: Text(metaLabel(l10n)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        RyadomGlassButton.icon(
                          onPressed: loading
                              ? null
                              : () => requestLocation(refreshSheet),
                          icon: loading
                              ? Icons.hourglass_top_rounded
                              : Icons.refresh_rounded,
                          label: loading
                              ? l10n.geoSearching
                              : enabled
                                  ? l10n.geoRefresh
                                  : l10n.geoEnable,
                          compact: true,
                        ),
                        RyadomGlassButton.icon(
                          onPressed: enabled && !loading
                              ? () => disableLocation(refreshSheet)
                              : null,
                          icon: Icons.location_off_rounded,
                          label: l10n.geoDisable,
                          variant: RyadomGlassVariant.secondary,
                          compact: true,
                        ),
                        RyadomGlassButton.icon(
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            openRadiusPicker();
                          },
                          icon: Icons.radar_rounded,
                          label: l10n.geoRadiusButton(
                            l10n.formatRadius(radiusMeters()),
                          ),
                          variant: RyadomGlassVariant.secondary,
                          compact: true,
                        ),
                      ],
                    ),
                    if (enabled && position != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        l10n.geoPublicZone(
                          GeoPrivacy.approximateAreaLabel(
                            position.latitude,
                            position.longitude,
                          ),
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<int?> showHomeRadiusPicker({
  required BuildContext context,
  required List<int> radiusOptions,
  required int selectedRadius,
}) {
  return showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final l10n = context.l10n;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.radiusPickerTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.radiusPickerHint,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              for (final radius in radiusOptions)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.formatRadius(radius)),
                  trailing: radius == selectedRadius
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.of(context).pop(radius),
                ),
            ],
          ),
        ),
      );
    },
  );
}
