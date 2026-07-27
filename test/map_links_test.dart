import 'package:flutter_test/flutter_test.dart';
import 'package:ryadom/features/geo/domain/map_links.dart';

void main() {
  test('formats coordinates and builds map uris', () {
    const lat = 55.75580;
    const lon = 37.61730;

    expect(MapLinks.formatCoordinates(lat, lon), '55.75580, 37.61730');

    final google = MapLinks.googleMaps(lat, lon);
    expect(google.host, 'www.google.com');
    expect(google.queryParameters['query'], '$lat,$lon');

    final yandex = MapLinks.yandexMaps(lat, lon);
    expect(yandex.host, 'yandex.ru');
    expect(yandex.queryParameters['pt'], '$lon,$lat');

    final geo = MapLinks.geoIntent(lat, lon);
    expect(geo.scheme, 'geo');
  });
}
