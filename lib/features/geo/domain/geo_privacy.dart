class GeoPrivacy {
  const GeoPrivacy._();

  static String approximateAreaLabel(
    double latitude,
    double longitude, {
    double precision = 0.02,
  }) {
    final lat = _snap(latitude, precision);
    final lon = _snap(longitude, precision);
    return 'Зона ${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
  }

  static String areaBucket(
    double latitude,
    double longitude, {
    double precision = 0.02,
  }) {
    final lat = _snap(latitude, precision);
    final lon = _snap(longitude, precision);
    return '${lat.toStringAsFixed(2)}:${lon.toStringAsFixed(2)}';
  }

  static ({double latitude, double longitude})? parseAreaBucket(
    String? bucket,
  ) {
    if (bucket == null || bucket.isEmpty || bucket == 'global') {
      return null;
    }

    final parts = bucket.split(':');
    if (parts.length != 2) {
      return null;
    }

    final latitude = double.tryParse(parts[0]);
    final longitude = double.tryParse(parts[1]);
    if (latitude == null || longitude == null) {
      return null;
    }

    return (latitude: latitude, longitude: longitude);
  }

  static double _snap(double value, double precision) {
    return (value / precision).round() * precision;
  }
}
