import 'dart:convert';

/// Exact coordinates shared deliberately inside an encrypted one-to-one chat.
class SharedLocationPayload {
  const SharedLocationPayload({
    required this.latitude,
    required this.longitude,
  });

  static const String type = 'ryadom.location.v1';

  final double latitude;
  final double longitude;

  String encode() {
    return jsonEncode({
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  static SharedLocationPayload? tryParse(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic> || decoded['type'] != type) {
        return null;
      }

      final latitude = (decoded['latitude'] as num?)?.toDouble();
      final longitude = (decoded['longitude'] as num?)?.toDouble();
      if (latitude == null || longitude == null) {
        return null;
      }
      if (latitude < -90 || latitude > 90) {
        return null;
      }
      if (longitude < -180 || longitude > 180) {
        return null;
      }

      return SharedLocationPayload(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (_) {
      return null;
    }
  }
}
