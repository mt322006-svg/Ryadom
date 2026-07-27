import 'dart:convert';

import '../domain/nostr_event.dart';

class NostrEventCodec {
  const NostrEventCodec._();

  static Map<String, dynamic> recordToJson(NostrEventRecord record) {
    return {
      'id': record.id,
      'sequence': record.sequence,
      'event': eventToJson(record.event),
    };
  }

  static NostrEventRecord recordFromJson(Map<String, dynamic> json) {
    return NostrEventRecord(
      id: json['id'] as String,
      sequence: json['sequence'] as int? ?? 0,
      event: eventFromJson(json['event'] as Map<String, dynamic>),
    );
  }

  static Map<String, dynamic> eventToJson(NostrEvent event) {
    return {
      'kind': event.kind,
      'content': event.content,
      'tags': event.tags,
      'pubkey': event.pubkey,
      'createdAt': event.createdAt?.toIso8601String(),
      'signature': event.signature,
    };
  }

  static NostrEvent eventFromJson(Map<String, dynamic> json) {
    return NostrEvent(
      kind: json['kind'] as int? ?? 0,
      content: (json['content'] as Map<String, dynamic>? ?? const {})
          .cast<String, Object?>(),
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((tag) => (tag as List<dynamic>).map((v) => '$v').toList())
          .toList(),
      pubkey: json['pubkey'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'] as String),
      signature: json['signature'] as String?,
    );
  }

  static String encodeSnapshot(RequestStoreSnapshot snapshot) {
    return jsonEncode(snapshot.toJson());
  }

  static RequestStoreSnapshot? decodeSnapshot(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return RequestStoreSnapshot.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}

class RequestStoreSnapshot {
  const RequestStoreSnapshot({
    required this.events,
    required this.ownRequestIds,
    required this.respondedRequestIds,
    required this.chosenHelperByRequestId,
    required this.sequence,
  });

  final List<NostrEventRecord> events;
  final Set<String> ownRequestIds;
  final Set<String> respondedRequestIds;
  final Map<String, String> chosenHelperByRequestId;
  final int sequence;

  Map<String, dynamic> toJson() {
    return {
      'events': events.map(NostrEventCodec.recordToJson).toList(),
      'ownRequestIds': ownRequestIds.toList(),
      'respondedRequestIds': respondedRequestIds.toList(),
      'chosenHelperByRequestId': chosenHelperByRequestId,
      'sequence': sequence,
    };
  }

  factory RequestStoreSnapshot.fromJson(Map<String, dynamic> json) {
    final events = (json['events'] as List<dynamic>? ?? const [])
        .map(
          (item) => NostrEventCodec.recordFromJson(
            (item as Map).cast<String, dynamic>(),
          ),
        )
        .toList();

    return RequestStoreSnapshot(
      events: events,
      ownRequestIds: (json['ownRequestIds'] as List<dynamic>? ?? const [])
          .map((item) => '$item')
          .toSet(),
      respondedRequestIds:
          (json['respondedRequestIds'] as List<dynamic>? ?? const [])
              .map((item) => '$item')
              .toSet(),
      chosenHelperByRequestId:
          (json['chosenHelperByRequestId'] as Map<String, dynamic>? ?? const {})
              .map((key, value) => MapEntry(key, '$value')),
      sequence: json['sequence'] as int? ?? 0,
    );
  }
}