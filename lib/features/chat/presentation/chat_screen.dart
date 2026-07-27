import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../l10n/app_localizations.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../l10n/ryadom_l10n_helpers.dart';
import '../../../theme/ryadom_palette.dart';
import '../../geo/domain/map_links.dart';
import '../../nostr/data/we_ryadom_nostr_gateway.dart';
import '../../nostr/domain/we_ryadom_nostr.dart';
import '../../trust/data/report_store.dart';
import '../../trust/domain/trust_guard.dart';
import '../domain/chat_models.dart';
import '../domain/shared_location_payload.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.session,
    required this.nostrGateway,
    required this.currentPubkey,
    this.initialChatPalette,
    this.onParticipantBlocked,
  });

  final HelpChatSession session;
  final WeRyadomNostrGateway nostrGateway;
  final String? currentPubkey;
  final ChatPalette? initialChatPalette;
  final Future<void> Function()? onParticipantBlocked;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  late ChatPalette _palette;
  StreamSubscription? _chatSubscription;
  bool _sending = false;
  bool _sharingLocation = false;
  bool _showAllQuickReplies = false;
  bool _hasDraft = false;
  _ChatDeliveryState _deliveryState = _ChatDeliveryState.online;

  @override
  void initState() {
    super.initState();
    _palette = widget.initialChatPalette ?? ChatPalette.night;
    _messages.addAll(widget.session.messages);
    _chatSubscription = widget.nostrGateway.events.listen(_handleRelayEvent);
    _messageController.addListener(_onDraftChanged);
    _loadSavedPalette();
    _scheduleScrollToEnd();
  }

  Future<void> _loadSavedPalette() async {
    final saved = await ChatPaletteStore.load();
    if (!mounted || saved == null) {
      return;
    }
    setState(() => _palette = saved);
  }

  void _onDraftChanged() {
    final hasDraft = _messageController.text.trim().isNotEmpty;
    if (!mounted || hasDraft == _hasDraft) {
      return;
    }
    setState(() => _hasDraft = hasDraft);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onDraftChanged);
    _chatSubscription?.cancel();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scheduleScrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = _paletteData(_palette, theme.brightness);
    final participantReady = widget.session.participantPubkey != null;
    final canSend = participantReady && !_sending && _hasDraft;
    final request = widget.session.request;
    final canShareExactLocation =
        request.isOwnRequest && participantReady && !_sending;
    final quickReplies = _visibleQuickReplies(l10n);

    return Theme(
      data: theme.copyWith(
        scaffoldBackgroundColor: palette.background,
        appBarTheme: theme.appBarTheme.copyWith(
          backgroundColor: palette.background,
          foregroundColor: palette.onSurface,
          elevation: 0,
          scrolledUnderElevation: 0.5,
        ),
      ),
      child: Scaffold(
        backgroundColor: palette.background,
        appBar: AppBar(
          titleSpacing: 12,
          title: _ChatTitle(
            name: widget.session.participant.name,
            subtitle: widget.session.participant.subtitle,
            deliveryLabel: _deliveryLabel(l10n),
            palette: palette,
          ),
          actions: [
            PopupMenuButton<String>(
              tooltip: l10n.chatMenuTooltip,
              onSelected: (value) {
                switch (value) {
                  case 'palette':
                    _pickPalette();
                  case 'report':
                    _handleSafetyAction(_ChatSafetyAction.report);
                  case 'block':
                    _handleSafetyAction(_ChatSafetyAction.block);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'palette',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.palette_outlined),
                    title: Text(l10n.chatThemeTitle),
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'report',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.flag_outlined),
                    title: Text(l10n.report),
                  ),
                ),
                PopupMenuItem(
                  value: 'block',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.block_outlined),
                    title: Text(l10n.block),
                  ),
                ),
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: _RequestContextBar(
              session: widget.session,
              palette: palette,
              l10n: l10n,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: DecoratedBox(
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
                child: _messages.isEmpty
                    ? _ChatEmptyState(palette: palette, l10n: l10n)
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final messageIndex = _messages.length - 1 - index;
                          final message = _messages[messageIndex];
                          final previous = messageIndex > 0
                              ? _messages[messageIndex - 1]
                              : null;
                          final next = messageIndex < _messages.length - 1
                              ? _messages[messageIndex + 1]
                              : null;
                          final groupedWithPrevious = previous != null &&
                              previous.isCurrentUser == message.isCurrentUser &&
                              (message.isCurrentUser ||
                                  previous.authorName == message.authorName);
                          final groupedWithNext = next != null &&
                              next.isCurrentUser == message.isCurrentUser &&
                              (message.isCurrentUser ||
                                  next.authorName == message.authorName);

                          return Padding(
                            padding: EdgeInsets.only(
                              top: groupedWithPrevious ? 2 : 8,
                              bottom: groupedWithNext ? 2 : 6,
                            ),
                            child: _MessageRow(
                              message: message,
                              palette: palette,
                              showAuthor:
                                  !message.isCurrentUser && !groupedWithPrevious,
                              showAvatar:
                                  !message.isCurrentUser && !groupedWithNext,
                              deliveryStatus:
                                  _deliveryStatusForMessage(messageIndex),
                            ),
                          );
                        },
                      ),
              ),
            ),
            _ChatComposer(
              palette: palette,
              l10n: l10n,
              controller: _messageController,
              quickReplies: quickReplies,
              hasHiddenQuickReplies: _hasHiddenQuickReplies(l10n),
              showAllQuickReplies: _showAllQuickReplies,
              onToggleQuickReplies: () {
                setState(() => _showAllQuickReplies = !_showAllQuickReplies);
              },
              onQuickReply: _sendMessage,
              canSend: canSend,
              isSending: _sending,
              waitingForPeer: !participantReady,
              onSend: () => _sendMessage(_messageController.text),
              showLocationAction: request.isOwnRequest,
              canShareLocation: canShareExactLocation,
              isSharingLocation: _sharingLocation,
              onShareLocation: _shareExactLocation,
            ),
          ],
        ),
      ),
    );
  }

  String _deliveryLabel(AppLocalizations l10n) {
    return switch (_deliveryState) {
      _ChatDeliveryState.online => l10n.chatDeliveryOnline,
      _ChatDeliveryState.sending => l10n.chatDeliverySending,
      _ChatDeliveryState.delivered => l10n.chatDeliveryDelivered,
      _ChatDeliveryState.error => l10n.chatDeliveryError,
    };
  }

  int? _lastOutgoingMessageIndex() {
    for (var i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].isCurrentUser) {
        return i;
      }
    }
    return null;
  }

  _MessageDeliveryStatus _deliveryStatusForMessage(int messageIndex) {
    if (!_messages[messageIndex].isCurrentUser) {
      return _MessageDeliveryStatus.none;
    }
    if (messageIndex != _lastOutgoingMessageIndex()) {
      return _MessageDeliveryStatus.sent;
    }
    if (_sending) {
      return _MessageDeliveryStatus.sending;
    }
    if (_deliveryState == _ChatDeliveryState.error) {
      return _MessageDeliveryStatus.failed;
    }
    if (_deliveryState == _ChatDeliveryState.delivered) {
      return _MessageDeliveryStatus.delivered;
    }
    return _MessageDeliveryStatus.sent;
  }

  Future<void> _sendMessage(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty) {
      return;
    }
    await _publishOutgoingMessage(text, clearDraft: true);
  }

  Future<void> _shareExactLocation() async {
    if (!widget.session.request.isOwnRequest ||
        widget.session.participantPubkey == null ||
        _sending) {
      return;
    }

    final copy = _LocationCopy.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.location_on_outlined),
          title: Text(copy.warningTitle),
          content: Text(copy.warningBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(copy.cancel),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.near_me_outlined),
              label: Text(copy.share),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _sharingLocation = true);
    final position = await _captureExactPosition();
    if (!mounted) {
      return;
    }
    if (position == null) {
      setState(() => _sharingLocation = false);
      return;
    }

    final payload = SharedLocationPayload(
      latitude: position.latitude,
      longitude: position.longitude,
    ).encode();
    await _publishOutgoingMessage(payload);
    if (mounted) {
      setState(() => _sharingLocation = false);
    }
  }

  Future<Position?> _captureExactPosition() async {
    final copy = _LocationCopy.of(context);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showLocationError(copy.locationServicesOff);
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showLocationError(copy.locationPermissionDenied);
        return null;
      }

      return Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (_) {
      _showLocationError(copy.locationCaptureFailed);
      return null;
    }
  }

  void _showLocationError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<String?> _publishOutgoingMessage(
    String text, {
    bool clearDraft = false,
  }) async {
    final participantPubkey = widget.session.participantPubkey;
    if (_sending || participantPubkey == null) {
      return null;
    }

    setState(() {
      _sending = true;
      _deliveryState = _ChatDeliveryState.sending;
    });
    if (clearDraft) {
      _messageController.clear();
    }

    final messageId = await widget.nostrGateway.publishChatMessage(
      requestId: widget.session.request.id,
      requestEventId: widget.session.requestEventId,
      requestAuthorPubkey: widget.session.requestAuthorPubkey,
      recipientPubkey: participantPubkey,
      message: text,
    );

    if (!mounted) {
      return messageId;
    }

    if (messageId != null && !_messages.any((item) => item.id == messageId)) {
      setState(() {
        _messages.add(
          ChatMessage(
            id: messageId,
            authorName: context.l10n.chatYou,
            text: text,
            timeLabel: context.l10n.formatClock(DateTime.now()),
            isCurrentUser: true,
          ),
        );
      });
      _scheduleScrollToEnd();
    }

    setState(() {
      _sending = false;
      _deliveryState = messageId != null
          ? _ChatDeliveryState.delivered
          : _ChatDeliveryState.error;
    });

    if (messageId == null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.chatSendFailed),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
    return messageId;
  }

  void _handleRelayEvent(dynamic record) {
    final event = record.event;
    if (event.kind != weRyadomChatMessageKind) {
      return;
    }

    final requestId = event.content['request_id'] as String?;
    if (requestId != widget.session.request.id) {
      return;
    }

    if (!TrustGuard.isChatVisibleToParticipant(
      event: event,
      currentPubkey: widget.currentPubkey,
      requestAuthorPubkey: widget.session.requestAuthorPubkey,
      activeParticipantPubkey: widget.session.participantPubkey,
    )) {
      return;
    }

    final isCurrentUser = event.pubkey == widget.currentPubkey;
    final messageId = WeRyadomNostr.firstTagValue(event, 'd') ?? record.id;
    if (_messages.any((message) => message.id == messageId)) {
      return;
    }

    final message = ChatMessage(
      id: messageId,
      authorName:
          isCurrentUser ? context.l10n.chatYou : widget.session.participant.name,
      text: (event.content['message'] as String?) ?? '',
      timeLabel: context.l10n.formatClock(event.createdAt ?? DateTime.now()),
      isCurrentUser: isCurrentUser,
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _messages.add(message);
      _deliveryState = isCurrentUser
          ? _ChatDeliveryState.delivered
          : _ChatDeliveryState.online;
    });
    _scheduleScrollToEnd();
  }

  Future<void> _pickPalette() async {
    final selectedPalette = await showModalBottomSheet<ChatPalette>(
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
                  l10n.chatThemeSheetTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.chatThemeSheetHint,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                for (final palette in ChatPalette.values)
                  RadioListTile<ChatPalette>(
                    value: palette,
                    groupValue: _palette,
                    title: Text(_paletteTitle(palette, l10n)),
                    subtitle: Text(_paletteDescription(palette, l10n)),
                    onChanged: (value) => Navigator.of(context).pop(value),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedPalette != null && mounted) {
      setState(() => _palette = selectedPalette);
      await ChatPaletteStore.save(selectedPalette);
    }
  }

  Future<void> _handleSafetyAction(_ChatSafetyAction action) async {
    if (action == _ChatSafetyAction.block) {
      await widget.onParticipantBlocked?.call();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.chatBlockedSnackbar)),
      );
      return;
    }

    final reportedPubkey = widget.session.participantPubkey;
    if (reportedPubkey != null && reportedPubkey.isNotEmpty) {
      await const ReportStore().addReport(
        reportedPubkey: reportedPubkey,
        requestId: widget.session.request.id,
        reason: context.l10n.chatReportReason,
      );
    }
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.chatReportSaved)),
    );
  }

  List<String> _visibleQuickReplies(AppLocalizations l10n) {
    final replies = _quickReplies(widget.session, l10n);
    if (_showAllQuickReplies || replies.length <= 2) {
      return replies;
    }
    return replies.take(2).toList(growable: false);
  }

  bool _hasHiddenQuickReplies(AppLocalizations l10n) =>
      _quickReplies(widget.session, l10n).length > 2;
}

enum _ChatSafetyAction { report, block }

enum _ChatDeliveryState { online, sending, delivered, error }

enum _MessageDeliveryStatus { none, sending, sent, delivered, failed }

class _ChatTitle extends StatelessWidget {
  const _ChatTitle({
    required this.name,
    required this.subtitle,
    required this.deliveryLabel,
    required this.palette,
  });

  final String name;
  final String subtitle;
  final String deliveryLabel;
  final _ChatPaletteData palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: palette.accent.withValues(alpha: 0.18),
          child: Text(
            _initialsFor(name),
            style: TextStyle(
              color: palette.accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$subtitle · $deliveryLabel',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: palette.muted, fontSize: 12),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surface.withValues(alpha: 0.9),
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
                  style: TextStyle(
                    color: palette.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.shield_outlined, size: 14, color: palette.muted),
              const SizedBox(width: 4),
              Text(
                l10n.chatNoPrepay,
                style: TextStyle(
                  color: palette.muted,
                  fontSize: 11,
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

class _ChatEmptyState extends StatelessWidget {
  const _ChatEmptyState({required this.palette, required this.l10n});

  final _ChatPaletteData palette;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
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
              child: Icon(Icons.forum_outlined, size: 34, color: palette.accent),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.chatStartMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: palette.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.chatStartHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

class _MessageRow extends StatelessWidget {
  const _MessageRow({
    required this.message,
    required this.palette,
    required this.showAuthor,
    required this.showAvatar,
    required this.deliveryStatus,
  });

  final ChatMessage message;
  final _ChatPaletteData palette;
  final bool showAuthor;
  final bool showAvatar;
  final _MessageDeliveryStatus deliveryStatus;

  @override
  Widget build(BuildContext context) {
    final outgoing = message.isCurrentUser;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment:
          outgoing ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!outgoing) ...[
          SizedBox(
            width: 36,
            child: showAvatar
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
          child: _MessageBubble(
            message: message,
            palette: palette,
            showAuthor: showAuthor,
            deliveryStatus: deliveryStatus,
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.palette,
    required this.showAuthor,
    required this.deliveryStatus,
  });

  final ChatMessage message;
  final _ChatPaletteData palette;
  final bool showAuthor;
  final _MessageDeliveryStatus deliveryStatus;

  @override
  Widget build(BuildContext context) {
    final outgoing = message.isCurrentUser;
    final bubbleColor = outgoing ? palette.accent : palette.surface;
    final textColor = outgoing ? palette.onAccent : palette.onSurface;
    final metaColor = outgoing
        ? palette.onAccent.withValues(alpha: 0.78)
        : palette.muted;
    final location = SharedLocationPayload.tryParse(message.text);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.78,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(18),
          border: outgoing ? null : Border.all(color: palette.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: outgoing ? 0.1 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 10, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showAuthor) ...[
                Text(
                  message.authorName,
                  style: TextStyle(
                    color: palette.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              if (location == null)
                Text(
                  message.text,
                  style: TextStyle(
                    color: textColor,
                    height: 1.32,
                    fontSize: 16,
                  ),
                )
              else
                _SharedLocationCard(
                  location: location,
                  outgoing: outgoing,
                  palette: palette,
                  textColor: textColor,
                ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.timeLabel,
                      style: TextStyle(
                        color: metaColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (outgoing) ...[
                      const SizedBox(width: 3),
                      _DeliveryTicks(status: deliveryStatus, color: metaColor),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SharedLocationCard extends StatelessWidget {
  const _SharedLocationCard({
    required this.location,
    required this.outgoing,
    required this.palette,
    required this.textColor,
  });

  final SharedLocationPayload location;
  final bool outgoing;
  final _ChatPaletteData palette;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final copy = _LocationCopy.of(context);
    return SizedBox(
      width: 230,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: textColor, size: 22),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  outgoing ? copy.locationSent : copy.locationReceived,
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
      _MessageDeliveryStatus.sending =>
        Icon(Icons.schedule_rounded, size: 14, color: color),
      _MessageDeliveryStatus.failed =>
        Icon(Icons.error_outline_rounded, size: 14, color: color),
      _MessageDeliveryStatus.delivered =>
        Icon(Icons.done_all_rounded, size: 15, color: color),
      _ => Icon(Icons.done_rounded, size: 14, color: color),
    };
  }
}

class _ChatComposer extends StatelessWidget {
  const _ChatComposer({
    required this.palette,
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
    final copy = _LocationCopy.of(context);
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
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
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
                          child: ActionChip(
                            label: Text(reply),
                            onPressed: isSending ? null : () => onQuickReply(reply),
                          ),
                        ),
                      if (hasHiddenQuickReplies)
                        ActionChip(
                          label: Text(
                            showAllQuickReplies ? l10n.chatLess : l10n.chatMore,
                          ),
                          onPressed: onToggleQuickReplies,
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
                      tooltip: canShareLocation
                          ? copy.shareAction
                          : copy.locationUnavailable,
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
                    )
                  else
                    IconButton(
                      onPressed: null,
                      tooltip: l10n.chatSoon,
                      icon: Icon(Icons.add_rounded, color: palette.muted),
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
                          ),
                          style: TextStyle(
                            color: palette.onSurface,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: canSend ? palette.accent : palette.border,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: canSend ? onSend : null,
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: 46,
                        height: 46,
                        child: Center(
                          child: isSending && !isSharingLocation
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: palette.onAccent,
                                  ),
                                )
                              : Icon(
                                  canSend
                                      ? Icons.send_rounded
                                      : Icons.mic_none_rounded,
                                  color: canSend
                                      ? palette.onAccent
                                      : palette.muted,
                                ),
                        ),
                      ),
                    ),
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
    required this.accent,
    required this.onAccent,
    required this.onSurface,
    required this.muted,
    required this.border,
  });

  final Color background;
  final Color surface;
  final Color inputSurface;
  final Color accent;
  final Color onAccent;
  final Color onSurface;
  final Color muted;
  final Color border;
}

_ChatPaletteData _chatPaletteFromRyadom(RyadomPalette palette) {
  return _ChatPaletteData(
    background: palette.background,
    surface: palette.surface,
    inputSurface: palette.inputSurface,
    accent: palette.accent,
    onAccent: palette.onAccent,
    onSurface: palette.onSurface,
    muted: palette.muted,
    border: palette.border,
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
        accent: isDark ? const Color(0xFFFFB07D) : const Color(0xFFC97C5D),
        onAccent: isDark ? const Color(0xFF382012) : Colors.white,
        onSurface: isDark ? const Color(0xFFF8EBE2) : const Color(0xFF382219),
        muted: isDark ? const Color(0xFFD0B7AA) : const Color(0xFF886A5D),
        border: isDark ? const Color(0xFF4A342A) : const Color(0xFFE9D4C6),
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
  if (parts.length == 1) {
    final value = parts.first;
    return value.substring(0, value.length > 2 ? 2 : value.length).toUpperCase();
  }
  return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
}
