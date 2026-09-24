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

part 'chat_screen_widgets.dart';

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
  _ChatDeliveryState _deliveryState = _ChatDeliveryState.online;
  bool _showAllQuickReplies = false;
  bool _hasDraft = false;

  @override
  void initState() {
    super.initState();
    _palette = widget.initialChatPalette ?? ChatPalette.night;
    _messages.addAll(widget.session.messages);
    _chatSubscription = widget.nostrGateway.events.listen(_handleRelayEvent);
    _hasDraft = _messageController.text.trim().isNotEmpty;
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
    if (hasDraft == _hasDraft || !mounted) {
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

  String _deliveryLabelText(AppLocalizations l10n) => switch (_deliveryState) {
        _ChatDeliveryState.online => l10n.chatDeliveryOnline,
        _ChatDeliveryState.sending => l10n.chatDeliverySending,
        _ChatDeliveryState.delivered => l10n.chatDeliveryDelivered,
        _ChatDeliveryState.error => l10n.chatDeliveryError,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = _paletteData(_palette, Theme.of(context).brightness);
    final theme = Theme.of(context);
    final canSend =
        widget.session.participantPubkey != null && !_sending && _hasDraft;
    final canShareLocation = widget.session.request.isOwnRequest &&
        widget.session.participantPubkey != null &&
        !_sending;
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
          titleSpacing: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(44),
            child: _RequestContextBar(
              session: widget.session,
              palette: palette,
              l10n: l10n,
            ),
          ),
          title: _MessengerAppBarTitle(
            name: widget.session.participant.name,
            subtitle: widget.session.participant.subtitle,
            statusLabel: _deliveryLabelText(l10n),
            deliveryState: _deliveryState,
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
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ChatWallpaper(palette: palette),
                  _messages.isEmpty
                      ? _ChatEmptyState(palette: palette, l10n: l10n)
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final lastOutgoing = _lastOutgoingMessageIndex();

                            return ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
                              reverse: true,
                              itemCount: _messages.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      top: 6,
                                      bottom: 16,
                                    ),
                                    child: _ChatDaySeparator(
                                      label: l10n.chatToday,
                                      palette: palette,
                                    ),
                                  );
                                }

                                final messageIndex = _messages.length - index;
                                final message = _messages[messageIndex];
                                final groupedWithPrevious = messageIndex > 0 &&
                                    _messages[messageIndex - 1].isCurrentUser ==
                                        message.isCurrentUser &&
                                    (!_messages[messageIndex - 1]
                                            .isCurrentUser ||
                                        _messages[messageIndex - 1]
                                                .authorName ==
                                            message.authorName);
                                final groupedWithNext = messageIndex <
                                        _messages.length - 1 &&
                                    _messages[messageIndex + 1].isCurrentUser ==
                                        message.isCurrentUser &&
                                    (!_messages[messageIndex + 1]
                                            .isCurrentUser ||
                                        _messages[messageIndex + 1]
                                                .authorName ==
                                            message.authorName);

                                return Padding(
                                  padding: EdgeInsets.only(
                                    top: groupedWithPrevious ? 2 : 8,
                                    bottom: groupedWithNext ? 2 : 6,
                                  ),
                                  child: _MessengerBubbleRow(
                                    message: message,
                                    palette: palette,
                                    maxWidth: constraints.maxWidth * 0.78,
                                    showAuthor: !message.isCurrentUser &&
                                        !groupedWithPrevious,
                                    isTail: !groupedWithNext,
                                    deliveryStatus: messageIndex == lastOutgoing
                                        ? _deliveryStatusForMessage(messageIndex)
                                        : message.isCurrentUser
                                            ? _MessageDeliveryStatus.sent
                                            : _MessageDeliveryStatus.none,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ],
              ),
            ),
            _MessengerComposer(
              palette: palette,
              theme: theme,
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
              waitingForPeer: widget.session.participantPubkey == null,
              onSend: () => _sendMessage(_messageController.text),
              showLocationAction: widget.session.request.isOwnRequest,
              canShareLocation: canShareLocation,
              isSharingLocation: _sharingLocation,
              onShareLocation: _shareExactLocation,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || _sending || widget.session.participantPubkey == null) {
      return;
    }

    setState(() {
      _sending = true;
      _deliveryState = _ChatDeliveryState.sending;
    });
    _messageController.clear();
    _scheduleScrollToEnd();

    final messageId = await widget.nostrGateway.publishChatMessage(
      requestId: widget.session.request.id,
      requestEventId: widget.session.requestEventId,
      requestAuthorPubkey: widget.session.requestAuthorPubkey,
      recipientPubkey: widget.session.participantPubkey!,
      message: text,
    );

    if (!mounted) {
      return;
    }

    if (messageId != null) {
      final localMessage = ChatMessage(
        id: messageId,
        authorName: context.l10n.chatYou,
        text: text,
        timeLabel: context.l10n.formatClock(DateTime.now()),
        isCurrentUser: true,
      );
      if (!_messages.any((item) => item.id == messageId)) {
        setState(() {
          _messages.add(localMessage);
        });
      }
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

    setState(() {
      _sending = true;
      _deliveryState = _ChatDeliveryState.sending;
    });

    final messageId = await widget.nostrGateway.publishChatMessage(
      requestId: widget.session.request.id,
      requestEventId: widget.session.requestEventId,
      requestAuthorPubkey: widget.session.requestAuthorPubkey,
      recipientPubkey: widget.session.participantPubkey!,
      message: payload,
    );

    if (!mounted) {
      return;
    }

    if (messageId != null && !_messages.any((item) => item.id == messageId)) {
      setState(() {
        _messages.add(
          ChatMessage(
            id: messageId,
            authorName: context.l10n.chatYou,
            text: payload,
            timeLabel: context.l10n.formatClock(DateTime.now()),
            isCurrentUser: true,
          ),
        );
      });
      _scheduleScrollToEnd();
    }

    setState(() {
      _sending = false;
      _sharingLocation = false;
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

      return await Geolocator.getCurrentPosition(
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
                for (final palette in ChatPalette.values) ...[
                  _PaletteRow(
                    palette: palette,
                    selected: palette == _palette,
                    data: _paletteData(palette, Theme.of(context).brightness),
                    l10n: l10n,
                    onTap: () => Navigator.of(context).pop(palette),
                  ),
                  const SizedBox(height: 10),
                ],
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
        SnackBar(
          content: Text(context.l10n.chatBlockedSnackbar),
        ),
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
      SnackBar(
        content: Text(context.l10n.chatReportSaved),
      ),
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
