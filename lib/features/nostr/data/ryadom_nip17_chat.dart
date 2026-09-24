import 'dart:convert';
import 'dart:math';

import 'package:dart_nostr/dart_nostr.dart';

import 'nip44_chat_crypto.dart';

const int nostrNip17GiftWrapKind = 1059;
const int nostrNip59SealKind = 13;
const int nostrNip17ChatKind = 14;

class RyadomNip17Message {
  const RyadomNip17Message({
    required this.id,
    required this.requestId,
    required this.message,
    required this.senderPubkey,
    required this.tags,
    required this.createdAt,
  });

  final String id;
  final String requestId;
  final String message;
  final String senderPubkey;
  final List<List<String>> tags;
  final DateTime createdAt;
}

/// Minimal NIP-17/NIP-59 adapter around the app's existing Nostr transport.
///
/// Public relays only see kind-1059 gift wraps. The real sender, request
/// context and message body live inside the encrypted rumor.
class RyadomNip17Chat {
  const RyadomNip17Chat._();

  static const String _subjectPrefix = 'we-ryadom:';
  static final Random _random = Random.secure();

  static NostrEvent createRumor({
    required NostrKeyPairs sender,
    required String recipientPubkey,
    required String requestId,
    required String message,
    DateTime? createdAt,
  }) {
    final timestamp = createdAt ?? DateTime.now();
    final tags = <List<String>>[
      ['p', recipientPubkey],
      ['subject', '$_subjectPrefix$requestId'],
    ];
    final id = NostrEvent.getEventId(
      kind: nostrNip17ChatKind,
      content: message,
      createdAt: timestamp,
      tags: tags,
      pubkey: sender.public,
    );
    return NostrEvent(
      id: id,
      kind: nostrNip17ChatKind,
      content: message,
      sig: null,
      pubkey: sender.public,
      createdAt: timestamp,
      tags: tags,
    );
  }

  static Future<NostrEvent> wrapRumor({
    required NostrEvent rumor,
    required NostrKeyPairs sender,
    required String recipientPubkey,
  }) async {
    if (rumor.sig != null) {
      throw ArgumentError('NIP-17 rumor must be unsigned');
    }

    final encryptedRumor = await Nip44ChatCrypto.encrypt(
      plaintext: jsonEncode(rumor.toMap()),
      senderPrivateKey: sender.private,
      recipientPubkey: recipientPubkey,
    );

    final seal = NostrEvent.fromPartialData(
      kind: nostrNip59SealKind,
      content: encryptedRumor,
      keyPairs: sender,
      tags: const [],
      createdAt: _randomPastTimestamp(),
    );

    final wrapper = NostrKeyPairs.generate();
    final encryptedSeal = await Nip44ChatCrypto.encrypt(
      plaintext: jsonEncode(seal.toMap()),
      senderPrivateKey: wrapper.private,
      recipientPubkey: recipientPubkey,
    );

    return NostrEvent.fromPartialData(
      kind: nostrNip17GiftWrapKind,
      content: encryptedSeal,
      keyPairs: wrapper,
      tags: [
        ['p', recipientPubkey],
      ],
      createdAt: _randomPastTimestamp(),
    );
  }

  static Future<RyadomNip17Message?> unwrap({
    required NostrEvent giftWrap,
    required NostrKeyPairs recipient,
  }) async {
    try {
      if (giftWrap.kind != nostrNip17GiftWrapKind ||
          !giftWrap.isVerified() ||
          !_hasExactlyOneRecipient(giftWrap.tags, recipient.public)) {
        return null;
      }

      final decryptedSeal = await Nip44ChatCrypto.decrypt(
        ciphertext: giftWrap.content ?? '',
        recipientPrivateKey: recipient.private,
        senderPubkey: giftWrap.pubkey,
      );
      final seal = _eventFromJson(decryptedSeal);
      if (seal == null ||
          seal.kind != nostrNip59SealKind ||
          (seal.tags?.isNotEmpty ?? false) ||
          !seal.isVerified()) {
        return null;
      }

      final decryptedRumor = await Nip44ChatCrypto.decrypt(
        ciphertext: seal.content ?? '',
        recipientPrivateKey: recipient.private,
        senderPubkey: seal.pubkey,
      );
      final rumor = _eventFromJson(decryptedRumor);
      if (rumor == null ||
          rumor.kind != nostrNip17ChatKind ||
          rumor.sig != null ||
          rumor.pubkey != seal.pubkey ||
          !_hasCanonicalId(rumor)) {
        return null;
      }

      final subject = _firstTagValue(rumor.tags, 'subject');
      if (subject == null || !subject.startsWith(_subjectPrefix)) {
        return null;
      }
      final requestId = subject.substring(_subjectPrefix.length).trim();
      if (requestId.isEmpty || requestId.length > 128) {
        return null;
      }

      final participantTags = (rumor.tags ?? const <List<String>>[])
          .where((tag) => tag.length >= 2 && tag.first == 'p')
          .map((tag) => tag[1])
          .toList(growable: false);
      final isSenderCopy = rumor.pubkey == recipient.public;
      if (!isSenderCopy && !participantTags.contains(recipient.public)) {
        return null;
      }

      final message = rumor.content ?? '';
      if (message.isEmpty || message.length > 12000) {
        return null;
      }

      return RyadomNip17Message(
        id: rumor.id!,
        requestId: requestId,
        message: message,
        senderPubkey: rumor.pubkey,
        tags: rumor.tags ?? const <List<String>>[],
        createdAt: rumor.createdAt ?? DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  static DateTime _randomPastTimestamp() {
    return DateTime.now().subtract(
      Duration(seconds: _random.nextInt(const Duration(days: 2).inSeconds)),
    );
  }

  static bool _hasExactlyOneRecipient(
    List<List<String>>? tags,
    String recipient,
  ) {
    final pTags = (tags ?? const <List<String>>[])
        .where((tag) => tag.length >= 2 && tag.first == 'p')
        .toList(growable: false);
    return pTags.length == 1 && pTags.single[1] == recipient;
  }

  static bool _hasCanonicalId(NostrEvent event) {
    final id = event.id;
    final kind = event.kind;
    final content = event.content;
    final createdAt = event.createdAt;
    if (id == null || kind == null || content == null || createdAt == null) {
      return false;
    }
    return NostrEvent.getEventId(
          kind: kind,
          content: content,
          createdAt: createdAt,
          tags: event.tags ?? const <List<String>>[],
          pubkey: event.pubkey,
        ) ==
        id;
  }

  static String? _firstTagValue(List<List<String>>? tags, String key) {
    for (final tag in tags ?? const <List<String>>[]) {
      if (tag.length >= 2 && tag.first == key) {
        return tag[1];
      }
    }
    return null;
  }

  static NostrEvent? _eventFromJson(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return null;
    }
    final map = decoded.cast<String, dynamic>();
    final id = map['id'];
    final kind = map['kind'];
    final content = map['content'];
    final pubkey = map['pubkey'];
    final createdAt = map['created_at'];
    final tagsRaw = map['tags'];
    final sig = map['sig'];

    if (id is! String ||
        kind is! int ||
        content is! String ||
        pubkey is! String ||
        createdAt is! int ||
        tagsRaw is! List) {
      return null;
    }
    if (sig != null && sig is! String) {
      return null;
    }

    final tags = <List<String>>[];
    for (final rawTag in tagsRaw) {
      if (rawTag is! List || rawTag.length > 8) {
        return null;
      }
      final tag = <String>[];
      for (final part in rawTag) {
        if (part is! String || part.length > 512) {
          return null;
        }
        tag.add(part);
      }
      tags.add(tag);
    }

    return NostrEvent(
      id: id,
      kind: kind,
      content: content,
      sig: sig as String?,
      pubkey: pubkey,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt * 1000),
      tags: tags,
    );
  }
}
