import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/chat/domain/chat_models.dart';
import 'ryadom_palette.dart';
import 'ryadom_theme.dart';

/// App-wide appearance preset (Settings).
enum RyadomAppTheme {
  classic,
  night,
  light,
  cyberpunk;

  RyadomPalette get palette => switch (this) {
        RyadomAppTheme.classic => RyadomPalette.classic,
        RyadomAppTheme.night => RyadomPalette.night,
        RyadomAppTheme.light => RyadomPalette.day,
        RyadomAppTheme.cyberpunk => RyadomPalette.cyberpunk,
      };

  ThemeData get themeData => buildRyadomTheme(palette);

  ChatPalette get chatPalette => switch (this) {
        RyadomAppTheme.classic => ChatPalette.calm,
        RyadomAppTheme.night => ChatPalette.night,
        RyadomAppTheme.light => ChatPalette.calm,
        RyadomAppTheme.cyberpunk => ChatPalette.cyberpunk,
      };

  static RyadomAppTheme fromName(String? raw) {
    if (raw == null || raw.isEmpty) {
      return RyadomAppTheme.cyberpunk;
    }
    return RyadomAppTheme.values.firstWhere(
      (item) => item.name == raw,
      orElse: () => RyadomAppTheme.cyberpunk,
    );
  }
}

abstract final class RyadomAppThemeStore {
  static const _prefsKey = 'ryadom_app_theme_v2';

  static Future<RyadomAppTheme> load() async {
    final preferences = await SharedPreferences.getInstance();
    return RyadomAppTheme.fromName(preferences.getString(_prefsKey));
  }

  static Future<void> save(RyadomAppTheme theme) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_prefsKey, theme.name);
  }
}