import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/nostr/data/local_nostr_request_store.dart';
import '../features/nostr/data/we_ryadom_nostr_gateway.dart';
import '../l10n/app_localizations.dart';
import '../l10n/ryadom_locale_store.dart';
import '../theme/ryadom_app_theme.dart';
import '../widgets/ryadom_backdrop.dart';
import '../widgets/ryadom_startup_gate.dart';

class _RyadomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class RyadomApp extends StatefulWidget {
  const RyadomApp({
    super.key,
    this.nostrGateway,
    this.requestStore,
    this.initialAppTheme,
    this.initialLocale,
  });

  final WeRyadomNostrGateway? nostrGateway;
  final LocalNostrRequestStore? requestStore;
  final RyadomAppTheme? initialAppTheme;
  final Locale? initialLocale;

  @override
  State<RyadomApp> createState() => _RyadomAppState();
}

class _RyadomAppState extends State<RyadomApp> {
  late RyadomAppTheme _appTheme;
  late bool _themeReady;
  Locale _locale = RyadomLocaleStore.defaultLocale;
  late bool _localeReady;

  @override
  void initState() {
    super.initState();
    if (widget.initialAppTheme != null) {
      _appTheme = widget.initialAppTheme!;
      _themeReady = true;
    } else {
      _appTheme = RyadomAppTheme.cyberpunk;
      _themeReady = false;
      _loadTheme();
    }
    if (widget.initialLocale != null) {
      _locale = widget.initialLocale!;
      _localeReady = true;
    } else {
      _localeReady = false;
      _loadLocale();
    }
  }

  Future<void> _loadTheme() async {
    final saved = await RyadomAppThemeStore.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _appTheme = saved;
      _themeReady = true;
    });
  }

  Future<void> _loadLocale() async {
    final saved = await RyadomLocaleStore.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _locale = saved;
      _localeReady = true;
    });
  }

  Future<void> _setAppTheme(RyadomAppTheme theme) async {
    await RyadomAppThemeStore.save(theme);
    if (!mounted) {
      return;
    }
    setState(() => _appTheme = theme);
  }

  Future<void> _setLocale(Locale locale) async {
    await RyadomLocaleStore.save(locale);
    if (!mounted) {
      return;
    }
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        _themeReady ? _appTheme.themeData : RyadomAppTheme.cyberpunk.themeData;
    final ready = _themeReady && _localeReady;

    return MaterialApp(
      title: 'Мы Рядом',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: RyadomLocaleStore.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      scrollBehavior: _RyadomScrollBehavior(),
      theme: theme,
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }
        return RyadomBackdrop(child: child);
      },
      home: ready
          ? HomeScreen(
              appTheme: _appTheme,
              onAppThemeChanged: _setAppTheme,
              currentLocale: _locale,
              onLocaleChanged: _setLocale,
              nostrGateway: widget.nostrGateway,
              requestStore: widget.requestStore,
            )
          : const RyadomStartupGate(),
    );
  }
}