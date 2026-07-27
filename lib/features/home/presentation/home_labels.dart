import 'package:flutter/material.dart';

import '../../requests/domain/help_request.dart';
import '../../../theme/ryadom_palette.dart';

Color urgencyColor(RequestUrgency urgency, {RyadomColors? colors}) {
  final accent = colors?.accent ?? const Color(0xFF5DA7FF);
  final muted = colors?.muted ?? const Color(0xFF95A8C4);
  final urgent = colors?.urgent ?? const Color(0xFFFFA16D);

  switch (urgency) {
    case RequestUrgency.low:
      return muted;
    case RequestUrgency.normal:
      return accent;
    case RequestUrgency.urgent:
      return urgent;
  }
}