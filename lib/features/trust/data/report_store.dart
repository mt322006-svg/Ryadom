import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SafetyReport {
  const SafetyReport({
    required this.id,
    required this.reportedPubkey,
    required this.requestId,
    required this.reason,
    required this.createdAt,
  });

  final String id;
  final String reportedPubkey;
  final String requestId;
  final String reason;
  final DateTime createdAt;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'reported_pubkey': reportedPubkey,
      'request_id': requestId,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SafetyReport.fromJson(Map<String, dynamic> json) {
    return SafetyReport(
      id: json['id'] as String? ?? '',
      reportedPubkey: json['reported_pubkey'] as String? ?? '',
      requestId: json['request_id'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class ReportStore {
  const ReportStore();

  static const String _prefsKey = 'ryadom_safety_reports_v1';

  Future<List<SafetyReport>> loadReports() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List<dynamic>) {
      return const [];
    }

    return [
      for (final item in decoded)
        if (item is Map<String, dynamic>) SafetyReport.fromJson(item),
    ];
  }

  Future<List<SafetyReport>> addReport({
    required String reportedPubkey,
    required String requestId,
    required String reason,
  }) async {
    final existing = await loadReports();
    final report = SafetyReport(
      id: 'report-${DateTime.now().millisecondsSinceEpoch}',
      reportedPubkey: reportedPubkey.trim(),
      requestId: requestId.trim(),
      reason: reason.trim(),
      createdAt: DateTime.now(),
    );

    final updated = <SafetyReport>[report, ...existing].take(200).toList();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _prefsKey,
      jsonEncode(updated.map((item) => item.toJson()).toList()),
    );
    return updated;
  }
}