// NIP-44 via ndk — API marked experimental until upstream stabilizes.
// ignore_for_file: experimental_member_use

import 'package:ndk/shared/nips/nip44/nip44.dart';

/// NIP-44 encryption for chat payloads on the wire.
class Nip44ChatCrypto {
  const Nip44ChatCrypto._();

  static Future<String> encrypt({
    required String plaintext,
    required String senderPrivateKey,
    required String recipientPubkey,
  }) {
    return Nip44.encryptMessage(
      plaintext,
      senderPrivateKey,
      recipientPubkey,
    );
  }

  static Future<String> decrypt({
    required String ciphertext,
    required String recipientPrivateKey,
    required String senderPubkey,
  }) {
    return Nip44.decryptMessage(
      ciphertext,
      recipientPrivateKey,
      senderPubkey,
    );
  }
}