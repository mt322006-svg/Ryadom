import 'dart:convert';

import 'package:dart_nostr/dart_nostr.dart' as nostr_sdk;

import '../../requests/domain/help_request.dart';
import 'nostr_event.dart';

const weRyadomRequestKind = 31101;
const weRyadomResponseKind = 31102;
const weRyadomRequestStateKind = 31103;
const weRyadomChatMessageKind = 31104;

class WeRyadomNostr {
  const WeRyadomNostr._();

  static NostrEvent requestEvent(
    HelpRequest request, {
    required String areaBucket,
    bool includePreciseLocation = true,
  }) {
    return NostrEvent(
      kind: weRyadomRequestKind,
      content: {
        'title': request.title,
        'description': request.description,
        'area_label': request.areaLabel,
        'time_label': request.timeLabel,
        if (includePreciseLocation && request.latitude != null)
          'latitude': request.latitude,
        if (includePreciseLocation && request.longitude != null)
          'longitude': request.longitude,
      },
      tags: [
        NostrTag.single('d', request.id),
        NostrTag.single('t', 'we-ryadom'),
        NostrTag.single('t', 'request'),
        NostrTag.single('g', areaBucket),
        NostrTag.single('status', _statusTag(request.status)),
        NostrTag.single('urgent', _urgencyTag(request.urgency)),
        NostrTag.single('comp', _compensationTag(request.compensation)),
        NostrTag.single('when', request.timeLabel),
      ],
      createdAt: request.createdAt ?? DateTime.now(),
    );
  }

  static NostrEvent responseEvent({
    required String responseId,
    required String requestEventId,
    required String requestAddress,
    required String requestId,
    required String message,
    String status = 'sent',
  }) {
    return NostrEvent(
      kind: weRyadomResponseKind,
      content: {'request_id': requestId, 'message': message},
      tags: [
        NostrTag.single('d', responseId),
        NostrTag.single('e', requestEventId),
        NostrTag.single('a', requestAddress),
        NostrTag.single('t', 'we-ryadom'),
        NostrTag.single('t', 'response'),
        NostrTag.single('status', status),
      ],
    );
  }

  static NostrEvent requestStateEvent({
    required String updateId,
    required String requestEventId,
    required String requestId,
    required RequestStatus status,
    String? note,
    String? helperPubkey,
    int? rating,
  }) {
    return NostrEvent(
      kind: weRyadomRequestStateKind,
      content: {
        'request_id': requestId,
        'status': _statusTag(status),
        if (note != null && note.isNotEmpty) 'note': note,
        if (helperPubkey != null && helperPubkey.isNotEmpty)
          'helper_pubkey': helperPubkey,
        'rating': ?rating,
      },
      tags: [
        NostrTag.single('d', updateId),
        NostrTag.single('e', requestEventId),
        NostrTag.single('t', 'we-ryadom'),
        NostrTag.single('t', 'request-state'),
        NostrTag.single('status', _statusTag(status)),
        if (helperPubkey != null && helperPubkey.isNotEmpty)
          NostrTag.single('p', helperPubkey),
        if (rating != null) NostrTag.single('rating', '$rating'),
      ],
    );
  }

  static NostrEvent chatMessageEvent({
    required String messageId,
    required String requestEventId,
    required String requestAddress,
    required String requestId,
    required String recipientPubkey,
    required String message,
  }) {
    return NostrEvent(
      kind: weRyadomChatMessageKind,
      content: {
        'request_id': requestId,
        'message': message,
      },
      tags: [
        NostrTag.single('d', messageId),
        NostrTag.single('e', requestEventId),
        NostrTag.single('a', requestAddress),
        NostrTag.single('p', recipientPubkey),
        NostrTag.single('enc', 'nip44'),
        NostrTag.single('t', 'we-ryadom'),
        NostrTag.single('t', 'chat-message'),
      ],
    );
  }

  static bool isEncryptedChatEvent(NostrEvent event) {
    return firstTagValue(event, 'enc') == 'nip44';
  }

  static HelpRequest requestFromEvent(
    NostrEvent event, {
    required bool isOwnRequest,
    int responseCount = 0,
    bool hasCurrentUserResponded = false,
    RequestStatus? statusOverride,
    bool trustRemoteLocation = true,
  }) {
    final remoteLatitude = trustRemoteLocation
        ? (event.content['latitude'] as num?)?.toDouble()
        : null;
    final remoteLongitude = trustRemoteLocation
        ? (event.content['longitude'] as num?)?.toDouble()
        : null;

    return HelpRequest(
      id: firstTagValue(event, 'd') ?? 'unknown-request',
      title: (event.content['title'] as String?) ?? 'Нужна помощь',
      description: (event.content['description'] as String?) ?? '',
      compensation: compensationFromEvent(event),
      areaLabel: (event.content['area_label'] as String?) ?? 'Рядом',
      timeLabel: (event.content['time_label'] as String?) ?? 'Скоро',
      urgency: urgencyFromEvent(event),
      status: statusOverride ?? statusFromEvent(event),
      responseCount: responseCount,
      hasCurrentUserResponded: hasCurrentUserResponded,
      isOwnRequest: isOwnRequest,
      latitude: remoteLatitude,
      longitude: remoteLongitude,
      createdAt: event.createdAt,
    );
  }

  static nostr_sdk.NostrEvent toRelayEvent(
    NostrEvent event, {
    required nostr_sdk.NostrKeyPairs keyPairs,
    DateTime? createdAt,
  }) {
    return nostr_sdk.NostrEvent.fromPartialData(
      kind: event.kind,
      content: jsonEncode(event.content),
      keyPairs: keyPairs,
      tags: event.tags,
      createdAt: createdAt,
    );
  }

  static NostrEvent fromRelayEvent(nostr_sdk.NostrEvent relayEvent) {
    Map<String, Object?> content = <String, Object?>{};
    final rawContent = relayEvent.content ?? '';
    if (rawContent.isNotEmpty) {
      final decoded = jsonDecode(rawContent);
      if (decoded is Map<String, dynamic>) {
        content = decoded.cast<String, Object?>();
      }
    }

    return NostrEvent(
      kind: relayEvent.kind ?? 0,
      content: content,
      tags: relayEvent.tags ?? const <List<String>>[],
      pubkey: relayEvent.pubkey,
      createdAt: relayEvent.createdAt,
      signature: relayEvent.sig,
    );
  }

  static String? firstTagValue(NostrEvent event, String key) {
    for (final tag in event.tags) {
      if (tag.length >= 2 && tag[0] == key) {
        return tag[1];
      }
    }
    return null;
  }

  static RequestUrgency urgencyFromEvent(NostrEvent event) {
    switch (firstTagValue(event, 'urgent')) {
      case 'low':
        return RequestUrgency.low;
      case 'urgent':
        return RequestUrgency.urgent;
      case 'normal':
      default:
        return RequestUrgency.normal;
    }
  }

  static RequestCompensation compensationFromEvent(NostrEvent event) {
    switch (firstTagValue(event, 'comp')) {
      case 'paid':
        return RequestCompensation.paid;
      case 'free':
      default:
        return RequestCompensation.free;
    }
  }

  static RequestStatus statusFromEvent(NostrEvent event) {
    switch (firstTagValue(event, 'status')) {
      case 'created':
        return RequestStatus.created;
      case 'accepted':
        return RequestStatus.accepted;
      case 'in_progress':
        return RequestStatus.inProgress;
      case 'completed':
        return RequestStatus.completed;
      case 'rated':
        return RequestStatus.rated;
      case 'cancelled':
        return RequestStatus.cancelled;
      case 'visible':
      default:
        return RequestStatus.visible;
    }
  }

  static String _urgencyTag(RequestUrgency urgency) {
    switch (urgency) {
      case RequestUrgency.low:
        return 'low';
      case RequestUrgency.normal:
        return 'normal';
      case RequestUrgency.urgent:
        return 'urgent';
    }
  }

  static String _compensationTag(RequestCompensation compensation) {
    switch (compensation) {
      case RequestCompensation.free:
        return 'free';
      case RequestCompensation.paid:
        return 'paid';
    }
  }

  static String _statusTag(RequestStatus status) {
    switch (status) {
      case RequestStatus.created:
        return 'created';
      case RequestStatus.visible:
        return 'visible';
      case RequestStatus.accepted:
        return 'accepted';
      case RequestStatus.inProgress:
        return 'in_progress';
      case RequestStatus.completed:
        return 'completed';
      case RequestStatus.rated:
        return 'rated';
      case RequestStatus.cancelled:
        return 'cancelled';
    }
  }
}
