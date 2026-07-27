import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryadom/features/nostr/data/nip44_chat_crypto.dart';

void main() {
  test('encrypts and decrypts chat payload with nip44', () async {
    final sender = NostrKeyPairs.generate();
    final recipient = NostrKeyPairs.generate();

    const plaintext = 'Я рядом, выхожу через 5 минут.';

    final ciphertext = await Nip44ChatCrypto.encrypt(
      plaintext: plaintext,
      senderPrivateKey: sender.private,
      recipientPubkey: recipient.public,
    );

    final decrypted = await Nip44ChatCrypto.decrypt(
      ciphertext: ciphertext,
      recipientPrivateKey: recipient.private,
      senderPubkey: sender.public,
    );

    expect(decrypted, plaintext);
  });
}