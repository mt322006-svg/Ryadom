import 'package:shared_preferences/shared_preferences.dart';

import 'nostr_event_codec.dart';

class LocalNostrRequestPersistence {
  const LocalNostrRequestPersistence._();

  static const String _snapshotKey = 'ryadom_request_store_v1';

  static Future<RequestStoreSnapshot?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_snapshotKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return NostrEventCodec.decodeSnapshot(raw);
  }

  static Future<void> save(RequestStoreSnapshot snapshot) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _snapshotKey,
      NostrEventCodec.encodeSnapshot(snapshot),
    );
  }
}
