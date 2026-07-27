import 'package:flutter/material.dart';

import 'ryadom_palette.dart';
import 'ryadom_tokens.dart';

ThemeData buildRyadomTheme(RyadomPalette palette) {
  final isDark = palette.background.computeLuminance() < 0.45;
  final brightness = isDark ? Brightness.dark : Brightness.light;
  final ryadomColors = RyadomColors.fromPalette(palette);

  final scheme = ColorScheme(
    brightness: brightness,
    primary: palette.accent,
    onPrimary: palette.onAccent,
    secondary: palette.secondary,
    onSecondary: palette.onAccent,
    surface: palette.surface,
    onSurface: palette.onSurface,
    error: palette.urgent,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    extensions: [ryadomColors],
    scaffoldBackgroundColor: palette.background,
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 34,
        height: 1.05,
        fontWeight: FontWeight.w700,
        color: palette.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: palette.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: palette.onSurface,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.4, color: palette.onSurface),
      bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: palette.muted),
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: palette.onSurface,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: palette.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: palette.onSurface,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: palette.border.withValues(alpha: 0.65),
      thickness: 1,
      space: 1,
    ),
    iconTheme: IconThemeData(color: palette.onSurface, size: 22),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: palette.accent,
      linearTrackColor: palette.border,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: palette.accent,
      textColor: palette.onSurface,
      tileColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: palette.surface,
      modalBackgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(RyadomTokens.radiusSheet),
        ),
      ),
      dragHandleColor: palette.border,
      showDragHandle: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.inputSurface,
      hintStyle: TextStyle(color: palette.muted, fontSize: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RyadomTokens.radiusControl),
        borderSide: BorderSide(color: palette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RyadomTokens.radiusControl),
        borderSide: BorderSide(color: palette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RyadomTokens.radiusControl),
        borderSide: BorderSide(color: palette.accent, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: palette.tagSurface,
      selectedColor: palette.accent.withValues(alpha: 0.22),
      disabledColor: palette.tagSurface.withValues(alpha: 0.5),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: palette.onSurface,
      ),
      secondaryLabelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: palette.onAccent,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RyadomTokens.radiusChip),
        side: BorderSide(color: palette.border),
      ),
    ),
    cardTheme: CardThemeData(
      color: palette.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RyadomTokens.radiusCard),
        side: BorderSide(color: palette.border),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark ? const Color(0xFF172538) : const Color(0xFF2A4570),
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.15,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
        foregroundColor: palette.onSurface,
        side: BorderSide(color: palette.border, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: palette.muted,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}