import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryadom/features/nostr/data/ryadom_nip17_chat.dart';

void main() {
  test('NIP-17 round-trip hides sender metadata in gift wrap', () async {
    final sender = NostrKeyPairs.generate();
    final recipient = NostrKeyPairs.generate();

    final rumor = RyadomNip17Chat.createRumor(
      sender: sender,
      recipientPubkey: recipient.public,
      requestId: 'req-42',
      message: 'Я рядом',
      createdAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
    );

    final giftWrap = await RyadomNip17Chat.wrapRumor(
      rumor: rumor,
      sender: sender,
      recipientPubkey: recipient.public,
    );

    expect(giftWrap.kind, nostrNip17GiftWrapKind);
    expect(giftWrap.pubkey, isNot(sender.public));
    expect(giftWrap.tags, [
      ['p', recipient.public],
    ]);
    expect(giftWrap.content, isNot(contains('req-42')));
    expect(giftWrap.content, isNot(contains('Я рядом')));

    final decoded = await RyadomNip17Chat.unwrap(
      giftWrap: giftWrap,
      recipient: recipient,
    );

    expect(decoded, isNotNull);
    expect(decoded!.requestId, 'req-42');
    expect(decoded.message, 'Я рядом');
    expect(decoded.senderPubkey, sender.public);
  });

  test('rejects gift wrap addressed to another key', () async {
    final sender = NostrKeyPairs.generate();
    final recipient = NostrKeyPairs.generate();
    final stranger = NostrKeyPairs.generate();

    final rumor = RyadomNip17Chat.createRumor(
      sender: sender,
      recipientPubkey: recipient.public,
      requestId: 'req-1',
      message: 'test',
    );
    final giftWrap = await RyadomNip17Chat.wrapRumor(
      rumor: rumor,
      sender: sender,
      recipientPubkey: recipient.public,
    );

    final decoded = await RyadomNip17Chat.unwrap(
      giftWrap: giftWrap,
      recipient: stranger,
    );
    expect(decoded, isNull);
  });
}
