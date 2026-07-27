import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../l10n/l10n_ext.dart';
import '../../../l10n/ryadom_l10n_helpers.dart';
import '../../requests/domain/help_request.dart';
import '../../../theme/ryadom_palette.dart';
import '../domain/radar_layout.dart';
import 'home_labels.dart';
import 'home_models.dart';

class RadarPanel extends StatefulWidget {
  const RadarPanel({
    super.key,
    required this.requests,
    required this.filter,
    required this.onRequestTap,
    required this.radiusLabel,
    required this.radiusMeters,
    required this.distanceForRequest,
    this.userLatitude,
    this.userLongitude,
  });

  final List<HelpRequest> requests;
  final RadarFilter filter;
  final ValueChanged<HelpRequest> onRequestTap;
  final String radiusLabel;
  final int radiusMeters;
  final double? Function(HelpRequest request) distanceForRequest;
  final double? userLatitude;
  final double? userLongitude;

  @override
  State<RadarPanel> createState() => _RadarPanelState();
}

class _RadarPanelState extends State<RadarPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final ryadom = RyadomColors.of(context);
    final markers = RadarLayout.layoutsFor(
      requests: widget.requests,
      radiusMeters: widget.radiusMeters,
      distanceForRequest: widget.distanceForRequest,
      userLatitude: widget.userLatitude,
      userLongitude: widget.userLongitude,
    );
    String? closestId;
    double? closestDistance;
    for (final marker in markers) {
      final distance = marker.distanceMeters;
      if (distance == null) {
        continue;
      }
      if (closestDistance == null || distance < closestDistance) {
        closestDistance = distance;
        closestId = marker.request.id;
      }
    }
    return AnimatedBuilder(
      animation: _scanController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ryadom.radarDeep,
                ryadom.radarMid,
                ryadom.palette.surface,
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 18,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      l10n.radarTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      l10n.radarRadius(widget.radiusLabel),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: ryadom.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AspectRatio(
                  aspectRatio: 1,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final radarSize = constraints.maxWidth;
                      final bubbleMaxWidth = radarSize * 0.38;

                      final showLabels = markers.length == 1;
                      final markerGeometries = _planMarkerGeometries(
                        markers: markers,
                        radarSize: radarSize,
                        labelWidth: showLabels ? bubbleMaxWidth : 0,
                        showLabels: showLabels,
                      );

                      final zoneLabels = [
                        for (final meters
                            in RadarZones.ringEdgeMeters(widget.radiusMeters))
                          l10n.formatDistance(meters),
                      ];

                      return Stack(
                        clipBehavior: Clip.none,
                        fit: StackFit.expand,
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _RadarPainter(
                                highlightColor: ryadom.radarGlow,
                                gridColor: ryadom.radarGlow.withValues(alpha: 0.22),
                                sweepAngle: _scanController.value * math.pi * 2,
                                ringFactors: RadarZones.ringFactors,
                                ringLabels: zoneLabels,
                                labelColor: Colors.white.withValues(alpha: 0.55),
                              ),
                            ),
                          ),
                          for (final geometry in markerGeometries)
                            AnimatedPositioned(
                              key: ValueKey('${geometry.request.id}-dot'),
                              duration: const Duration(milliseconds: 480),
                              curve: Curves.easeOutCubic,
                              left: geometry.dot.dx - _RadarMarkerGeometry.dotSize / 2,
                              top: geometry.dot.dy - _RadarMarkerGeometry.dotSize / 2,
                              child: Tooltip(
                                message: geometry.request.title,
                                child: GestureDetector(
                                  onTap: () =>
                                      widget.onRequestTap(geometry.request),
                                  child: _MarkerDot(
                                    request: geometry.request,
                                    colors: ryadom,
                                    emphasized:
                                        geometry.request.id == closestId,
                                  ),
                                ),
                              ),
                            ),
                          if (showLabels)
                            for (final geometry in markerGeometries)
                              AnimatedPositioned(
                                key: ValueKey('${geometry.request.id}-label'),
                                duration: const Duration(milliseconds: 480),
                                curve: Curves.easeOutCubic,
                                left: geometry.labelLeft,
                                top: geometry.labelTop,
                                width: geometry.labelWidth,
                                child: _MarkerLabelCard(
                                  request: geometry.request,
                                  distanceLabel: l10n.formatDistance(
                                    geometry.distanceMeters,
                                  ),
                                  mutedColor: ryadom.muted,
                                  surfaceColor: ryadom.palette.surface,
                                  borderColor: ryadom.border,
                                  onTap: () =>
                                      widget.onRequestTap(geometry.request),
                                ),
                              ),
                          Center(
                            child: _CenterDot(
                              pulse: 0.94 + (_scanController.value * 0.12),
                              glowColor: ryadom.radarGlow,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        _LegendDot(
                          color: ryadom.accent,
                          label: markers.length > 1
                              ? l10n.radarLegendMulti
                              : l10n.radarLegendSingle,
                        ),
                        _LegendDot(
                          color: ryadom.urgent,
                          label: l10n.radarLegendUrgent,
                        ),
                        _LegendDot(
                          color: ryadom.radarGlow,
                          label: l10n.radarLegendZones,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.requests.isEmpty
                          ? l10n.radarNearbySummaryEmpty
                          : l10n.radarNearbySummary(
                              widget.requests.length,
                              totalResponses(widget.requests),
                            ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: ryadom.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RadarMarkerGeometry {
  const _RadarMarkerGeometry({
    required this.request,
    required this.dot,
    required this.labelLeft,
    required this.labelTop,
    required this.labelWidth,
    required this.distanceMeters,
  });

  static const double dotSize = 14;
  static const double edgeInset = 8;
  static const double labelHeight = 62;

  final HelpRequest request;
  final Offset dot;
  final double labelLeft;
  final double labelTop;
  final double labelWidth;
  final double? distanceMeters;
}

List<_RadarMarkerGeometry> _planMarkerGeometries({
  required List<RadarMarkerLayout> markers,
  required double radarSize,
  required double labelWidth,
  required bool showLabels,
}) {
  if (markers.isEmpty) {
    return const [];
  }

  final size = Size(radarSize, radarSize);
  final center = size.center(Offset.zero);
  final planned = <_PlannedLabel>[];

  if (!showLabels) {
    return [
      for (final marker in markers)
        _RadarMarkerGeometry(
          request: marker.request,
          dot: _offsetForAlignment(marker.alignment, size),
          labelLeft: 0,
          labelTop: 0,
          labelWidth: 0,
          distanceMeters: marker.distanceMeters,
        ),
    ];
  }

  for (var index = 0; index < markers.length; index++) {
    final marker = markers[index];
    final dot = _offsetForAlignment(marker.alignment, size);
    final outward = dot - center;
    final outwardUnit = outward.distance < 1
        ? const Offset(0, -1)
        : outward / outward.distance;
    final tangent = Offset(-outwardUnit.dy, outwardUnit.dx);
    final side = index.isEven ? 1.0 : -1.0;

    var labelCenter =
        dot + outwardUnit * (labelWidth * 0.22 + 28) + tangent * (side * 18);

    final labelLeft = (labelCenter.dx - labelWidth / 2).clamp(
      _RadarMarkerGeometry.edgeInset,
      size.width - labelWidth - _RadarMarkerGeometry.edgeInset,
    );
    final labelTop = (labelCenter.dy - _RadarMarkerGeometry.labelHeight / 2).clamp(
      _RadarMarkerGeometry.edgeInset,
      size.height - _RadarMarkerGeometry.labelHeight - _RadarMarkerGeometry.edgeInset,
    );

    planned.add(
      _PlannedLabel(
        request: marker.request,
        dot: dot,
        distanceMeters: marker.distanceMeters,
        rect: Rect.fromLTWH(
          labelLeft,
          labelTop,
          labelWidth,
          _RadarMarkerGeometry.labelHeight,
        ),
      ),
    );
  }

  _resolveLabelOverlaps(planned, size);

  return [
    for (final item in planned)
      _RadarMarkerGeometry(
        request: item.request,
        dot: item.dot,
        labelLeft: item.rect.left,
        labelTop: item.rect.top,
        labelWidth: item.rect.width,
        distanceMeters: item.distanceMeters,
      ),
  ];
}

class _PlannedLabel {
  _PlannedLabel({
    required this.request,
    required this.dot,
    required this.distanceMeters,
    required this.rect,
  });

  final HelpRequest request;
  final Offset dot;
  final double? distanceMeters;
  Rect rect;
}

void _resolveLabelOverlaps(List<_PlannedLabel> labels, Size bounds) {
  const maxPasses = 10;
  const padding = 6.0;

  for (var pass = 0; pass < maxPasses; pass++) {
    var moved = false;

    for (var i = 0; i < labels.length; i++) {
      for (var j = i + 1; j < labels.length; j++) {
        final overlap = _expandedRect(labels[i].rect, padding)
            .overlaps(_expandedRect(labels[j].rect, padding));
        if (!overlap) {
          continue;
        }

        final a = labels[i].rect.center;
        final b = labels[j].rect.center;
        var push = b - a;
        if (push.distance < 1) {
          push = Offset(0, j.isEven ? 12 : -12);
        } else {
          push = push / push.distance * 10;
        }

        labels[i].rect = _shiftRect(labels[i].rect, -push / 2, bounds);
        labels[j].rect = _shiftRect(labels[j].rect, push / 2, bounds);
        moved = true;
      }
    }

    if (!moved) {
      break;
    }
  }
}

Rect _expandedRect(Rect rect, double padding) {
  return rect.inflate(padding);
}

Rect _shiftRect(Rect rect, Offset delta, Size bounds) {
  var left = rect.left + delta.dx;
  var top = rect.top + delta.dy;
  left = left.clamp(
    _RadarMarkerGeometry.edgeInset,
    bounds.width - rect.width - _RadarMarkerGeometry.edgeInset,
  );
  top = top.clamp(
    _RadarMarkerGeometry.edgeInset,
    bounds.height - rect.height - _RadarMarkerGeometry.edgeInset,
  );
  return Rect.fromLTWH(left, top, rect.width, rect.height);
}

Offset _offsetForAlignment(Alignment alignment, Size size) {
  const ringInset = 0.12;
  final w = size.width * (1 - ringInset * 2);
  final h = size.height * (1 - ringInset * 2);
  final inset = size.width * ringInset;
  return Offset(
    inset + (alignment.x + 1) / 2 * w,
    inset + (alignment.y + 1) / 2 * h,
  );
}

class _MarkerDot extends StatelessWidget {
  const _MarkerDot({
    required this.request,
    required this.colors,
    this.emphasized = false,
  });

  final HelpRequest request;
  final RyadomColors colors;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final color = urgencyColor(request.urgency, colors: colors);
    final size = emphasized ? 18.0 : 14.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: emphasized
                ? Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: emphasized ? 0.75 : 0.55),
                blurRadius: emphasized ? 18 : 12,
                spreadRadius: emphasized ? 3 : 2,
              ),
            ],
          ),
        ),
        if (request.hasCurrentUserResponded) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.check_circle_rounded,
            size: 14,
            color: colors.accent.withValues(alpha: 0.85),
          ),
        ],
      ],
    );
  }
}

class _MarkerLabelCard extends StatelessWidget {
  const _MarkerLabelCard({
    required this.request,
    required this.distanceLabel,
    required this.mutedColor,
    required this.surfaceColor,
    required this.borderColor,
    required this.onTap,
  });

  final HelpRequest request;
  final String distanceLabel;
  final Color mutedColor;
  final Color surfaceColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surfaceColor.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor.withValues(alpha: 0.65)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$distanceLabel · ${request.timeLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 11,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Только точка «вы здесь» — без подписи «Ты».
class _CenterDot extends StatelessWidget {
  const _CenterDot({required this.pulse, required this.glowColor});

  final double pulse;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: pulse,
      child: Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: glowColor.withValues(alpha: 0.2),
        ),
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: glowColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.65),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).extension<RyadomColors>()?.muted,
          ),
        ),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter({
    required this.highlightColor,
    required this.gridColor,
    required this.sweepAngle,
    required this.ringFactors,
    required this.ringLabels,
    required this.labelColor,
  });

  final Color highlightColor;
  final Color gridColor;
  final double sweepAngle;
  final List<double> ringFactors;
  final List<String> ringLabels;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          highlightColor.withValues(alpha: 0.14),
          const Color(0x00000000),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, fillPaint);

    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final factor in ringFactors) {
      canvas.drawCircle(center, radius * factor, gridPaint);
    }
    // Outer rim
    canvas.drawCircle(center, radius, gridPaint);

    for (var i = 0; i < 8; i++) {
      final angle = (math.pi * 2 / 8) * i;
      final end = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      canvas.drawLine(center, end, gridPaint);
    }

    final sweepRect = Rect.fromCircle(center: center, radius: radius);
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 3,
        endAngle: math.pi / 7,
        colors: [
          const Color(0x00000000),
          highlightColor.withValues(alpha: 0.08),
          highlightColor.withValues(alpha: 0.42),
          highlightColor.withValues(alpha: 0.10),
          const Color(0x00000000),
        ],
        stops: const [0.0, 0.38, 0.55, 0.72, 1.0],
        transform: GradientRotation(sweepAngle),
      ).createShader(sweepRect);

    canvas.drawCircle(center, radius, sweepPaint);

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    for (var i = 0; i < ringFactors.length && i < ringLabels.length; i++) {
      final ringR = radius * ringFactors[i];
      textPainter.text = TextSpan(
        text: ringLabels[i],
        style: TextStyle(
          color: labelColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      );
      textPainter.layout(maxWidth: radius * 0.4);
      // Label on the right side of each ring.
      final labelOffset = Offset(
        center.dx + ringR - textPainter.width - 4,
        center.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, labelOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.highlightColor != highlightColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.ringFactors != ringFactors ||
        oldDelegate.ringLabels != ringLabels ||
        oldDelegate.labelColor != labelColor;
  }
}