import 'package:url_launcher/url_launcher.dart';

/// Builds external map links for approximate request coordinates.
class MapLinks {
  const MapLinks._();

  static String formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
  }

  /// Google Maps search (lat,lon).
  static Uri googleMaps(double latitude, double longitude) {
    return Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
  }

  /// Yandex Maps point (lon,lat order in pt=).
  static Uri yandexMaps(double latitude, double longitude) {
    return Uri.parse(
      'https://yandex.ru/maps/?pt=$longitude,$latitude&z=15&l=map',
    );
  }

  /// Generic geo: intent (system picker).
  static Uri geoIntent(double latitude, double longitude) {
    return Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude');
  }

  static Future<bool> open(Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        return launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// Prefer Yandex → Google → geo: (first that works).
  static Future<bool> openInMaps({
    required double latitude,
    required double longitude,
    required MapApp preferred,
  }) async {
    final candidates = switch (preferred) {
      MapApp.yandex => [
          yandexMaps(latitude, longitude),
          googleMaps(latitude, longitude),
          geoIntent(latitude, longitude),
        ],
      MapApp.google => [
          googleMaps(latitude, longitude),
          yandexMaps(latitude, longitude),
          geoIntent(latitude, longitude),
        ],
      MapApp.system => [
          geoIntent(latitude, longitude),
          googleMaps(latitude, longitude),
          yandexMaps(latitude, longitude),
        ],
    };

    for (final uri in candidates) {
      if (await open(uri)) {
        return true;
      }
    }
    return false;
  }
}

enum MapApp { yandex, google, system }
