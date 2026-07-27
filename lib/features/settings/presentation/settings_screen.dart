import 'package:flutter/material.dart';

import '../../../l10n/l10n_ext.dart';
import '../../../l10n/ryadom_l10n_helpers.dart';
import '../../../l10n/ryadom_locale_store.dart';
import '../../../theme/ryadom_app_theme.dart';
import '../../../theme/ryadom_palette.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.currentTheme,
    required this.onThemeSelected,
    required this.currentLocale,
    required this.onLocaleSelected,
    this.onOpenRelay,
    this.onOpenGeo,
  });

  final RyadomAppTheme currentTheme;
  final ValueChanged<RyadomAppTheme> onThemeSelected;
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleSelected;
  final VoidCallback? onOpenRelay;
  final VoidCallback? onOpenGeo;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late RyadomAppTheme _theme;
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _theme = widget.currentTheme;
    _locale = widget.currentLocale;
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentTheme != widget.currentTheme) {
      _theme = widget.currentTheme;
    }
    if (oldWidget.currentLocale != widget.currentLocale) {
      _locale = widget.currentLocale;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Text(l10n.settingsLanguage, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            l10n.settingsLanguageHint,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                for (final locale in RyadomLocaleStore.supportedLocales) ...[
                  if (locale != RyadomLocaleStore.supportedLocales.first)
                    const Divider(height: 1),
                  ListTile(
                    title: Text(
                      locale.languageCode == 'ru'
                          ? l10n.languageRussian
                          : l10n.languageEnglish,
                    ),
                    trailing: Icon(
                      _locale.languageCode == locale.languageCode
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: _locale.languageCode == locale.languageCode
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyMedium?.color,
                    ),
                    onTap: () {
                      setState(() => _locale = locale);
                      widget.onLocaleSelected(locale);
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.settingsAppearance, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            l10n.settingsAppearanceHint,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ...RyadomAppTheme.values.map(
            (preset) => _ThemeOptionCard(
              preset: preset,
              selected: preset == _theme,
              onSelect: () {
                setState(() => _theme = preset);
                widget.onThemeSelected(preset);
              },
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.settingsConnectionAndMap, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                if (widget.onOpenRelay != null)
                  ListTile(
                    leading: Icon(
                      Icons.wifi_tethering_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(l10n.settingsNostrRelay),
                    subtitle: Text(l10n.settingsNostrRelayHint),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: widget.onOpenRelay,
                  ),
                if (widget.onOpenRelay != null && widget.onOpenGeo != null)
                  const Divider(height: 1),
                if (widget.onOpenGeo != null)
                  ListTile(
                    leading: Icon(
                      Icons.my_location_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(l10n.settingsGeoRadius),
                    subtitle: Text(l10n.settingsGeoRadiusHint),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: widget.onOpenGeo,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.settingsChat, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            l10n.settingsChatHint,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  const _ThemeOptionCard({
    required this.preset,
    required this.selected,
    required this.onSelect,
  });

  final RyadomAppTheme preset;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = preset.palette;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected
                ? theme.colorScheme.primary
                : RyadomColors.of(context).border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onSelect,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              children: [
                _ThemePreviewStrip(palette: palette),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.themeTitle(preset),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.themeSubtitle(preset),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.textTheme.bodyMedium?.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemePreviewStrip extends StatelessWidget {
  const _ThemePreviewStrip({required this.palette});

  final RyadomPalette palette;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 52,
        height: 52,
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: ColoredBox(color: palette.background),
            ),
            Expanded(
              flex: 3,
              child: ColoredBox(color: palette.surface),
            ),
            SizedBox(
              height: 10,
              child: ColoredBox(color: palette.accent),
            ),
          ],
        ),
      ),
    );
  }
}
