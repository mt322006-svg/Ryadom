import 'package:flutter/material.dart';

/// Shared «Ночная» palette (from chat) for the whole app.
@immutable
class RyadomPalette {
  const RyadomPalette({
    required this.background,
    required this.surface,
    required this.inputSurface,
    required this.tagSurface,
    required this.accent,
    required this.onAccent,
    required this.onSurface,
    required this.muted,
    required this.border,
    required this.secondary,
    required this.urgent,
    required this.radarDeep,
    required this.radarMid,
    required this.radarGlow,
  });

  final Color background;
  final Color surface;
  final Color inputSurface;
  final Color tagSurface;
  final Color accent;
  final Color onAccent;
  final Color onSurface;
  final Color muted;
  final Color border;
  final Color secondary;
  final Color urgent;
  final Color radarDeep;
  final Color radarMid;
  final Color radarGlow;

  /// Original green «Мы Рядом» look (dark).
  static const RyadomPalette classic = RyadomPalette(
    background: Color(0xFF071515),
    surface: Color(0xFF102222),
    inputSurface: Color(0xFF132828),
    tagSurface: Color(0xFF18312E),
    accent: Color(0xFF5EE7C0),
    onAccent: Color(0xFF0A1A18),
    onSurface: Color(0xFFE7F3EF),
    muted: Color(0xFF9FB7B0),
    border: Color(0xFF1E3836),
    secondary: Color(0xFF48EFB8),
    urgent: Color(0xFFFFA16D),
    radarDeep: Color(0xFF071A1A),
    radarMid: Color(0xFF0A2322),
    radarGlow: Color(0xFF42F5BF),
  );

  static const RyadomPalette night = RyadomPalette(
    background: Color(0xFF050A12),
    surface: Color(0xFF101A28),
    inputSurface: Color(0xFF132033),
    tagSurface: Color(0xFF172538),
    accent: Color(0xFF5DA7FF),
    onAccent: Colors.white,
    onSurface: Color(0xFFE8EFFA),
    muted: Color(0xFF95A8C4),
    border: Color(0xFF20324B),
    secondary: Color(0xFF7EB6FF),
    urgent: Color(0xFFFFA16D),
    radarDeep: Color(0xFF050A12),
    radarMid: Color(0xFF0D1522),
    radarGlow: Color(0xFF5DA7FF),
  );

  /// Light companion — same character, readable in daylight.
  static const RyadomPalette day = RyadomPalette(
    background: Color(0xFFE8EEF8),
    surface: Color(0xFFF5F8FF),
    inputSurface: Color(0xFFEDF3FC),
    tagSurface: Color(0xFFDCE8FA),
    accent: Color(0xFF3B7ED4),
    onAccent: Colors.white,
    onSurface: Color(0xFF152238),
    muted: Color(0xFF5A6F8C),
    border: Color(0xFFC5D4EA),
    secondary: Color(0xFF5B9AE8),
    urgent: Color(0xFFC97C5D),
    radarDeep: Color(0xFF1A2D4A),
    radarMid: Color(0xFF243B5C),
    radarGlow: Color(0xFF5DA7FF),
  );

  /// Neon magenta / cyan on deep black — cyberpunk radar.
  static const RyadomPalette cyberpunk = RyadomPalette(
    background: Color(0xFF0A0412),
    surface: Color(0xFF160A1E),
    inputSurface: Color(0xFF1C0E28),
    tagSurface: Color(0xFF241430),
    accent: Color(0xFFFF2EC8),
    onAccent: Color(0xFF1A0514),
    onSurface: Color(0xFFF5E9FF),
    muted: Color(0xFFA88CC4),
    border: Color(0xFF3D1F52),
    secondary: Color(0xFF00F0FF),
    urgent: Color(0xFFFFE566),
    radarDeep: Color(0xFF07020E),
    radarMid: Color(0xFF12081C),
    radarGlow: Color(0xFF00E8FF),
  );

  @Deprecated('Use RyadomAppTheme instead')
  static RyadomPalette forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? night : day;
  }
}

@immutable
class RyadomColors extends ThemeExtension<RyadomColors> {
  const RyadomColors({
    required this.palette,
    required this.tagSurface,
    required this.inputSurface,
    required this.urgent,
    required this.radarDeep,
    required this.radarMid,
    required this.radarGlow,
  });

  final RyadomPalette palette;
  final Color tagSurface;
  final Color inputSurface;
  final Color urgent;
  final Color radarDeep;
  final Color radarMid;
  final Color radarGlow;

  factory RyadomColors.fromPalette(RyadomPalette palette) {
    return RyadomColors(
      palette: palette,
      tagSurface: palette.tagSurface,
      inputSurface: palette.inputSurface,
      urgent: palette.urgent,
      radarDeep: palette.radarDeep,
      radarMid: palette.radarMid,
      radarGlow: palette.radarGlow,
    );
  }

  Color get accent => palette.accent;
  Color get muted => palette.muted;
  Color get border => palette.border;

  static RyadomColors of(BuildContext context) {
    return Theme.of(context).extension<RyadomColors>()!;
  }

  @override
  RyadomColors copyWith({
    RyadomPalette? palette,
    Color? tagSurface,
    Color? inputSurface,
    Color? urgent,
    Color? radarDeep,
    Color? radarMid,
    Color? radarGlow,
  }) {
    return RyadomColors(
      palette: palette ?? this.palette,
      tagSurface: tagSurface ?? this.tagSurface,
      inputSurface: inputSurface ?? this.inputSurface,
      urgent: urgent ?? this.urgent,
      radarDeep: radarDeep ?? this.radarDeep,
      radarMid: radarMid ?? this.radarMid,
      radarGlow: radarGlow ?? this.radarGlow,
    );
  }

  @override
  RyadomColors lerp(ThemeExtension<RyadomColors>? other, double t) {
    if (other is! RyadomColors) {
      return this;
    }
    return other;
  }
}