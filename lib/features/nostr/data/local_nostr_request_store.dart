import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../chat/domain/chat_models.dart';
import '../../geo/domain/geo_privacy.dart';
import '../../requests/domain/help_request.dart';
import '../../requests/domain/request_responder.dart';
import '../../trust/domain/trust_guard.dart';
import '../domain/nostr_event.dart';
import '../domain/we_ryadom_nostr.dart';
import 'local_nostr_request_persistence.dart';
import 'nostr_event_codec.dart';

class LocalNostrRequestStore {
  LocalNostrRequestStore({bool persist = true}) : _persistEnabled = persist;

  @visibleForTesting
  LocalNostrRequestStore.testOnly() : _persistEnabled = false;

  final List<NostrEventRecord> _events = [];
  final Set<String> _ownRequestIds = {};
  final Set<String> _respondedRequestIds = {};
  final Map<String, String> _chosenHelperByRequestId = {};
  final bool _persistEnabled;
  int _sequence = 0;
  int _responseSerial = 0;
  int _updateSerial = 0;

  LocalNostrRequestStore._fromSnapshot(RequestStoreSnapshot snapshot)
      : _persistEnabled = true {
    _events.addAll(snapshot.events);
    _ownRequestIds.addAll(snapshot.ownRequestIds);
    _respondedRequestIds.addAll(snapshot.respondedRequestIds);
    _chosenHelperByRequestId.addAll(snapshot.chosenHelperByRequestId);
    _sequence = snapshot.sequence;
  }

  static Future<LocalNostrRequestStore> open() async {
    final snapshot = await LocalNostrRequestPersistence.load();
    if (snapshot == null) {
      return LocalNostrRequestStore();
    }
    return LocalNostrRequestStore._fromSnapshot(snapshot);
  }

  /// Запросы других людей (не «Мои»).
  List<HelpRequest> get nearbyRequests => _materializeRequests(isOwn: false);

  List<HelpRequest> get ownRequests => _materializeRequests(isOwn: true);

  void publishRequest(
    HelpRequest request, {
    String areaBucket = 'u4xj',
    String? authorPubkey,
  }) {
    _appendRequestRecord(
      request,
      areaBucket: areaBucket,
      isOwn: true,
      authorPubkey: authorPubkey ?? 'local-owner',
    );
    _schedulePersist();
  }

  bool _isWeRyadomEvent(NostrEvent event) {
    for (final tag in event.tags) {
      if (tag.length >= 2 && tag[0] == 't' && tag[1] == 'we-ryadom') {
        return true;
      }
    }
    return false;
  }

  void ingestEventRecord(
    NostrEventRecord record, {
    String? currentPubkey,
    Set<String> blockedPubkeys = const {},
  }) {
    if (!_isWeRyadomEvent(record.event)) {
      return;
    }

    if (TrustGuard.isBlockedAuthor(
      authorPubkey: record.event.pubkey,
      blockedPubkeys: blockedPubkeys,
    )) {
      return;
    }

    if (_events.any((item) => item.id == record.id)) {
      return;
    }

    var event = record.event;
    if (event.kind == weRyadomRequestKind) {
      event = TrustGuard.sanitizePublicRequestEvent(event);
    }

    if (event.kind == weRyadomRequestStateKind) {
      final requestId = event.content['request_id'] as String? ?? '';
      final requestAuthor = requestAuthorPubkeyFor(requestId);
      if (!TrustGuard.canTrustRequestStateUpdate(
        eventPubkey: event.pubkey,
        requestAuthorPubkey: requestAuthor,
      )) {
        return;
      }
    }

    final sanitizedRecord = NostrEventRecord(
      id: record.id,
      event: event,
      sequence: record.sequence,
    );

    final stableId = WeRyadomNostr.firstTagValue(sanitizedRecord.event, 'd');
    if (stableId != null &&
        stableId.isNotEmpty &&
        sanitizedRecord.event.kind == weRyadomRequestKind) {
      final existing = _findRequestRecord(stableId);
      if (existing != null) {
        if (_isPlaceholderRequestRecord(existing)) {
          _upgradeRequestRecord(
            existing,
            sanitizedRecord,
            currentPubkey: currentPubkey,
          );
        }
        return;
      }
    }

    _events.add(sanitizedRecord);
    _sequence =
        sanitizedRecord.sequence >= _sequence ? sanitizedRecord.sequence + 1 : _sequence;

    final requestId = _requestStableId(sanitizedRecord.event);
    if (sanitizedRecord.event.kind == weRyadomRequestKind &&
        currentPubkey != null &&
        sanitizedRecord.event.pubkey == currentPubkey &&
        requestId.isNotEmpty) {
      _ownRequestIds.add(requestId);
    }

    if (sanitizedRecord.event.kind == weRyadomResponseKind &&
        currentPubkey != null &&
        sanitizedRecord.event.pubkey == currentPubkey) {
      final responseRequestId =
          sanitizedRecord.event.content['request_id'] as String? ?? '';
      if (responseRequestId.isNotEmpty) {
        _respondedRequestIds.add(responseRequestId);
      }
    }

    if (sanitizedRecord.event.kind == weRyadomRequestStateKind) {
      final stateRequestId =
          sanitizedRecord.event.content['request_id'] as String? ?? '';
      final helperPubkey =
          sanitizedRecord.event.content['helper_pubkey'] as String? ??
          WeRyadomNostr.firstTagValue(sanitizedRecord.event, 'p');
      if (stateRequestId.isNotEmpty &&
          helperPubkey != null &&
          helperPubkey.isNotEmpty) {
        _chosenHelperByRequestId[stateRequestId] = helperPubkey;
      }
    }

    _schedulePersist();
  }

  String? requestEventIdFor(String requestId) {
    return _findRequestRecord(requestId)?.id;
  }

  String? requestAuthorPubkeyFor(String requestId) {
    return _findRequestRecord(requestId)?.event.pubkey;
  }

  String? chosenHelperPubkeyFor(String requestId) {
    return _chosenHelperByRequestId[requestId];
  }

  List<RequestResponder> respondersFor(String requestId) {
    final requestRecord = _findRequestRecord(requestId);
    if (requestRecord == null) {
      return const [];
    }

    final responses = _events.where((item) {
      if (item.event.kind != weRyadomResponseKind) {
        return false;
      }
      return _eventBelongsToRequest(item.event, requestRecord);
    }).toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));

    return [
      for (final record in responses)
        RequestResponder(
          responseId: record.id,
          pubkey: record.event.pubkey ?? 'unknown',
          message: (record.event.content['message'] as String?) ?? 'Готов помочь',
          createdAt: record.event.createdAt ?? DateTime.now(),
        ),
    ];
  }

  HelpRequest chooseHelper({
    required String requestId,
    required String helperPubkey,
  }) {
    _chosenHelperByRequestId[requestId] = helperPubkey;

    final requestRecord = _findRequestRecord(requestId);
    if (requestRecord != null) {
      final updateId = 'choose-$requestId-${++_updateSerial}';
      final updateEvent = appRequestEventWithPubkey(
        WeRyadomNostr.requestStateEvent(
          updateId: updateId,
          requestEventId: requestRecord.id,
          requestId: requestId,
          status: RequestStatus.inProgress,
          note: 'Помощник выбран',
          helperPubkey: helperPubkey,
        ),
        requestRecord.event.pubkey,
      );
      _appendEvent(id: updateId, event: updateEvent);
    }

    _schedulePersist();

    return ownRequests.firstWhere(
      (item) => item.id == requestId,
      orElse: () => nearbyRequests.firstWhere((item) => item.id == requestId),
    );
  }

  HelpRequest updateRequestStatus({
    required String requestId,
    required RequestStatus status,
    String? note,
    String? helperPubkey,
    int? rating,
  }) {
    if (helperPubkey != null && helperPubkey.isNotEmpty) {
      _chosenHelperByRequestId[requestId] = helperPubkey;
    }

    final requestRecord = _findRequestRecord(requestId);
    if (requestRecord != null) {
      final updateId = 'state-$requestId-${++_updateSerial}';
      final updateEvent = appRequestEventWithPubkey(
        WeRyadomNostr.requestStateEvent(
          updateId: updateId,
          requestEventId: requestRecord.id,
          requestId: requestId,
          status: status,
          note: note,
          helperPubkey: helperPubkey,
          rating: rating,
        ),
        requestRecord.event.pubkey,
      );
      _appendEvent(id: updateId, event: updateEvent);
    }

    _schedulePersist();

    for (final item in ownRequests) {
      if (item.id == requestId) {
        return item;
      }
    }
    return nearbyRequests.firstWhere((item) => item.id == requestId);
  }

  List<ChatMessage> chatMessagesFor({
    required String requestId,
    required String? currentPubkey,
    required String participantName,
    required String requestAuthorPubkey,
    required String? activeParticipantPubkey,
  }) {
    final records = _events.where((item) {
      if (item.event.kind != weRyadomChatMessageKind) {
        return false;
      }
      if (item.event.content['request_id'] != requestId) {
        return false;
      }
      return TrustGuard.isChatVisibleToParticipant(
        event: item.event,
        currentPubkey: currentPubkey,
        requestAuthorPubkey: requestAuthorPubkey,
        activeParticipantPubkey: activeParticipantPubkey,
      );
    }).toList()
      ..sort((a, b) {
        final aTime = a.event.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.event.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aTime.compareTo(bTime);
      });

    return [
      for (final record in records)
        _chatMessageFromRecord(
          record,
          currentPubkey: currentPubkey,
          participantName: participantName,
        ),
    ];
  }

  ChatMessage _chatMessageFromRecord(
    NostrEventRecord record, {
    required String? currentPubkey,
    required String participantName,
  }) {
    final isCurrentUser =
        currentPubkey != null && record.event.pubkey == currentPubkey;
    final createdAt = record.event.createdAt ?? DateTime.now();
    final hours = createdAt.hour.toString().padLeft(2, '0');
    final minutes = createdAt.minute.toString().padLeft(2, '0');

    return ChatMessage(
      id: WeRyadomNostr.firstTagValue(record.event, 'd') ?? record.id,
      authorName: isCurrentUser ? 'Ты' : participantName,
      text: (record.event.content['message'] as String?) ?? '',
      timeLabel: '$hours:$minutes',
      isCurrentUser: isCurrentUser,
    );
  }

  String? latestResponderPubkeyFor(String requestId) {
    final chosen = _chosenHelperByRequestId[requestId];
    if (chosen != null && chosen.isNotEmpty) {
      return chosen;
    }
    final requestRecord = _findRequestRecord(requestId);
    if (requestRecord == null) {
      return null;
    }

    final responses = _events.where((item) {
      if (item.event.kind != weRyadomResponseKind) {
        return false;
      }
      return _eventBelongsToRequest(item.event, requestRecord);
    }).toList()..sort((a, b) => b.sequence.compareTo(a.sequence));

    return responses.isEmpty ? null : responses.first.event.pubkey;
  }

  HelpRequest respondToRequest(HelpRequest request) {
    if (request.isOwnRequest || request.hasCurrentUserResponded) {
      return request;
    }

    final requestRecord = _findRequestRecord(request.id);
    if (requestRecord == null) {
      return request;
    }

    final responseId = 'resp-${request.id}-${++_responseSerial}';
    final responseEvent = WeRyadomNostr.responseEvent(
      responseId: responseId,
      requestEventId: requestRecord.id,
      requestAddress:
          '$weRyadomRequestKind:local:${_requestStableId(requestRecord.event)}',
      requestId: request.id,
      message: 'Я рядом, могу подойти.',
    );

    _appendEvent(id: responseId, event: responseEvent);
    _respondedRequestIds.add(request.id);

    _schedulePersist();

    return nearbyRequests.firstWhere((item) => item.id == request.id);
  }

  @visibleForTesting
  void installRequestForTests(
    HelpRequest request, {
    required bool isOwn,
    String? authorPubkey,
  }) {
    final owner = isOwn || request.isOwnRequest;
    _appendRequestRecord(
      request,
      areaBucket: 'u4xj',
      isOwn: owner,
      authorPubkey: authorPubkey ?? (owner ? 'test-owner' : 'test-nearby'),
    );

    final requestRecord = _findRequestRecord(request.id);
    if (requestRecord == null) {
      return;
    }

    for (var i = 0; i < request.responseCount; i++) {
      final responseId = 'test-resp-${request.id}-${i + 1}';
      final responseEvent = WeRyadomNostr.responseEvent(
        responseId: responseId,
        requestEventId: requestRecord.id,
        requestAddress:
            '$weRyadomRequestKind:local:${_requestStableId(requestRecord.event)}',
        requestId: request.id,
        message: 'test-response',
      );
      _appendEvent(
        id: responseId,
        event: appRequestEventWithPubkey(
          responseEvent,
          owner ? 'test-helper' : 'test-responder',
        ),
      );
    }

    if (request.hasCurrentUserResponded) {
      _respondedRequestIds.add(request.id);
    }

    if (request.status != RequestStatus.visible) {
      final updateId = 'test-upd-${request.id}';
      final updateEvent = appRequestEventWithPubkey(
        WeRyadomNostr.requestStateEvent(
          updateId: updateId,
          requestEventId: requestRecord.id,
          requestId: request.id,
          status: request.status,
          note: 'test-state',
        ),
        requestRecord.event.pubkey,
      );
      _appendEvent(id: updateId, event: updateEvent);
    }
  }

  void _appendRequestRecord(
    HelpRequest request, {
    required String areaBucket,
    required bool isOwn,
    String? authorPubkey,
  }) {
    final stamped = request.copyWith(
      isOwnRequest: false,
      hasCurrentUserResponded: false,
      createdAt: request.createdAt ?? DateTime.now(),
    );
    final baseEvent = WeRyadomNostr.requestEvent(
      stamped,
      areaBucket: areaBucket,
      includePreciseLocation: false,
    );
    final event = appRequestEventWithPubkey(baseEvent, authorPubkey);
    final eventId = 'req-event-${request.id}';
    _appendEvent(id: eventId, event: event);
    if (isOwn) {
      _ownRequestIds.add(request.id);
    }
  }

  void _appendEvent({required String id, required NostrEvent event}) {
    _events.add(NostrEventRecord(id: id, event: event, sequence: _sequence++));
    _schedulePersist();
  }

  void _schedulePersist() {
    if (!_persistEnabled) {
      return;
    }
    unawaited(_persistNow());
  }

  Future<void> _persistNow() async {
    await LocalNostrRequestPersistence.save(
      RequestStoreSnapshot(
        events: List<NostrEventRecord>.from(_events),
        ownRequestIds: Set<String>.from(_ownRequestIds),
        respondedRequestIds: Set<String>.from(_respondedRequestIds),
        chosenHelperByRequestId: Map<String, String>.from(
          _chosenHelperByRequestId,
        ),
        sequence: _sequence,
      ),
    );
  }

  NostrEventRecord? _findRequestRecord(String requestId) {
    for (final record in _events.reversed) {
      if (record.event.kind == weRyadomRequestKind &&
          _requestStableId(record.event) == requestId) {
        return record;
      }
    }
    return null;
  }

  List<HelpRequest> _materializeRequests({required bool isOwn}) {
    final requestRecords = _latestRequestRecords()
        .where(
          (record) =>
              _ownRequestIds.contains(_requestStableId(record.event)) == isOwn,
        )
        .toList()
      ..sort((a, b) => b.sequence.compareTo(a.sequence));

    return [
      for (final record in requestRecords)
        _requestFromRecord(record, isOwn: isOwn),
    ];
  }

  HelpRequest _requestFromRecord(
    NostrEventRecord record, {
    required bool isOwn,
  }) {
    final requestId = _requestStableId(record.event);
    final request = WeRyadomNostr.requestFromEvent(
      record.event,
      isOwnRequest: isOwn,
      responseCount: _responseCountForRequestRecord(record),
      hasCurrentUserResponded: _respondedRequestIds.contains(requestId),
      statusOverride: _statusForRequestRecord(record),
      trustRemoteLocation: false,
    );
    return _enrichWithApproximateLocation(request, record.event);
  }

  HelpRequest _enrichWithApproximateLocation(
    HelpRequest request,
    NostrEvent event,
  ) {
    if (request.latitude != null && request.longitude != null) {
      return request;
    }

    final bucket = WeRyadomNostr.firstTagValue(event, 'g');
    final coords = GeoPrivacy.parseAreaBucket(bucket);
    if (coords == null) {
      return request;
    }

    return request.copyWith(
      latitude: coords.latitude,
      longitude: coords.longitude,
    );
  }

  int _responseCountForRequestRecord(NostrEventRecord record) {
    return _events.where((item) {
      if (item.event.kind != weRyadomResponseKind) {
        return false;
      }
      return _eventBelongsToRequest(item.event, record);
    }).length;
  }

  RequestStatus _statusForRequestRecord(NostrEventRecord record) {
    final requestAuthor = record.event.pubkey;
    final updates = _events.where((item) {
      if (item.event.kind != weRyadomRequestStateKind) {
        return false;
      }
      if (!TrustGuard.canTrustRequestStateUpdate(
        eventPubkey: item.event.pubkey,
        requestAuthorPubkey: requestAuthor,
      )) {
        return false;
      }
      return _eventBelongsToRequest(item.event, record);
    }).toList()..sort((a, b) => b.sequence.compareTo(a.sequence));

    if (updates.isEmpty) {
      return WeRyadomNostr.statusFromEvent(record.event);
    }

    return WeRyadomNostr.statusFromEvent(updates.first.event);
  }

  String _requestStableId(NostrEvent event) {
    return WeRyadomNostr.firstTagValue(event, 'd') ?? '';
  }

  bool _isPlaceholderRequestRecord(NostrEventRecord record) {
    if (record.event.kind != weRyadomRequestKind) {
      return false;
    }
    return record.id.startsWith('req-event-') ||
        record.event.pubkey == 'local-owner';
  }

  void _upgradeRequestRecord(
    NostrEventRecord placeholder,
    NostrEventRecord relay, {
    String? currentPubkey,
  }) {
    final index = _events.indexWhere((item) => item.id == placeholder.id);
    if (index < 0) {
      return;
    }

    final requestId = _requestStableId(relay.event);
    _events[index] = NostrEventRecord(
      id: relay.id,
      event: relay.event,
      sequence: relay.sequence > placeholder.sequence
          ? relay.sequence
          : placeholder.sequence,
    );
    if (relay.sequence >= _sequence) {
      _sequence = relay.sequence + 1;
    }

    if (currentPubkey != null &&
        relay.event.pubkey == currentPubkey &&
        requestId.isNotEmpty) {
      _ownRequestIds.add(requestId);
    }

    _schedulePersist();
  }

  bool _eventBelongsToRequest(NostrEvent event, NostrEventRecord requestRecord) {
    final requestStableId = _requestStableId(requestRecord.event);
    final eventRef = WeRyadomNostr.firstTagValue(event, 'e');
    if (eventRef != null &&
        eventRef.isNotEmpty &&
        eventRef == requestRecord.id) {
      return true;
    }

    final contentRequestId = event.content['request_id'] as String?;
    return contentRequestId != null &&
        contentRequestId.isNotEmpty &&
        contentRequestId == requestStableId;
  }

  List<NostrEventRecord> _latestRequestRecords() {
    final latestByRequestId = <String, NostrEventRecord>{};

    for (final record in _events) {
      if (record.event.kind != weRyadomRequestKind) {
        continue;
      }

      final requestId = _requestStableId(record.event);
      if (requestId.isEmpty) {
        continue;
      }

      final existing = latestByRequestId[requestId];
      if (existing == null || existing.sequence < record.sequence) {
        latestByRequestId[requestId] = record;
      }
    }

    return latestByRequestId.values.toList(growable: false);
  }
}

NostrEvent appRequestEventWithPubkey(NostrEvent event, String? pubkey) {
  if (pubkey == null || pubkey.isEmpty) {
    return event;
  }

  return NostrEvent(
    kind: event.kind,
    content: event.content,
    tags: event.tags,
    pubkey: pubkey,
    createdAt: event.createdAt,
    signature: event.signature,
  );
}
