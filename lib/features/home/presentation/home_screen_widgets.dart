part of 'home_screen.dart';

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final action = Text(
      actionLabel,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.end,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );

    return Row(
      children: [
        Expanded(child: Text(title, style: theme.textTheme.headlineSmall)),
        const SizedBox(width: 12),
        Flexible(
          child: onActionTap == null
              ? action
              : TextButton(
                  onPressed: onActionTap,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: action,
                ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow(
    this.request, {
    required this.onTap,
    this.distanceMeters,
  });

  final HelpRequest request;
  final VoidCallback onTap;
  final double? distanceMeters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final chipColor =
        urgencyColor(request.urgency, colors: RyadomColors.of(context));
    final distanceLabel = l10n.formatDistance(distanceMeters);
    final secondaryParts = <String>[
      request.timeLabel,
      if (distanceMeters != null) distanceLabel,
      if (request.hasCurrentUserResponded) l10n.youResponded,
    ];

    return RyadomSurfaceCard(
      margin: const EdgeInsets.only(bottom: RyadomTokens.itemGap),
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: chipColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.campaign_rounded, color: chipColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 17,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  request.areaLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  secondaryParts.join(' • '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _MetaChip(
            label: distanceMeters != null
                ? distanceLabel
                : request.hasCurrentUserResponded
                    ? l10n.responseChip
                    : l10n.urgencyLabel(request.urgency),
            color: chipColor,
          ),
        ],
      ),
    );
  }
}

class _RequestDetailsSheet extends StatelessWidget {
  const _RequestDetailsSheet({
    required this.request,
    required this.onRespond,
    this.onMarkComplete,
    this.onCancel,
    this.onRate,
    this.onReport,
    this.onBlock,
    this.distanceMeters,
    this.busy = false,
  });

  final HelpRequest request;
  final VoidCallback onRespond;
  final VoidCallback? onMarkComplete;
  final VoidCallback? onCancel;
  final void Function(int stars)? onRate;
  final VoidCallback? onReport;
  final VoidCallback? onBlock;
  final double? distanceMeters;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final chipColor =
        urgencyColor(request.urgency, colors: RyadomColors.of(context));

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 22,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: RyadomColors.of(context).border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        label: l10n.urgencyLabel(request.urgency),
                        color: chipColor,
                      ),
                      _MetaChip(
                        label: l10n.compensationLabel(request.compensation),
                        color: request.compensation == RequestCompensation.free
                            ? theme.colorScheme.primary
                            : RyadomColors.of(context).urgent,
                      ),
                      _MetaChip(
                        label:
                            l10n.responseCountChipLabel(request.responseCount),
                        color: RyadomColors.of(context).muted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(request.title, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 10),
                  Text(request.description, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  _SafetyNoteCard(
                    message: request.compensation == RequestCompensation.paid
                        ? l10n.safetyPaid
                        : l10n.safetyFree,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          request.areaLabel,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  if (distanceMeters != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.near_me_outlined, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.formatDistance(distanceMeters),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (request.latitude != null &&
                      request.longitude != null) ...[
                    const SizedBox(height: 14),
                    _MapPointCard(
                      latitude: request.latitude!,
                      longitude: request.longitude!,
                      enabled: !busy,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.schedule_outlined, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          request.timeLabel,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MetaChip(
                    label: l10n.statusLabel(request.status),
                    color: theme.colorScheme.primary,
                  ),
                  if (onRate != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.rateHelpTitle,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var stars = 1; stars <= 5; stars++)
                          IconButton(
                            tooltip: l10n.rateStarsTooltip(stars),
                            onPressed: busy ? null : () => onRate!(stars),
                            icon: Icon(
                              Icons.star_rounded,
                              size: 34,
                              color: Color.lerp(
                                const Color(0xFFD6CEC3),
                                const Color(0xFFE8B84A),
                                stars / 5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (onReport != null)
                        TextButton.icon(
                          onPressed: busy ? null : onReport,
                          icon: const Icon(Icons.flag_outlined, size: 18),
                          label: Text(l10n.report),
                        ),
                      if (onBlock != null)
                        TextButton.icon(
                          onPressed: busy ? null : onBlock,
                          icon: const Icon(Icons.block_outlined, size: 18),
                          label: Text(l10n.block),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RyadomSheetActions(
                    extra: onMarkComplete == null && onCancel == null
                        ? null
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (onMarkComplete != null) ...[
                                RyadomGlassButton(
                                  label: l10n.helpReceived,
                                  onPressed: busy ? null : onMarkComplete,
                                  variant: RyadomGlassVariant.ghost,
                                  expand: true,
                                ),
                                if (onCancel != null) const SizedBox(height: 10),
                              ],
                              if (onCancel != null)
                                RyadomGlassButton(
                                  label: l10n.cancelRequest,
                                  onPressed: busy ? null : onCancel,
                                  variant: RyadomGlassVariant.secondary,
                                  expand: true,
                                ),
                            ],
                          ),
                    primaryLabel: request.isOwnRequest ||
                            request.hasCurrentUserResponded
                        ? l10n.openChat
                        : l10n.respond,
                    onPrimary: busy ? null : onRespond,
                    secondaryLabel: l10n.later,
                    onSecondary:
                        busy ? null : () => Navigator.of(context).pop(),
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

class _MapPointCard extends StatelessWidget {
  const _MapPointCard({
    required this.latitude,
    required this.longitude,
    required this.enabled,
  });

  final double latitude;
  final double longitude;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final colors = RyadomColors.of(context);
    final coords = MapLinks.formatCoordinates(latitude, longitude);

    Future<void> openMap(MapApp app) async {
      final ok = await MapLinks.openInMaps(
        latitude: latitude,
        longitude: longitude,
        preferred: app,
      );
      if (!context.mounted) {
        return;
      }
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.mapOpenFailed)),
        );
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.inputSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.mapCoordsTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          InkWell(
            onTap: enabled
                ? () async {
                    await Clipboard.setData(ClipboardData(text: coords));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.mapCoordsCopied)),
                      );
                    }
                  }
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.my_location_rounded, size: 18, color: colors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      coords,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  Icon(Icons.copy_rounded, size: 18, color: colors.muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(l10n.mapCoordsHint, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              RyadomGlassButton.icon(
                onPressed: enabled ? () => openMap(MapApp.yandex) : null,
                icon: Icons.map_outlined,
                label: l10n.mapOpenYandex,
                compact: true,
              ),
              RyadomGlassButton.icon(
                onPressed: enabled ? () => openMap(MapApp.google) : null,
                icon: Icons.public_rounded,
                label: l10n.mapOpenGoogle,
                compact: true,
                variant: RyadomGlassVariant.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SafetyNoteCard extends StatelessWidget {
  const _SafetyNoteCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyActivityCard extends StatelessWidget {
  const _EmptyActivityCard({
    required this.filter,
    this.onCreateRequest,
    this.onChangeRadius,
  }) : forOwnRequests = false;

  const _EmptyActivityCard.myRequests({
    this.onCreateRequest,
  })  : filter = RadarFilter.requests,
        onChangeRadius = null,
        forOwnRequests = true;

  final RadarFilter filter;
  final bool forOwnRequests;
  final VoidCallback? onCreateRequest;
  final VoidCallback? onChangeRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final accent = theme.colorScheme.primary;
    final (icon, title, body) = forOwnRequests
        ? (
            Icons.campaign_outlined,
            l10n.emptyMyRequestsTitle,
            l10n.emptyMyRequestsBody,
          )
        : switch (filter) {
            RadarFilter.people => (
              Icons.people_outline_rounded,
              l10n.emptyPeopleTitle,
              l10n.emptyPeopleBody,
            ),
            RadarFilter.signals => (
              Icons.bolt_outlined,
              l10n.emptySignalsTitle,
              l10n.emptySignalsBody,
            ),
            RadarFilter.requests => (
              Icons.receipt_long_outlined,
              l10n.emptyFilterTitle,
              l10n.emptyFilterBody,
            ),
            RadarFilter.all => (
              Icons.radar_rounded,
              l10n.emptyQuietTitle,
              l10n.emptyQuietBody,
            ),
          };

    final isRussian = Localizations.localeOf(context).languageCode == 'ru';

    return RyadomSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(body, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          if (onCreateRequest != null || onChangeRadius != null) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (onChangeRadius != null)
                  TextButton.icon(
                    onPressed: onChangeRadius,
                    icon: const Icon(Icons.radar_rounded),
                    label: Text(isRussian ? 'Изменить радиус' : 'Change radius'),
                  ),
                if (onCreateRequest != null)
                  FilledButton.icon(
                    onPressed: onCreateRequest,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(isRussian ? 'Нужна помощь' : 'Ask for help'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RyadomSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(color: color),
          ),
          const SizedBox(height: 6),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _OwnRequestCard extends StatelessWidget {
  const _OwnRequestCard(
    this.request, {
    required this.onTap,
    required this.relayState,
    required this.actionLabel,
  });

  final HelpRequest request;
  final VoidCallback onTap;
  final RequestRelayState relayState;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return RyadomSurfaceCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                label: l10n.statusLabel(request.status),
                color: theme.colorScheme.primary,
              ),
              _MetaChip(
                label: l10n.responseCountChipLabel(request.responseCount),
                color: const Color(0xFF7B6A58),
              ),
              _MetaChip(
                label: l10n.relayStateLabel(relayState),
                color: relayState.color,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            request.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            request.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                actionLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
