import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../requests/domain/help_request.dart';

class RadarMarkerLayout {
  const RadarMarkerLayout({
    required this.request,
    required this.alignment,
    required this.distanceMeters,
    required this.zoneIndex,
  });

  final HelpRequest request;
  final Alignment alignment;
  final double? distanceMeters;
  final int zoneIndex;
}

/// Discrete proximity rings for the radar (honest “~” zones, not GPS meters).
class RadarZones {
  const RadarZones._();

  /// Outer edge of each ring as a fraction of the selected search radius.
  static const List<double> distanceFractions = [0.25, 0.50, 0.75, 1.0];

  /// Where markers sit (0…1 from center, Alignment scale).
  static const List<double> markerRadii = [0.28, 0.48, 0.68, 0.88];

  /// Painted ring radii (match marker rings; outermost = full canvas ring).
  static const List<double> ringFactors = [0.30, 0.50, 0.70, 0.92];

  static int zoneIndexFor({
    required double? distanceMeters,
    required int radiusMeters,
  }) {
    if (radiusMeters <= 0) {
      return 1;
    }
    if (distanceMeters == null) {
      return 1;
    }
    final fraction = (distanceMeters / radiusMeters).clamp(0.0, 1.0);
    if (fraction <= distanceFractions[0]) {
      return 0;
    }
    if (fraction <= distanceFractions[1]) {
      return 1;
    }
    if (fraction <= distanceFractions[2]) {
      return 2;
    }
    return 3;
  }

  static double markerRadiusForZone(int zoneIndex) {
    final index = zoneIndex.clamp(0, markerRadii.length - 1);
    return markerRadii[index];
  }

  /// Label distances at ring edges (for UI).
  static List<double> ringEdgeMeters(int radiusMeters) {
    return [
      for (final fraction in distanceFractions) radiusMeters * fraction,
    ];
  }
}

class _PolarMarker {
  _PolarMarker({
    required this.request,
    required this.radius,
    required this.angle,
    required this.distanceMeters,
    required this.zoneIndex,
  });

  final HelpRequest request;
  double radius;
  double angle;
  final double? distanceMeters;
  final int zoneIndex;
}

/// Places request markers on proximity rings + bearing, with anti-overlap.
class RadarLayout {
  const RadarLayout._();

  static const int _maxMarkers = 6;
  static const double _minAngleSeparation = 0.72;

  static List<RadarMarkerLayout> layoutsFor({
    required List<HelpRequest> requests,
    required int radiusMeters,
    required double? Function(HelpRequest request) distanceForRequest,
    double? userLatitude,
    double? userLongitude,
  }) {
    if (requests.isEmpty || radiusMeters <= 0) {
      return const [];
    }

    final sorted = [...requests]
      ..sort((a, b) {
        final distanceA = distanceForRequest(a);
        final distanceB = distanceForRequest(b);
        if (distanceA == null && distanceB == null) {
          return 0;
        }
        if (distanceA == null) {
          return 1;
        }
        if (distanceB == null) {
          return -1;
        }
        return distanceA.compareTo(distanceB);
      });

    final candidates = sorted.take(_maxMarkers).toList();
    final polar = <_PolarMarker>[
      for (var i = 0; i < candidates.length; i++)
        _buildMarker(
          request: candidates[i],
          distanceMeters: distanceForRequest(candidates[i]),
          radiusMeters: radiusMeters,
          userLatitude: userLatitude,
          userLongitude: userLongitude,
          slotIndex: i,
          slotCount: candidates.length,
        ),
    ];

    _fanSameZoneAngles(polar);
    _resolveOverlaps(polar);

    return [
      for (final item in polar)
        RadarMarkerLayout(
          request: item.request,
          alignment: Alignment(
            math.cos(item.angle) * item.radius,
            -math.sin(item.angle) * item.radius,
          ),
          distanceMeters: item.distanceMeters,
          zoneIndex: item.zoneIndex,
        ),
    ];
  }

  static _PolarMarker _buildMarker({
    required HelpRequest request,
    required double? distanceMeters,
    required int radiusMeters,
    double? userLatitude,
    double? userLongitude,
    required int slotIndex,
    required int slotCount,
  }) {
    final zone = RadarZones.zoneIndexFor(
      distanceMeters: distanceMeters,
      radiusMeters: radiusMeters,
    );
    return _PolarMarker(
      request: request,
      radius: RadarZones.markerRadiusForZone(zone),
      angle: _bearingRadians(
        request: request,
        userLatitude: userLatitude,
        userLongitude: userLongitude,
        slotIndex: slotIndex,
        slotCount: slotCount,
      ),
      distanceMeters: distanceMeters,
      zoneIndex: zone,
    );
  }

  /// Spread markers that share a ring so they do not stack.
  static void _fanSameZoneAngles(List<_PolarMarker> markers) {
    final byZone = <int, List<_PolarMarker>>{};
    for (final marker in markers) {
      byZone.putIfAbsent(marker.zoneIndex, () => []).add(marker);
    }

    for (final group in byZone.values) {
      if (group.length < 2) {
        continue;
      }
      final hasGeoBearing = group.any(
        (m) => m.request.latitude != null && m.request.longitude != null,
      );
      if (hasGeoBearing) {
        // Keep bearings; tiny jitter only if almost identical.
        group.sort((a, b) => a.angle.compareTo(b.angle));
        for (var i = 1; i < group.length; i++) {
          final gap = _angleGap(group[i].angle, group[i - 1].angle);
          if (gap < 0.35) {
            group[i].angle = group[i - 1].angle + 0.45;
          }
        }
        continue;
      }

      final step = (math.pi * 2) / group.length;
      const start = -math.pi / 2;
      for (var i = 0; i < group.length; i++) {
        group[i].angle = start + step * i;
      }
    }
  }

  static void _resolveOverlaps(List<_PolarMarker> markers) {
    if (markers.length <= 1) {
      return;
    }

    const maxPasses = 8;
    for (var pass = 0; pass < maxPasses; pass++) {
      var moved = false;

      for (var i = 0; i < markers.length; i++) {
        for (var j = i + 1; j < markers.length; j++) {
          final angleGap = _angleGap(markers[i].angle, markers[j].angle);
          final radiusGap = (markers[i].radius - markers[j].radius).abs();

          if (angleGap < _minAngleSeparation && radiusGap < 0.12) {
            final push = (_minAngleSeparation - angleGap) / 2 + 0.08;
            markers[i].angle -= push;
            markers[j].angle += push;
            moved = true;
          }
        }
      }

      if (!moved) {
        break;
      }
    }

    // Snap back onto zone ring after angle-only nudges.
    for (final marker in markers) {
      marker.radius = RadarZones.markerRadiusForZone(marker.zoneIndex);
    }
  }

  static double _angleGap(double a, double b) {
    final raw = (a - b).abs();
    return math.min(raw, math.pi * 2 - raw);
  }

  static double _bearingRadians({
    required HelpRequest request,
    double? userLatitude,
    double? userLongitude,
    required int slotIndex,
    required int slotCount,
  }) {
    if (userLatitude != null &&
        userLongitude != null &&
        request.latitude != null &&
        request.longitude != null) {
      final dy = request.latitude! - userLatitude;
      final dx = request.longitude! - userLongitude;
      if (dx != 0 || dy != 0) {
        return math.atan2(dy, dx);
      }
    }

    if (slotCount > 0) {
      return (math.pi * 2 / slotCount) * slotIndex - math.pi / 2;
    }

    final hash = request.id.hashCode;
    return (hash % 628) / 100;
  }
}
