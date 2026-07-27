import 'package:dart_nostr/dart_nostr.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'secure_nostr_key_store.dart';

class NostrIdentity {
  const NostrIdentity({
    required this.privateKey,
    required this.publicKey,
    required this.relayUrl,
    required this.npub,
  });

  final String privateKey;
  final String publicKey;
  final String relayUrl;
  final String npub;
}

class NostrIdentityStore {
  const NostrIdentityStore({
    SecureNostrKeyStore? keyStore,
  }) : _keyStore = keyStore ?? const SecureNostrKeyStore();

  final SecureNostrKeyStore _keyStore;

  static const String _relayUrlKey = 'nostr_relay_url';
  static const String defaultRelayUrl = 'wss://nos.lol';

  Future<NostrIdentity> loadOrCreate() async {
    final preferences = await SharedPreferences.getInstance();
    final storedPrivateKey = await _keyStore.readPrivateKey();
    final relayUrl = preferences.getString(_relayUrlKey) ?? defaultRelayUrl;

    final keyPair = storedPrivateKey != null && storedPrivateKey.isNotEmpty
        ? NostrKeyPairs(private: storedPrivateKey)
        : NostrKeyPairs.generate();

    if (storedPrivateKey == null || storedPrivateKey.isEmpty) {
      await _keyStore.writePrivateKey(keyPair.private);
    }

    if (!preferences.containsKey(_relayUrlKey)) {
      await preferences.setString(_relayUrlKey, relayUrl);
    }

    final npub = Nostr.instance.bech32.encodePublicKeyToNpub(keyPair.public);

    return NostrIdentity(
      privateKey: keyPair.private,
      publicKey: keyPair.public,
      relayUrl: relayUrl,
      npub: npub,
    );
  }

  Future<void> saveRelayUrl(String relayUrl) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_relayUrlKey, relayUrl.trim());
  }
}
