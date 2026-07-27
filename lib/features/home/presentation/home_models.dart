import 'package:flutter/material.dart';

enum RadarFilter { all, requests, people, signals }

enum RequestRelayState {
  localOnly(Color(0xFF95A8C4)),
  sentToRelay(Color(0xFF5DA7FF)),
  seenFromRelay(Color(0xFF7EB6FF));

  const RequestRelayState(this.color);

  final Color color;
}