import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureNostrKeyStore {
  const SecureNostrKeyStore({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String privateKeyKey = 'nostr_private_key';
  static const String _legacyPrivateKeyKey = 'nostr_private_key';

  final FlutterSecureStorage _secureStorage;

  Future<String?> readPrivateKey() async {
    final stored = await _secureStorage.read(key: privateKeyKey);
    if (stored != null && stored.isNotEmpty) {
      return stored;
    }

    final preferences = await SharedPreferences.getInstance();
    final legacy = preferences.getString(_legacyPrivateKeyKey);
    if (legacy == null || legacy.isEmpty) {
      return null;
    }

    await _secureStorage.write(key: privateKeyKey, value: legacy);
    await preferences.remove(_legacyPrivateKeyKey);
    return legacy;
  }

  Future<void> writePrivateKey(String privateKey) async {
    await _secureStorage.write(key: privateKeyKey, value: privateKey);
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_legacyPrivateKeyKey);
  }
}