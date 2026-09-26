class EncryptedPayload {
  const EncryptedPayload({
    required this.ciphertext,
    required this.scheme,
    this.metadata = const <String, String>{},
  });

  final String ciphertext;
  final String scheme;

  /// Non-sensitive routing/format metadata only.
  ///
  /// Plaintext message content, exact coordinates and other private payloads
  /// must never be placed here.
  final Map<String, String> metadata;
}
