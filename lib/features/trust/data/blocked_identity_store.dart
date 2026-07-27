import 'package:shared_preferences/shared_preferences.dart';

class BlockedIdentityStore {
  const BlockedIdentityStore();

  static const String _prefsKey = 'ryadom_blocked_pubkeys_v1';

  Future<Set<String>> loadBlockedPubkeys() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getStringList(_prefsKey) ?? const <String>[];
    return stored.where((item) => item.isNotEmpty).toSet();
  }

  Future<Set<String>> blockPubkey(String pubkey) async {
    final normalized = pubkey.trim();
    if (normalized.isEmpty) {
      return loadBlockedPubkeys();
    }

    final preferences = await SharedPreferences.getInstance();
    final blocked = await loadBlockedPubkeys();
    if (blocked.contains(normalized)) {
      return blocked;
    }

    final updated = <String>[...blocked, normalized];
    await preferences.setStringList(_prefsKey, updated);
    return updated.toSet();
  }

  Future<Set<String>> unblockPubkey(String pubkey) async {
    final normalized = pubkey.trim();
    if (normalized.isEmpty) {
      return loadBlockedPubkeys();
    }

    final preferences = await SharedPreferences.getInstance();
    final blocked = await loadBlockedPubkeys();
    final updated = blocked.where((item) => item != normalized).toList();
    await preferences.setStringList(_prefsKey, updated);
    return updated.toSet();
  }
}