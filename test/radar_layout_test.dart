import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:ryadom/features/home/domain/radar_layout.dart';
import 'package:ryadom/features/requests/domain/help_request.dart';

HelpRequest _request(String id) {
  return HelpRequest(
    id: id,
    title: 'Запрос $id',
    description: 'Тест',
    compensation: RequestCompensation.free,
    areaLabel: 'Рядом',
    timeLabel: 'Сейчас',
    urgency: RequestUrgency.normal,
    status: RequestStatus.visible,
  );
}

double _alignmentRadius(RadarMarkerLayout layout) {
  return math.sqrt(
    layout.alignment.x * layout.alignment.x +
        layout.alignment.y * layout.alignment.y,
  );
}

void main() {
  test('places markers on discrete zones — closer nearer center', () {
    final close = _request('close');
    final mid = _request('mid');
    final far = _request('far');

    final layouts = RadarLayout.layoutsFor(
      requests: [far, mid, close],
      radiusMeters: 1000,
      distanceForRequest: (request) => switch (request.id) {
            'close' => 100.0,
            'mid' => 400.0,
            _ => 900.0,
          },
      userLatitude: 55.75,
      userLongitude: 37.62,
    );

    final closeLayout = layouts.firstWhere((l) => l.request.id == 'close');
    final midLayout = layouts.firstWhere((l) => l.request.id == 'mid');
    final farLayout = layouts.firstWhere((l) => l.request.id == 'far');

    expect(closeLayout.zoneIndex, 0);
    expect(midLayout.zoneIndex, 1);
    expect(farLayout.zoneIndex, 3);
    expect(_alignmentRadius(closeLayout), lessThan(_alignmentRadius(midLayout)));
    expect(_alignmentRadius(midLayout), lessThan(_alignmentRadius(farLayout)));
    expect(
      _alignmentRadius(closeLayout),
      closeTo(RadarZones.markerRadii[0], 0.02),
    );
  });

  test('uses bearing when geo is available', () {
    final north =
        _request('north').copyWith(latitude: 55.76, longitude: 37.62);
    final east = _request('east').copyWith(latitude: 55.75, longitude: 37.64);

    final layouts = RadarLayout.layoutsFor(
      requests: [north, east],
      radiusMeters: 2000,
      distanceForRequest: (_) => 500.0,
      userLatitude: 55.75,
      userLongitude: 37.62,
    );

    final northLayout = layouts.firstWhere((l) => l.request.id == 'north');
    final eastLayout = layouts.firstWhere((l) => l.request.id == 'east');

    expect(northLayout.alignment.y, lessThan(-0.1));
    expect(eastLayout.alignment.x, greaterThan(0.1));
  });

  test('spreads markers on same zone without geo', () {
    final requests = List.generate(4, (index) => _request('req-$index'));

    final layouts = RadarLayout.layoutsFor(
      requests: requests,
      radiusMeters: 1000,
      distanceForRequest: (_) => 400,
    );

    expect(layouts, hasLength(4));
    for (final layout in layouts) {
      expect(layout.zoneIndex, 1);
    }

    final angles = layouts
        .map(
          (layout) => math.atan2(
            -layout.alignment.y,
            layout.alignment.x,
          ),
        )
        .toList()
      ..sort();

    for (var i = 1; i < angles.length; i++) {
      final gap = angles[i] - angles[i - 1];
      expect(gap, greaterThan(0.5));
    }
  });

  test('zone index follows search radius fractions', () {
    expect(
      RadarZones.zoneIndexFor(distanceMeters: 200, radiusMeters: 1000),
      0,
    );
    expect(
      RadarZones.zoneIndexFor(distanceMeters: 400, radiusMeters: 1000),
      1,
    );
    expect(
      RadarZones.zoneIndexFor(distanceMeters: 700, radiusMeters: 1000),
      2,
    );
    expect(
      RadarZones.zoneIndexFor(distanceMeters: 950, radiusMeters: 1000),
      3,
    );
  });
}
