import 'package:shared_preferences/shared_preferences.dart';

import '../domain/trust_guard.dart';

class ResponseRateLimiter {
  const ResponseRateLimiter();

  static const String _prefsKey = 'ryadom_response_timestamps_v1';

  Future<bool> canRespond() async {
    final timestamps = await _loadRecentTimestamps();
    return timestamps.length < TrustGuard.maxResponsesPerHour;
  }

  Future<void> recordResponse() async {
    final preferences = await SharedPreferences.getInstance();
    final timestamps = await _loadRecentTimestamps();
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    await preferences.setStringList(
      _prefsKey,
      timestamps.map((item) => '$item').toList(growable: false),
    );
  }

  Future<int> remainingResponses() async {
    final timestamps = await _loadRecentTimestamps();
    final remaining = TrustGuard.maxResponsesPerHour - timestamps.length;
    return remaining < 0 ? 0 : remaining;
  }

  Future<List<int>> _loadRecentTimestamps() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getStringList(_prefsKey) ?? const <String>[];
    final cutoff = DateTime.now()
        .subtract(const Duration(hours: 1))
        .millisecondsSinceEpoch;

    final recent = <int>[];
    for (final raw in stored) {
      final value = int.tryParse(raw);
      if (value != null && value >= cutoff) {
        recent.add(value);
      }
    }

    if (recent.length != stored.length) {
      await preferences.setStringList(
        _prefsKey,
        recent.map((item) => '$item').toList(growable: false),
      );
    }

    return recent;
  }
}