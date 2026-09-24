part of 'chat_screen.dart';

class _MessengerAppBarTitle extends StatelessWidget {
  const _MessengerAppBarTitle({
    required this.name,
    required this.subtitle,
    required this.statusLabel,
    required this.deliveryState,
    required this.palette,
  });

  final String name;
  final String subtitle;
  final String statusLabel;
  final _ChatDeliveryState deliveryState;
  final _ChatPaletteData palette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _initialsFor(name);
    final isOnline = deliveryState != _ChatDeliveryState.error &&
        deliveryState != _ChatDeliveryState.sending;

    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: palette.accent.withValues(alpha: 0.2),
              child: Text(
                initials,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: palette.accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isOnline
                      ? const Color(0xFF4CD964)
                      : palette.muted,
                  shape: BoxShape.circle,
                  border: Border.all(color: palette.background, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: palette.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$subtitle · $statusLabel',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RequestContextBar extends StatelessWidget {
  const _RequestContextBar({
    required this.session,
    required this.palette,
    required this.l10n,
  });

  final HelpChatSession session;
  final _ChatPaletteData palette;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surface.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.campaign_outlined, size: 18, color: palette.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  session.request.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: palette.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.shield_outlined, size: 14, color: palette.muted),
              const SizedBox(width: 4),
              Text(
                l10n.chatNoPrepay,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: palette.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatWallpaper extends StatelessWidget {
  const _ChatWallpaper({required this.palette});

  final _ChatPaletteData palette;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.background,
            Color.lerp(palette.background, palette.surface, 0.35)!,
          ],
        ),
      ),
      child: CustomPaint(
        painter: _ChatDotsPainter(
          dotColor: palette.border.withValues(alpha: 0.35),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ChatDotsPainter extends CustomPainter {
  _ChatDotsPainter({required this.dotColor});

  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;
    const step = 28.0;
    for (var y = 0.0; y < size.height; y += step) {
      for (var x = 0.0; x < size.width; x += step) {
        canvas.drawCircle(Offset(x + 6, y + 6), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ChatDotsPainter oldDelegate) {
    return oldDelegate.dotColor != dotColor;
  }
}

class _ChatDaySeparator extends StatelessWidget {
  const _ChatDaySeparator({required this.label, required this.palette});

  final String label;
  final _ChatPaletteData palette;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: palette.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              color: palette.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatEmptyState extends StatelessWidget {
  const _ChatEmptyState({required this.palette, required this.l10n});

  final _ChatPaletteData palette;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: palette.surface,
                shape: BoxShape.circle,
                border: Border.all(color: palette.border),
              ),
              child: Icon(
                Icons.forum_outlined,
                size: 34,
                color: palette.accent,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.chatStartMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: palette.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.chatStartHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.muted,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessengerBubbleRow extends StatelessWidget {
  const _MessengerBubbleRow({
    required this.message,
    required this.palette,
    required this.maxWidth,
    required this.showAuthor,
    required this.isTail,
    required this.deliveryStatus,
  });

  final ChatMessage message;
  final _ChatPaletteData palette;
  final double maxWidth;
  final bool showAuthor;
  final bool isTail;
  final _MessageDeliveryStatus deliveryStatus;

  @override
  Widget build(BuildContext context) {
    final isOutgoing = message.isCurrentUser;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment:
          isOutgoing ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isOutgoing) ...[
          SizedBox(
            width: 36,
            child: isTail
                ? CircleAvatar(
                    radius: 16,
                    backgroundColor: palette.accent.withValues(alpha: 0.18),
                    child: Text(
                      _initialsFor(message.authorName),
                      style: TextStyle(
                        color: palette.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: _MessengerBubble(
            message: message,
            palette: palette,
            maxWidth: maxWidth,
            showAuthor: showAuthor,
            isTail: isTail,
            deliveryStatus: deliveryStatus,
          ),
        ),
        if (isOutgoing) const SizedBox(width: 4),
      ],
    );
  }
}

class _MessengerBubble extends StatelessWidget {
  const _MessengerBubble({
    required this.message,
    required this.palette,
    required this.maxWidth,
    required this.showAuthor,
    required this.isTail,
    required this.deliveryStatus,
  });

  final ChatMessage message;
  final _ChatPaletteData palette;
  final double maxWidth;
  final bool showAuthor;
  final bool isTail;
  final _MessageDeliveryStatus deliveryStatus;

  @override
  Widget build(BuildContext context) {
    final isOutgoing = message.isCurrentUser;
    final bubbleColor = isOutgoing ? palette.accent : palette.surface;
    final textColor = isOutgoing ? palette.onAccent : palette.onSurface;
    final metaColor = isOutgoing
        ? palette.onAccent.withValues(alpha: 0.78)
        : palette.muted;
    final location = SharedLocationPayload.tryParse(message.text);
    const corner = 18.0;
    const groupedCorner = 12.0;
    const tailCorner = 5.0;

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isOutgoing ? corner : groupedCorner),
              topRight: Radius.circular(isOutgoing ? groupedCorner : corner),
              bottomLeft: Radius.circular(
                isOutgoing
                    ? (isTail ? tailCorner : groupedCorner)
                    : (isTail ? tailCorner : groupedCorner),
              ),
              bottomRight: Radius.circular(
                isOutgoing
                    ? (isTail ? tailCorner : groupedCorner)
                    : (isTail ? tailCorner : groupedCorner),
              ),
            ),
            border: isOutgoing
                ? null
                : Border.all(color: palette.border.withValues(alpha: 0.9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isOutgoing ? 0.1 : 0.06),
                blurRadius: isTail ? 10 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, showAuthor ? 8 : 7, 10, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showAuthor) ...[
                  Text(
                    message.authorName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: palette.accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                ],
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    if (location == null)
                      Text(
                        message.text,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: textColor,
                          height: 1.32,
                          fontSize: 16,
                        ),
                      )
                    else
                      _SharedLocationCard(
                        location: location,
                        isOutgoing: isOutgoing,
                        palette: palette,
                        textColor: textColor,
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.timeLabel,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: metaColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isOutgoing) ...[
                          const SizedBox(width: 3),
                          _DeliveryTicks(
                            status: deliveryStatus,
                            color: metaColor,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SharedLocationCard extends StatelessWidget {
  const _SharedLocationCard({
    required this.location,
    required this.isOutgoing,
    required this.palette,
    required this.textColor,
  });

  final SharedLocationPayload location;
  final bool isOutgoing;
  final _ChatPaletteData palette;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final copy = _LocationCopy.of(context);
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: textColor, size: 22),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isOutgoing ? copy.locationSent : copy.locationReceived,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${location.latitude.toStringAsFixed(5)}, '
            '${location.longitude.toStringAsFixed(5)}',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.86),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: textColor,
                side: BorderSide(color: textColor.withValues(alpha: 0.45)),
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () async {
                final opened = await MapLinks.openInMaps(
                  latitude: location.latitude,
                  longitude: location.longitude,
                  preferred: MapApp.system,
                );
                if (!opened && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(copy.mapOpenFailed)),
                  );
                }
              },
              icon: const Icon(Icons.map_outlined, size: 18),
              label: Text(copy.openMap),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryTicks extends StatelessWidget {
  const _DeliveryTicks({required this.status, required this.color});

  final _MessageDeliveryStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      _MessageDeliveryStatus.sending => Icon(
          Icons.schedule_rounded,
          size: 14,
          color: color,
        ),
      _MessageDeliveryStatus.failed => Icon(
          Icons.error_outline_rounded,
          size: 14,
          color: color,
        ),
      _MessageDeliveryStatus.delivered => Icon(
          Icons.done_all_rounded,
          size: 15,
          color: color,
        ),
      _ => Icon(Icons.done_rounded, size: 14, color: color),
    };
  }
}

class _MessengerComposer extends StatelessWidget {
  const _MessengerComposer({
    required this.palette,
    required this.theme,
    required this.l10n,
    required this.controller,
    required this.quickReplies,
    required this.hasHiddenQuickReplies,
    required this.showAllQuickReplies,
    required this.onToggleQuickReplies,
    required this.onQuickReply,
    required this.canSend,
    required this.isSending,
    required this.waitingForPeer,
    required this.onSend,
    required this.showLocationAction,
    required this.canShareLocation,
    required this.isSharingLocation,
    required this.onShareLocation,
  });

  final _ChatPaletteData palette;
  final ThemeData theme;
  final AppLocalizations l10n;
  final TextEditingController controller;
  final List<String> quickReplies;
  final bool hasHiddenQuickReplies;
  final bool showAllQuickReplies;
  final VoidCallback onToggleQuickReplies;
  final ValueChanged<String> onQuickReply;
  final bool canSend;
  final bool isSending;
  final bool waitingForPeer;
  final VoidCallback onSend;
  final bool showLocationAction;
  final bool canShareLocation;
  final bool isSharingLocation;
  final VoidCallback onShareLocation;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final locationCopy = _LocationCopy.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.inputSurface.withValues(alpha: 0.98),
        border: Border(top: BorderSide(color: palette.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (quickReplies.isNotEmpty)
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final reply in quickReplies)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _QuickReplyChip(
                            label: reply,
                            palette: palette,
                            onTap: () => onQuickReply(reply),
                          ),
                        ),
                      if (hasHiddenQuickReplies)
                        _QuickReplyChip(
                          label:
                              showAllQuickReplies ? l10n.chatLess : l10n.chatMore,
                          palette: palette,
                          muted: true,
                          onTap: onToggleQuickReplies,
                        ),
                    ],
                  ),
                ),
              if (quickReplies.isNotEmpty) const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (showLocationAction)
                    IconButton(
                      onPressed: canShareLocation ? onShareLocation : null,
                      icon: isSharingLocation
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              Icons.location_on_outlined,
                              color: canShareLocation
                                  ? palette.accent
                                  : palette.muted,
                            ),
                      tooltip: canShareLocation
                          ? locationCopy.shareAction
                          : locationCopy.locationUnavailable,
                    )
                  else
                    IconButton(
                      onPressed: null,
                      icon: Icon(Icons.add_rounded, color: palette.muted),
                      tooltip: l10n.chatSoon,
                    ),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: palette.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: palette.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 2,
                        ),
                        child: TextField(
                          controller: controller,
                          minLines: 1,
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.send,
                          onSubmitted: canSend ? (_) => onSend() : null,
                          decoration: InputDecoration(
                            hintText: waitingForPeer
                                ? l10n.chatWaitingPeer
                                : l10n.chatMessageHint,
                            border: InputBorder.none,
                            isCollapsed: true,
                            hintStyle: theme.textTheme.bodyLarge?.copyWith(
                              color: palette.muted,
                            ),
                          ),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: palette.onSurface,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _SendButton(
                    palette: palette,
                    active: canSend,
                    busy: isSending && !isSharingLocation,
                    onPressed: canSend ? onSend : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickReplyChip extends StatelessWidget {
  const _QuickReplyChip({
    required this.label,
    required this.palette,
    required this.onTap,
    this.muted = false,
  });

  final String label;
  final _ChatPaletteData palette;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: muted ? palette.surface : palette.quickAction,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: muted ? palette.border : palette.quickAction,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: muted ? palette.onSurface : palette.quickActionText,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.palette,
    required this.active,
    required this.busy,
    required this.onPressed,
  });

  final _ChatPaletteData palette;
  final bool active;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = active ? palette.accent : palette.border;

    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Center(
            child: busy
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: palette.onAccent,
                    ),
                  )
                : Icon(
                    active ? Icons.send_rounded : Icons.mic_none_rounded,
                    color: active ? palette.onAccent : palette.muted,
                    size: 22,
                  ),
          ),
        ),
      ),
    );
  }
}

class _PaletteRow extends StatelessWidget {
  const _PaletteRow({
    required this.palette,
    required this.selected,
    required this.data,
    required this.l10n,
    required this.onTap,
  });

  final ChatPalette palette;
  final bool selected;
  final _ChatPaletteData data;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: data.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? data.accent : data.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _paletteTitle(palette, l10n),
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: data.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _paletteDescription(palette, l10n),
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: data.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ColorDot(data.accent),
                    const SizedBox(width: 6),
                    _ColorDot(data.surface),
                    const SizedBox(width: 6),
                    _ColorDot(data.quickAction),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
    );
  }
}

class _LocationCopy {
  const _LocationCopy({
    required this.shareAction,
    required this.locationUnavailable,
    required this.warningTitle,
    required this.warningBody,
    required this.cancel,
    required this.share,
    required this.locationSent,
    required this.locationReceived,
    required this.openMap,
    required this.mapOpenFailed,
    required this.locationServicesOff,
    required this.locationPermissionDenied,
    required this.locationCaptureFailed,
  });

  final String shareAction;
  final String locationUnavailable;
  final String warningTitle;
  final String warningBody;
  final String cancel;
  final String share;
  final String locationSent;
  final String locationReceived;
  final String openMap;
  final String mapOpenFailed;
  final String locationServicesOff;
  final String locationPermissionDenied;
  final String locationCaptureFailed;

  factory _LocationCopy.of(BuildContext context) {
    final isRussian = Localizations.localeOf(context).languageCode == 'ru';
    if (isRussian) {
      return const _LocationCopy(
        shareAction: 'Поделиться точным местоположением',
        locationUnavailable: 'Сначала выберите помощника',
        warningTitle: 'Передать точное местоположение?',
        warningBody:
            'Передавайте точное местоположение только тому, кому доверяете. Не уверены — не отправляйте.',
        cancel: 'Отмена',
        share: 'Поделиться',
        locationSent: 'Точное местоположение отправлено',
        locationReceived: 'Точное местоположение',
        openMap: 'Открыть на карте',
        mapOpenFailed: 'Не удалось открыть карты',
        locationServicesOff: 'Включите геолокацию, чтобы передать точную точку.',
        locationPermissionDenied:
            'Нет доступа к геолокации. Точная точка не отправлена.',
        locationCaptureFailed:
            'Не удалось определить точное местоположение. Попробуйте ещё раз.',
      );
    }
    return const _LocationCopy(
      shareAction: 'Share exact location',
      locationUnavailable: 'Choose a helper first',
      warningTitle: 'Share your exact location?',
      warningBody:
          'Only share your exact location with someone you trust. If you are unsure, do not send it.',
      cancel: 'Cancel',
      share: 'Share',
      locationSent: 'Exact location sent',
      locationReceived: 'Exact location',
      openMap: 'Open in maps',
      mapOpenFailed: 'Could not open maps',
      locationServicesOff: 'Turn on location services to share your exact point.',
      locationPermissionDenied:
          'Location access was not granted. The exact point was not sent.',
      locationCaptureFailed:
          'Could not determine your exact location. Please try again.',
    );
  }
}

class _ChatPaletteData {
  const _ChatPaletteData({
    required this.background,
    required this.surface,
    required this.inputSurface,
    required this.tagSurface,
    required this.accent,
    required this.onAccent,
    required this.onSurface,
    required this.muted,
    required this.border,
    required this.quickAction,
    required this.quickActionText,
  });

  final Color background;
  final Color surface;
  final Color inputSurface;
  final Color tagSurface;
  final Color accent;
  final Color onAccent;
  final Color onSurface;
  final Color muted;
  final Color border;
  final Color quickAction;
  final Color quickActionText;
}

_ChatPaletteData _chatPaletteFromRyadom(RyadomPalette palette) {
  return _ChatPaletteData(
    background: palette.background,
    surface: palette.surface,
    inputSurface: palette.inputSurface,
    tagSurface: palette.tagSurface,
    accent: palette.accent,
    onAccent: palette.onAccent,
    onSurface: palette.onSurface,
    muted: palette.muted,
    border: palette.border,
    quickAction: palette.tagSurface,
    quickActionText: palette.secondary,
  );
}

_ChatPaletteData _paletteData(ChatPalette palette, Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  return switch (palette) {
    ChatPalette.calm => _chatPaletteFromRyadom(
        brightness == Brightness.dark
            ? RyadomPalette.classic
            : RyadomPalette.day,
      ),
    ChatPalette.night => _chatPaletteFromRyadom(RyadomPalette.night),
    ChatPalette.warm => _ChatPaletteData(
        background: isDark ? const Color(0xFF19100D) : const Color(0xFFF9F0E7),
        surface: isDark ? const Color(0xFF2A1D18) : const Color(0xFFFFFBF6),
        inputSurface:
            isDark ? const Color(0xFF32231D) : const Color(0xFFFFF5EB),
        tagSurface: isDark ? const Color(0xFF3A2920) : const Color(0xFFF7E7D6),
        accent: isDark ? const Color(0xFFFFB07D) : const Color(0xFFC97C5D),
        onAccent: isDark ? const Color(0xFF382012) : Colors.white,
        onSurface: isDark ? const Color(0xFFF8EBE2) : const Color(0xFF382219),
        muted: isDark ? const Color(0xFFD0B7AA) : const Color(0xFF886A5D),
        border: isDark ? const Color(0xFF4A342A) : const Color(0xFFE9D4C6),
        quickAction:
            isDark ? const Color(0xFF4B3427) : const Color(0xFFF7E3D8),
        quickActionText: isDark
            ? const Color(0xFFFFD8C0)
            : const Color(0xFF8D5239),
      ),
    ChatPalette.cyberpunk => _chatPaletteFromRyadom(RyadomPalette.cyberpunk),
  };
}

String _paletteTitle(ChatPalette palette, AppLocalizations l10n) {
  return switch (palette) {
    ChatPalette.calm => l10n.chatPaletteCalmTitle,
    ChatPalette.night => l10n.chatPaletteNightTitle,
    ChatPalette.warm => l10n.chatPaletteWarmTitle,
    ChatPalette.cyberpunk => l10n.chatPaletteCyberpunkTitle,
  };
}

String _paletteDescription(ChatPalette palette, AppLocalizations l10n) {
  return switch (palette) {
    ChatPalette.calm => l10n.chatPaletteCalm,
    ChatPalette.night => l10n.chatPaletteNight,
    ChatPalette.warm => l10n.chatPaletteWarm,
    ChatPalette.cyberpunk => l10n.chatPaletteCyberpunk,
  };
}

List<String> _quickReplies(HelpChatSession session, AppLocalizations l10n) {
  if (session.request.isOwnRequest) {
    return [
      l10n.chatQuickReplyHelper1,
      l10n.chatQuickReplyHelper2,
      l10n.chatQuickReplyHelper3,
      l10n.chatQuickReplyHelper4,
    ];
  }

  return [
    l10n.chatQuickReplyResponder1,
    l10n.chatQuickReplyResponder2,
    l10n.chatQuickReplyResponder3,
    l10n.chatQuickReplyResponder4,
  ];
}

String _initialsFor(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) {
    return '?';
  }
  String head(String value, int count) {
    if (value.length <= count) {
      return value;
    }
    return value.substring(0, count);
  }

  if (parts.length == 1) {
    return head(parts.first, 2).toUpperCase();
  }
  return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
}
