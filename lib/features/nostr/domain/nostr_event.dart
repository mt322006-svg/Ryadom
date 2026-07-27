class NostrEvent {
  const NostrEvent({
    required this.kind,
    required this.content,
    required this.tags,
    this.pubkey,
    this.createdAt,
    this.signature,
  });

  final int kind;
  final Map<String, Object?> content;
  final List<List<String>> tags;
  final String? pubkey;
  final DateTime? createdAt;
  final String? signature;
}

class NostrEventRecord {
  const NostrEventRecord({
    required this.id,
    required this.event,
    required this.sequence,
  });

  final String id;
  final NostrEvent event;
  final int sequence;
}

class NostrTag {
  const NostrTag._();

  static List<String> single(String key, String value) => [key, value];
}
