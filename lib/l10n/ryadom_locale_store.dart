import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class RyadomLocaleStore {
  static const String _prefsKey = 'ryadom_locale_v1';

  static const Locale defaultLocale = Locale('ru');

  static const List<Locale> supportedLocales = [
    Locale('ru'),
    Locale('en'),
  ];

  static Future<Locale> load() async {
    final preferences = await SharedPreferences.getInstance();
    final code = preferences.getString(_prefsKey);
    if (code == null || code.isEmpty) {
      return defaultLocale;
    }
    return Locale(code);
  }

  static Future<void> save(Locale locale) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_prefsKey, locale.languageCode);
  }
}