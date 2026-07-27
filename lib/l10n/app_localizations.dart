import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Мы Рядом'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In ru, this message translates to:
  /// **'Помощь рядом'**
  String get appTagline;

  /// No description provided for @settingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In ru, this message translates to:
  /// **'Оформление'**
  String get settingsAppearance;

  /// No description provided for @settingsAppearanceHint.
  ///
  /// In ru, this message translates to:
  /// **'Тема меняет весь интерфейс: радар, запросы, кнопки и профиль.'**
  String get settingsAppearanceHint;

  /// No description provided for @settingsConnectionAndMap.
  ///
  /// In ru, this message translates to:
  /// **'Связь и карта'**
  String get settingsConnectionAndMap;

  /// No description provided for @settingsNostrRelay.
  ///
  /// In ru, this message translates to:
  /// **'Nostr relay'**
  String get settingsNostrRelay;

  /// No description provided for @settingsNostrRelayHint.
  ///
  /// In ru, this message translates to:
  /// **'Один URL на всех — иначе телефоны не видят друг друга'**
  String get settingsNostrRelayHint;

  /// No description provided for @settingsGeoRadius.
  ///
  /// In ru, this message translates to:
  /// **'Геолокация и радиус'**
  String get settingsGeoRadius;

  /// No description provided for @settingsGeoRadiusHint.
  ///
  /// In ru, this message translates to:
  /// **'Точка на карте и дистанция поиска'**
  String get settingsGeoRadiusHint;

  /// No description provided for @settingsChat.
  ///
  /// In ru, this message translates to:
  /// **'Чат'**
  String get settingsChat;

  /// No description provided for @settingsChatHint.
  ///
  /// In ru, this message translates to:
  /// **'Внутри переписки можно отдельно выбрать палитру (иконка палитры в чате). По умолчанию «Ночная» совпадает с темой приложения.'**
  String get settingsChatHint;

  /// No description provided for @settingsLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageHint.
  ///
  /// In ru, this message translates to:
  /// **'Русский по умолчанию. English — в настройках.'**
  String get settingsLanguageHint;

  /// No description provided for @languageRussian.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @languageEnglish.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @themeClassicTitle.
  ///
  /// In ru, this message translates to:
  /// **'Классическая'**
  String get themeClassicTitle;

  /// No description provided for @themeClassicSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Зелёная, как было раньше'**
  String get themeClassicSubtitle;

  /// No description provided for @themeNightTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ночная'**
  String get themeNightTitle;

  /// No description provided for @themeNightSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Синяя, глубокая'**
  String get themeNightSubtitle;

  /// No description provided for @themeLightTitle.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get themeLightTitle;

  /// No description provided for @themeLightSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Дневная, спокойная'**
  String get themeLightSubtitle;

  /// No description provided for @themeCyberpunkTitle.
  ///
  /// In ru, this message translates to:
  /// **'Киберпанк'**
  String get themeCyberpunkTitle;

  /// No description provided for @themeCyberpunkSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Неон, магента и циан'**
  String get themeCyberpunkSubtitle;

  /// No description provided for @navRadar.
  ///
  /// In ru, this message translates to:
  /// **'Радар'**
  String get navRadar;

  /// No description provided for @navRequests.
  ///
  /// In ru, this message translates to:
  /// **'Запросы'**
  String get navRequests;

  /// No description provided for @navProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get navProfile;

  /// No description provided for @tooltipSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get tooltipSettings;

  /// No description provided for @tooltipNeedHelp.
  ///
  /// In ru, this message translates to:
  /// **'Нужна помощь'**
  String get tooltipNeedHelp;

  /// No description provided for @tooltipDismiss.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть'**
  String get tooltipDismiss;

  /// No description provided for @tooltipCopyNpub.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать npub'**
  String get tooltipCopyNpub;

  /// No description provided for @headerConnection.
  ///
  /// In ru, this message translates to:
  /// **'Связь'**
  String get headerConnection;

  /// No description provided for @headerGeo.
  ///
  /// In ru, this message translates to:
  /// **'Гео'**
  String get headerGeo;

  /// No description provided for @filterAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get filterAll;

  /// No description provided for @filterRequests.
  ///
  /// In ru, this message translates to:
  /// **'Запросы'**
  String get filterRequests;

  /// No description provided for @filterPeople.
  ///
  /// In ru, this message translates to:
  /// **'Люди'**
  String get filterPeople;

  /// No description provided for @filterSignals.
  ///
  /// In ru, this message translates to:
  /// **'Сигналы'**
  String get filterSignals;

  /// No description provided for @relayTipTitle.
  ///
  /// In ru, this message translates to:
  /// **'Два телефона — один relay'**
  String get relayTipTitle;

  /// No description provided for @relayTipBody.
  ///
  /// In ru, this message translates to:
  /// **'На обоих укажи один и тот же relay в Nostr. Тапни сюда, чтобы открыть настройки связи.'**
  String get relayTipBody;

  /// No description provided for @urgencyLow.
  ///
  /// In ru, this message translates to:
  /// **'Спокойно'**
  String get urgencyLow;

  /// No description provided for @urgencyNormal.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get urgencyNormal;

  /// No description provided for @urgencyUrgent.
  ///
  /// In ru, this message translates to:
  /// **'Срочно'**
  String get urgencyUrgent;

  /// No description provided for @compensationFree.
  ///
  /// In ru, this message translates to:
  /// **'Бесплатно'**
  String get compensationFree;

  /// No description provided for @compensationPaid.
  ///
  /// In ru, this message translates to:
  /// **'Платно'**
  String get compensationPaid;

  /// No description provided for @compensationPaidAction.
  ///
  /// In ru, this message translates to:
  /// **'Оплачу'**
  String get compensationPaidAction;

  /// No description provided for @distanceNearby.
  ///
  /// In ru, this message translates to:
  /// **'рядом'**
  String get distanceNearby;

  /// No description provided for @distanceKm.
  ///
  /// In ru, this message translates to:
  /// **'{km} км'**
  String distanceKm(String km);

  /// No description provided for @distanceMeters.
  ///
  /// In ru, this message translates to:
  /// **'{m} м'**
  String distanceMeters(int m);

  /// No description provided for @distanceApproxNearby.
  ///
  /// In ru, this message translates to:
  /// **'~рядом'**
  String get distanceApproxNearby;

  /// No description provided for @distanceApproxMeters.
  ///
  /// In ru, this message translates to:
  /// **'~{m} м'**
  String distanceApproxMeters(int m);

  /// No description provided for @distanceApproxKm.
  ///
  /// In ru, this message translates to:
  /// **'~{km} км'**
  String distanceApproxKm(String km);

  /// No description provided for @cancelRequest.
  ///
  /// In ru, this message translates to:
  /// **'Отменить запрос'**
  String get cancelRequest;

  /// No description provided for @noteRequestCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Запрос отменён'**
  String get noteRequestCancelled;

  /// No description provided for @snackRequestCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Запрос снят с радара'**
  String get snackRequestCancelled;

  /// No description provided for @radiusKmInt.
  ///
  /// In ru, this message translates to:
  /// **'{km} км'**
  String radiusKmInt(int km);

  /// No description provided for @radiusKmDecimal.
  ///
  /// In ru, this message translates to:
  /// **'{km} км'**
  String radiusKmDecimal(String km);

  /// No description provided for @radiusMeters.
  ///
  /// In ru, this message translates to:
  /// **'{m} м'**
  String radiusMeters(int m);

  /// No description provided for @statusCreated.
  ///
  /// In ru, this message translates to:
  /// **'создан'**
  String get statusCreated;

  /// No description provided for @statusVisible.
  ///
  /// In ru, this message translates to:
  /// **'виден'**
  String get statusVisible;

  /// No description provided for @statusAccepted.
  ///
  /// In ru, this message translates to:
  /// **'принят'**
  String get statusAccepted;

  /// No description provided for @statusInProgress.
  ///
  /// In ru, this message translates to:
  /// **'в работе'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In ru, this message translates to:
  /// **'завершён'**
  String get statusCompleted;

  /// No description provided for @statusRated.
  ///
  /// In ru, this message translates to:
  /// **'оценён'**
  String get statusRated;

  /// No description provided for @statusCancelled.
  ///
  /// In ru, this message translates to:
  /// **'отменён'**
  String get statusCancelled;

  /// No description provided for @responseCountChip.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{ждёт отклик} one{{count} отклик} few{{count} отклика} many{{count} откликов} other{{count} откликов}}'**
  String responseCountChip(int count);

  /// No description provided for @radarNearbySummaryEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока рядом тихо — можно создать первый сигнал.'**
  String get radarNearbySummaryEmpty;

  /// No description provided for @radarNearbySummary.
  ///
  /// In ru, this message translates to:
  /// **'{requestCount, plural, one{{requestCount} ситуация} few{{requestCount} ситуации} many{{requestCount} ситуаций} other{{requestCount} ситуаций}} рядом · {responseCount, plural, one{{responseCount} отклик} few{{responseCount} отклика} many{{responseCount} откликов} other{{responseCount} откликов}}'**
  String radarNearbySummary(int requestCount, int responseCount);

  /// No description provided for @relayStateLocalOnly.
  ///
  /// In ru, this message translates to:
  /// **'только здесь'**
  String get relayStateLocalOnly;

  /// No description provided for @relayStateSentToRelay.
  ///
  /// In ru, this message translates to:
  /// **'в relay'**
  String get relayStateSentToRelay;

  /// No description provided for @relayStateSeenFromRelay.
  ///
  /// In ru, this message translates to:
  /// **'с сети'**
  String get relayStateSeenFromRelay;

  /// No description provided for @nostrStatusStarting.
  ///
  /// In ru, this message translates to:
  /// **'Nostr старт'**
  String get nostrStatusStarting;

  /// No description provided for @nostrStatusConnecting.
  ///
  /// In ru, this message translates to:
  /// **'Nostr подключается'**
  String get nostrStatusConnecting;

  /// No description provided for @nostrStatusOnline.
  ///
  /// In ru, this message translates to:
  /// **'Nostr онлайн'**
  String get nostrStatusOnline;

  /// No description provided for @nostrStatusOffline.
  ///
  /// In ru, this message translates to:
  /// **'Nostr офлайн'**
  String get nostrStatusOffline;

  /// No description provided for @nostrStatusTest.
  ///
  /// In ru, this message translates to:
  /// **'Nostr тест'**
  String get nostrStatusTest;

  /// No description provided for @nostrStatusError.
  ///
  /// In ru, this message translates to:
  /// **'Nostr ошибка'**
  String get nostrStatusError;

  /// No description provided for @headerStatusOk.
  ///
  /// In ru, this message translates to:
  /// **'{label} ok'**
  String headerStatusOk(String label);

  /// No description provided for @headerStatusNo.
  ///
  /// In ru, this message translates to:
  /// **'{label} нет'**
  String headerStatusNo(String label);

  /// No description provided for @headerStatusProgress.
  ///
  /// In ru, this message translates to:
  /// **'{label}...'**
  String headerStatusProgress(String label);

  /// No description provided for @headerStatusOff.
  ///
  /// In ru, this message translates to:
  /// **'{label} выкл.'**
  String headerStatusOff(String label);

  /// No description provided for @headerGeoPrecise.
  ///
  /// In ru, this message translates to:
  /// **'Гео точно'**
  String get headerGeoPrecise;

  /// No description provided for @headerGeoStable.
  ///
  /// In ru, this message translates to:
  /// **'Гео стаб.'**
  String get headerGeoStable;

  /// No description provided for @headerGeoApprox.
  ///
  /// In ru, this message translates to:
  /// **'Гео прим.'**
  String get headerGeoApprox;

  /// No description provided for @geoSearching.
  ///
  /// In ru, this message translates to:
  /// **'Ищем точку'**
  String get geoSearching;

  /// No description provided for @geoPrecise.
  ///
  /// In ru, this message translates to:
  /// **'Гео точное'**
  String get geoPrecise;

  /// No description provided for @geoStable.
  ///
  /// In ru, this message translates to:
  /// **'Гео стабильное'**
  String get geoStable;

  /// No description provided for @geoNearby.
  ///
  /// In ru, this message translates to:
  /// **'Гео рядом'**
  String get geoNearby;

  /// No description provided for @geoDisabled.
  ///
  /// In ru, this message translates to:
  /// **'Гео выкл.'**
  String get geoDisabled;

  /// No description provided for @geoCaptured.
  ///
  /// In ru, this message translates to:
  /// **'Точка поймана'**
  String get geoCaptured;

  /// No description provided for @geoAccuracy.
  ///
  /// In ru, this message translates to:
  /// **'точность {m} м'**
  String geoAccuracy(int m);

  /// No description provided for @geoUpdated.
  ///
  /// In ru, this message translates to:
  /// **'обновлено {time}'**
  String geoUpdated(String time);

  /// No description provided for @geoMetaWithoutGeo.
  ///
  /// In ru, this message translates to:
  /// **'Можно продолжать и без гео, но фильтр по расстоянию станет условным.'**
  String get geoMetaWithoutGeo;

  /// No description provided for @geoMetaOptional.
  ///
  /// In ru, this message translates to:
  /// **'Гео опционально, но для живой проверки на двух телефонах лучше включить.'**
  String get geoMetaOptional;

  /// No description provided for @geoDetailsEnabled.
  ///
  /// In ru, this message translates to:
  /// **'Телефон знает твою точку, но наружу мы показываем только приблизительную зону и фильтруем запросы по выбранному радиусу.'**
  String get geoDetailsEnabled;

  /// No description provided for @geoDetailsLoading.
  ///
  /// In ru, this message translates to:
  /// **'Спокойно, телефон сейчас пытается поймать точку и не изображать спутник из фильма.'**
  String get geoDetailsLoading;

  /// No description provided for @geoDetailsError.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас геолокация не готова. Без нее приложение живет, но «рядом» превращается в догадку, а нам нужна уверенность.'**
  String get geoDetailsError;

  /// No description provided for @geoDetailsDefault.
  ///
  /// In ru, this message translates to:
  /// **'Геолокация у нас не для красоты. Она нужна, чтобы радиус и близость вели себя честно.'**
  String get geoDetailsDefault;

  /// No description provided for @geoErrorServiceDisabled.
  ///
  /// In ru, this message translates to:
  /// **'Включи геолокацию на телефоне'**
  String get geoErrorServiceDisabled;

  /// No description provided for @geoErrorPermissionDenied.
  ///
  /// In ru, this message translates to:
  /// **'Геодоступ не выдан'**
  String get geoErrorPermissionDenied;

  /// No description provided for @geoErrorFailed.
  ///
  /// In ru, this message translates to:
  /// **'Геолокация не поймалась'**
  String get geoErrorFailed;

  /// No description provided for @geoTitle.
  ///
  /// In ru, this message translates to:
  /// **'Геолокация'**
  String get geoTitle;

  /// No description provided for @geoRefresh.
  ///
  /// In ru, this message translates to:
  /// **'Обновить точку'**
  String get geoRefresh;

  /// No description provided for @geoEnable.
  ///
  /// In ru, this message translates to:
  /// **'Включить гео'**
  String get geoEnable;

  /// No description provided for @geoDisable.
  ///
  /// In ru, this message translates to:
  /// **'Выключить'**
  String get geoDisable;

  /// No description provided for @geoRadiusButton.
  ///
  /// In ru, this message translates to:
  /// **'Радиус {radius}'**
  String geoRadiusButton(String radius);

  /// No description provided for @geoPublicZone.
  ///
  /// In ru, this message translates to:
  /// **'Публично мы показываем только приблизительную зону: {zone}'**
  String geoPublicZone(String zone);

  /// No description provided for @mapCoordsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Координаты (примерно)'**
  String get mapCoordsTitle;

  /// No description provided for @mapCoordsHint.
  ///
  /// In ru, this message translates to:
  /// **'Это центр зоны, не точный подъезд. Для ориентира на карте.'**
  String get mapCoordsHint;

  /// No description provided for @mapOpenYandex.
  ///
  /// In ru, this message translates to:
  /// **'Яндекс.Карты'**
  String get mapOpenYandex;

  /// No description provided for @mapOpenGoogle.
  ///
  /// In ru, this message translates to:
  /// **'Google Карты'**
  String get mapOpenGoogle;

  /// No description provided for @mapOpenFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть карты'**
  String get mapOpenFailed;

  /// No description provided for @mapCoordsCopied.
  ///
  /// In ru, this message translates to:
  /// **'Координаты скопированы'**
  String get mapCoordsCopied;

  /// No description provided for @radiusPickerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Радиус рядом'**
  String get radiusPickerTitle;

  /// No description provided for @radiusPickerHint.
  ///
  /// In ru, this message translates to:
  /// **'Можно выбрать от 500 м до 10 км. Это опционально и всегда под твоим контролем.'**
  String get radiusPickerHint;

  /// No description provided for @needHelpTitle.
  ///
  /// In ru, this message translates to:
  /// **'Нужна помощь'**
  String get needHelpTitle;

  /// No description provided for @requestCreationIntro.
  ///
  /// In ru, this message translates to:
  /// **'Собери короткий понятный сигнал. Его увидят люди рядом.'**
  String get requestCreationIntro;

  /// No description provided for @requestWhatTitle.
  ///
  /// In ru, this message translates to:
  /// **'Что нужно'**
  String get requestWhatTitle;

  /// No description provided for @requestWhatSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Одна ясная фраза про ситуацию'**
  String get requestWhatSubtitle;

  /// No description provided for @requestWhatHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: Нужно прикурить автомобиль'**
  String get requestWhatHint;

  /// No description provided for @requestContextTitle.
  ///
  /// In ru, this message translates to:
  /// **'Контекст'**
  String get requestContextTitle;

  /// No description provided for @requestContextSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Пара деталей, чтобы было легче откликнуться'**
  String get requestContextSubtitle;

  /// No description provided for @requestContextHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: Машина стоит у торгового центра, нужны провода на 10 минут.'**
  String get requestContextHint;

  /// No description provided for @requestWhenTitle.
  ///
  /// In ru, this message translates to:
  /// **'Когда нужно'**
  String get requestWhenTitle;

  /// No description provided for @requestWhenSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Без лишних календарей в первой версии'**
  String get requestWhenSubtitle;

  /// No description provided for @requestWhenNow.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас'**
  String get requestWhenNow;

  /// No description provided for @requestWhenWithinHour.
  ///
  /// In ru, this message translates to:
  /// **'В течение часа'**
  String get requestWhenWithinHour;

  /// No description provided for @requestWhenToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get requestWhenToday;

  /// No description provided for @requestWhereTitle.
  ///
  /// In ru, this message translates to:
  /// **'Где примерно'**
  String get requestWhereTitle;

  /// No description provided for @requestWhereSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Показываем район, не точную точку'**
  String get requestWhereSubtitle;

  /// No description provided for @requestWhereHint.
  ///
  /// In ru, this message translates to:
  /// **'Район, ориентир или ближайшая улица'**
  String get requestWhereHint;

  /// No description provided for @requestWherePrivacy.
  ///
  /// In ru, this message translates to:
  /// **'Точную точку мы не публикуем. В сеть уйдет только приблизительная зона.'**
  String get requestWherePrivacy;

  /// No description provided for @requestUrgencyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Насколько срочно'**
  String get requestUrgencyTitle;

  /// No description provided for @requestUrgencySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Это поможет показать запрос правильным людям'**
  String get requestUrgencySubtitle;

  /// No description provided for @requestPaymentTitle.
  ///
  /// In ru, this message translates to:
  /// **'Оплата'**
  String get requestPaymentTitle;

  /// No description provided for @requestPaymentSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Можно оставить запрос бесплатным'**
  String get requestPaymentSubtitle;

  /// No description provided for @requestPreviewTitle.
  ///
  /// In ru, this message translates to:
  /// **'Как это увидят рядом'**
  String get requestPreviewTitle;

  /// No description provided for @requestPreviewTitlePlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Нужно прикурить автомобиль'**
  String get requestPreviewTitlePlaceholder;

  /// No description provided for @requestPreviewDescriptionPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Короткое описание появится здесь после ввода.'**
  String get requestPreviewDescriptionPlaceholder;

  /// No description provided for @requestPublish.
  ///
  /// In ru, this message translates to:
  /// **'Опубликовать запрос'**
  String get requestPublish;

  /// No description provided for @requestTitleRequired.
  ///
  /// In ru, this message translates to:
  /// **'Добавь короткую фразу о том, какая помощь нужна.'**
  String get requestTitleRequired;

  /// No description provided for @requestDefaultDescription.
  ///
  /// In ru, this message translates to:
  /// **'Описание можно уточнить после первых откликов.'**
  String get requestDefaultDescription;

  /// No description provided for @requestDefaultArea.
  ///
  /// In ru, this message translates to:
  /// **'Район рядом с тобой'**
  String get requestDefaultArea;

  /// No description provided for @snackPublishedRelay.
  ///
  /// In ru, this message translates to:
  /// **'Запрос ушёл в relay. Теперь ждём второй телефон.'**
  String get snackPublishedRelay;

  /// No description provided for @snackPublishedLocal.
  ///
  /// In ru, this message translates to:
  /// **'Пока запрос живёт только на этом телефоне. Связь с relay ещё не схватилась.'**
  String get snackPublishedLocal;

  /// No description provided for @snackAuthorBlocked.
  ///
  /// In ru, this message translates to:
  /// **'Этот автор скрыт. Отклик недоступен.'**
  String get snackAuthorBlocked;

  /// No description provided for @snackRateLimited.
  ///
  /// In ru, this message translates to:
  /// **'Слишком много откликов за час. Подожди немного (осталось {remaining}).'**
  String snackRateLimited(int remaining);

  /// No description provided for @snackResponseSent.
  ///
  /// In ru, this message translates to:
  /// **'Отклик отправлен. Запрос теперь знает, что ты рядом.'**
  String get snackResponseSent;

  /// No description provided for @snackNewRequestNearby.
  ///
  /// In ru, this message translates to:
  /// **'Новый запрос рядом: {title}'**
  String snackNewRequestNearby(String title);

  /// No description provided for @snackUntitledRequest.
  ///
  /// In ru, this message translates to:
  /// **'без названия'**
  String get snackUntitledRequest;

  /// No description provided for @nostrSettingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Связь между телефонами'**
  String get nostrSettingsTitle;

  /// No description provided for @nostrSettingsHint.
  ///
  /// In ru, this message translates to:
  /// **'Оба телефона должны смотреть в один и тот же relay. Иначе это как две рации на разных частотах: романтично, но бесполезно.'**
  String get nostrSettingsHint;

  /// No description provided for @nostrYourNpub.
  ///
  /// In ru, this message translates to:
  /// **'Твой npub'**
  String get nostrYourNpub;

  /// No description provided for @nostrNpubCopied.
  ///
  /// In ru, this message translates to:
  /// **'npub скопирован'**
  String get nostrNpubCopied;

  /// No description provided for @nostrReconnect.
  ///
  /// In ru, this message translates to:
  /// **'Переподключить'**
  String get nostrReconnect;

  /// No description provided for @snackRelayRefreshed.
  ///
  /// In ru, this message translates to:
  /// **'Обновили ленту с relay'**
  String get snackRelayRefreshed;

  /// No description provided for @snackRelayUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Relay недоступен — проверь URL и сеть'**
  String get snackRelayUnavailable;

  /// No description provided for @activityNearby.
  ///
  /// In ru, this message translates to:
  /// **'Активность рядом'**
  String get activityNearby;

  /// No description provided for @filterActiveRequests.
  ///
  /// In ru, this message translates to:
  /// **'активных запросов'**
  String get filterActiveRequests;

  /// No description provided for @filterNearbyResponses.
  ///
  /// In ru, this message translates to:
  /// **'откликов рядом'**
  String get filterNearbyResponses;

  /// No description provided for @myRequests.
  ///
  /// In ru, this message translates to:
  /// **'Мои запросы'**
  String get myRequests;

  /// No description provided for @myRequestsShort.
  ///
  /// In ru, this message translates to:
  /// **'Мои'**
  String get myRequestsShort;

  /// No description provided for @nearbySection.
  ///
  /// In ru, this message translates to:
  /// **'Рядом'**
  String get nearbySection;

  /// No description provided for @radarFooterHint.
  ///
  /// In ru, this message translates to:
  /// **'Радар — чужие сигналы (точки). Свои запросы в блоке «Мои». Потяни вниз — обновить с relay.'**
  String get radarFooterHint;

  /// No description provided for @requestsTabSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Твои сигналы и то, что видно рядом.'**
  String get requestsTabSubtitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Идентичность Nostr на этом телефоне.'**
  String get profileSubtitle;

  /// No description provided for @profileNostr.
  ///
  /// In ru, this message translates to:
  /// **'Nostr'**
  String get profileNostr;

  /// No description provided for @profileRelay.
  ///
  /// In ru, this message translates to:
  /// **'Relay'**
  String get profileRelay;

  /// No description provided for @profileTheme.
  ///
  /// In ru, this message translates to:
  /// **'Тема: {theme}'**
  String profileTheme(String theme);

  /// No description provided for @aboutBuild.
  ///
  /// In ru, this message translates to:
  /// **'О сборке'**
  String get aboutBuild;

  /// No description provided for @aboutVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия {version}'**
  String aboutVersion(String version);

  /// No description provided for @profileLiveTestTitle.
  ///
  /// In ru, this message translates to:
  /// **'Проверка на двух телефонах'**
  String get profileLiveTestTitle;

  /// No description provided for @profileLiveTestStep1.
  ///
  /// In ru, this message translates to:
  /// **'На обоих — один и тот же relay (Nostr в профиле, статус «онлайн»).'**
  String get profileLiveTestStep1;

  /// No description provided for @profileLiveTestStep2.
  ///
  /// In ru, this message translates to:
  /// **'Включи геолокацию — радар и «рядом» работают честнее.'**
  String get profileLiveTestStep2;

  /// No description provided for @profileLiveTestStep3.
  ///
  /// In ru, this message translates to:
  /// **'На телефоне А: «Нужна помощь» → опубликуй запрос.'**
  String get profileLiveTestStep3;

  /// No description provided for @profileLiveTestStep4.
  ///
  /// In ru, this message translates to:
  /// **'На телефоне Б: вкладка «Запросы» или радар → откликнись.'**
  String get profileLiveTestStep4;

  /// No description provided for @profileLiveTestStep5.
  ///
  /// In ru, this message translates to:
  /// **'Открой чат, договоритесь о встрече. Без предоплаты.'**
  String get profileLiveTestStep5;

  /// No description provided for @aboutBuildNote.
  ///
  /// In ru, this message translates to:
  /// **'Данные на этом телефоне. Чужие запросы приходят с relay, когда связь общая.'**
  String get aboutBuildNote;

  /// No description provided for @filterShowRequests.
  ///
  /// In ru, this message translates to:
  /// **'Фильтр: запросы'**
  String get filterShowRequests;

  /// No description provided for @filterShowAll.
  ///
  /// In ru, this message translates to:
  /// **'Смотреть все'**
  String get filterShowAll;

  /// No description provided for @youResponded.
  ///
  /// In ru, this message translates to:
  /// **'ты откликнулся'**
  String get youResponded;

  /// No description provided for @responseChip.
  ///
  /// In ru, this message translates to:
  /// **'отклик'**
  String get responseChip;

  /// No description provided for @safetyPaid.
  ///
  /// In ru, this message translates to:
  /// **'Не отправляй деньги заранее. Сначала договоритесь в чате и встретьтесь безопасно.'**
  String get safetyPaid;

  /// No description provided for @safetyFree.
  ///
  /// In ru, this message translates to:
  /// **'Держи точный адрес при себе, пока не появится доверие и понятная точка встречи.'**
  String get safetyFree;

  /// No description provided for @rateHelpTitle.
  ///
  /// In ru, this message translates to:
  /// **'Как прошла помощь?'**
  String get rateHelpTitle;

  /// No description provided for @rateStarsTooltip.
  ///
  /// In ru, this message translates to:
  /// **'{stars} из 5'**
  String rateStarsTooltip(int stars);

  /// No description provided for @report.
  ///
  /// In ru, this message translates to:
  /// **'Пожаловаться'**
  String get report;

  /// No description provided for @block.
  ///
  /// In ru, this message translates to:
  /// **'Заблокировать'**
  String get block;

  /// No description provided for @snackReported.
  ///
  /// In ru, this message translates to:
  /// **'Жалоба отмечена. Проверим ситуацию внимательнее.'**
  String get snackReported;

  /// No description provided for @snackBlocked.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь скрыт. Бережем нервы и здравый смысл.'**
  String get snackBlocked;

  /// No description provided for @helpReceived.
  ///
  /// In ru, this message translates to:
  /// **'Помощь получена'**
  String get helpReceived;

  /// No description provided for @openChat.
  ///
  /// In ru, this message translates to:
  /// **'Открыть чат'**
  String get openChat;

  /// No description provided for @respond.
  ///
  /// In ru, this message translates to:
  /// **'Откликнуться'**
  String get respond;

  /// No description provided for @later.
  ///
  /// In ru, this message translates to:
  /// **'Позже'**
  String get later;

  /// No description provided for @emptyMyRequestsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Твоих запросов пока нет'**
  String get emptyMyRequestsTitle;

  /// No description provided for @emptyMyRequestsBody.
  ///
  /// In ru, this message translates to:
  /// **'Создай сигнал — «Нужна помощь» на главной или иконка в шапке.'**
  String get emptyMyRequestsBody;

  /// No description provided for @emptyPeopleTitle.
  ///
  /// In ru, this message translates to:
  /// **'Люди рядом'**
  String get emptyPeopleTitle;

  /// No description provided for @emptyPeopleBody.
  ///
  /// In ru, this message translates to:
  /// **'Слой «Люди» появится, когда подключим профили помощников.'**
  String get emptyPeopleBody;

  /// No description provided for @emptySignalsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сигналы'**
  String get emptySignalsTitle;

  /// No description provided for @emptySignalsBody.
  ///
  /// In ru, this message translates to:
  /// **'Быстрые сигналы добавим позже — сейчас работаем с запросами.'**
  String get emptySignalsBody;

  /// No description provided for @emptyFilterTitle.
  ///
  /// In ru, this message translates to:
  /// **'Нет запросов в фильтре'**
  String get emptyFilterTitle;

  /// No description provided for @emptyFilterBody.
  ///
  /// In ru, this message translates to:
  /// **'Переключи радар на «Все» или создай свой сигнал.'**
  String get emptyFilterBody;

  /// No description provided for @emptyQuietTitle.
  ///
  /// In ru, this message translates to:
  /// **'Рядом тихо'**
  String get emptyQuietTitle;

  /// No description provided for @emptyQuietBody.
  ///
  /// In ru, this message translates to:
  /// **'Создай первый сигнал — кнопка «Нужна помощь» ниже.'**
  String get emptyQuietBody;

  /// No description provided for @waitingResponses.
  ///
  /// In ru, this message translates to:
  /// **'Ждём откликов'**
  String get waitingResponses;

  /// No description provided for @chooseHelper.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать помощника'**
  String get chooseHelper;

  /// No description provided for @snackNoResponses.
  ///
  /// In ru, this message translates to:
  /// **'Откликов пока нет — подожди немного.'**
  String get snackNoResponses;

  /// No description provided for @snackChooseHelper.
  ///
  /// In ru, this message translates to:
  /// **'Выбери помощника, чтобы открыть чат.'**
  String get snackChooseHelper;

  /// No description provided for @snackChatNoRelay.
  ///
  /// In ru, this message translates to:
  /// **'Чат пока не знает, к к какой заявке привязаться в relay.'**
  String get snackChatNoRelay;

  /// No description provided for @chatHelperNearby.
  ///
  /// In ru, this message translates to:
  /// **'Помощник рядом'**
  String get chatHelperNearby;

  /// No description provided for @chatRequestAuthor.
  ///
  /// In ru, this message translates to:
  /// **'Автор запроса'**
  String get chatRequestAuthor;

  /// No description provided for @chatNoResponseYet.
  ///
  /// In ru, this message translates to:
  /// **'Отклик ещё не пришёл'**
  String get chatNoResponseYet;

  /// No description provided for @chatWaitingResponse.
  ///
  /// In ru, this message translates to:
  /// **'Ждём отклик'**
  String get chatWaitingResponse;

  /// No description provided for @chatHasResponse.
  ///
  /// In ru, this message translates to:
  /// **'Есть отклик'**
  String get chatHasResponse;

  /// No description provided for @chatHelpTitle.
  ///
  /// In ru, this message translates to:
  /// **'Чат помощи'**
  String get chatHelpTitle;

  /// No description provided for @chatResponseTitle.
  ///
  /// In ru, this message translates to:
  /// **'Чат отклика'**
  String get chatResponseTitle;

  /// No description provided for @chatNoParticipant.
  ///
  /// In ru, this message translates to:
  /// **'Собеседник ещё не найден'**
  String get chatNoParticipant;

  /// No description provided for @chatReady.
  ///
  /// In ru, this message translates to:
  /// **'Связь готова'**
  String get chatReady;

  /// No description provided for @snackRequestCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Запрос завершён. Можно оценить помощь.'**
  String get snackRequestCompleted;

  /// No description provided for @snackRatingSaved.
  ///
  /// In ru, this message translates to:
  /// **'Спасибо! Оценка {stars} сохранена.'**
  String snackRatingSaved(int stars);

  /// No description provided for @noteHelpReceived.
  ///
  /// In ru, this message translates to:
  /// **'Помощь получена'**
  String get noteHelpReceived;

  /// No description provided for @noteRating.
  ///
  /// In ru, this message translates to:
  /// **'Оценка {stars}'**
  String noteRating(int stars);

  /// No description provided for @radarTitle.
  ///
  /// In ru, this message translates to:
  /// **'Радар'**
  String get radarTitle;

  /// No description provided for @radarRadius.
  ///
  /// In ru, this message translates to:
  /// **'Радиус {radius}'**
  String radarRadius(String radius);

  /// No description provided for @radarHelperNearby.
  ///
  /// In ru, this message translates to:
  /// **'Помощник рядом'**
  String get radarHelperNearby;

  /// No description provided for @radarSignal.
  ///
  /// In ru, this message translates to:
  /// **'Сигнал'**
  String get radarSignal;

  /// No description provided for @radarSoon.
  ///
  /// In ru, this message translates to:
  /// **'скоро'**
  String get radarSoon;

  /// No description provided for @radarLegendMulti.
  ///
  /// In ru, this message translates to:
  /// **'точка — тап, название ниже'**
  String get radarLegendMulti;

  /// No description provided for @radarLegendSingle.
  ///
  /// In ru, this message translates to:
  /// **'запрос рядом'**
  String get radarLegendSingle;

  /// No description provided for @radarLegendUrgent.
  ///
  /// In ru, this message translates to:
  /// **'срочный запрос'**
  String get radarLegendUrgent;

  /// No description provided for @radarLegendZones.
  ///
  /// In ru, this message translates to:
  /// **'кольца — зоны близости'**
  String get radarLegendZones;

  /// No description provided for @helperSelectionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Кто помогает?'**
  String get helperSelectionTitle;

  /// No description provided for @helperSelectionSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'«{title}» — выбери одного помощника для чата.'**
  String helperSelectionSubtitle(String title);

  /// No description provided for @chatPaletteCalmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Спокойная'**
  String get chatPaletteCalmTitle;

  /// No description provided for @chatPaletteNightTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ночная'**
  String get chatPaletteNightTitle;

  /// No description provided for @chatPaletteWarmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Теплая'**
  String get chatPaletteWarmTitle;

  /// No description provided for @chatPaletteCyberpunkTitle.
  ///
  /// In ru, this message translates to:
  /// **'Киберпанк'**
  String get chatPaletteCyberpunkTitle;

  /// No description provided for @chatStartHint.
  ///
  /// In ru, this message translates to:
  /// **'«Я рядом», «Уже иду» — так проще договориться без звонков.'**
  String get chatStartHint;

  /// No description provided for @chatReportReason.
  ///
  /// In ru, this message translates to:
  /// **'Жалоба из чата'**
  String get chatReportReason;

  /// No description provided for @chatMenuTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Меню чата'**
  String get chatMenuTooltip;

  /// No description provided for @chatThemeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Тема чата'**
  String get chatThemeTitle;

  /// No description provided for @chatThemeSheetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Тема чата'**
  String get chatThemeSheetTitle;

  /// No description provided for @chatThemeSheetHint.
  ///
  /// In ru, this message translates to:
  /// **'Выбери настроение разговора. Это только про ощущение, не про функциональность.'**
  String get chatThemeSheetHint;

  /// No description provided for @chatPaletteCalm.
  ///
  /// In ru, this message translates to:
  /// **'Сдержанная и мягкая, для спокойного согласования.'**
  String get chatPaletteCalm;

  /// No description provided for @chatPaletteNight.
  ///
  /// In ru, this message translates to:
  /// **'Глубже и контрастнее, если хочется тишины.'**
  String get chatPaletteNight;

  /// No description provided for @chatPaletteWarm.
  ///
  /// In ru, this message translates to:
  /// **'Чуть теплее по тону, когда нужен живой контакт.'**
  String get chatPaletteWarm;

  /// No description provided for @chatPaletteCyberpunk.
  ///
  /// In ru, this message translates to:
  /// **'Неон и контраст, как на радаре в киберпанке.'**
  String get chatPaletteCyberpunk;

  /// No description provided for @chatNoPrepay.
  ///
  /// In ru, this message translates to:
  /// **'Без предоплаты'**
  String get chatNoPrepay;

  /// No description provided for @chatStartMessage.
  ///
  /// In ru, this message translates to:
  /// **'Начни с короткого сообщения'**
  String get chatStartMessage;

  /// No description provided for @chatLess.
  ///
  /// In ru, this message translates to:
  /// **'Меньше'**
  String get chatLess;

  /// No description provided for @chatMore.
  ///
  /// In ru, this message translates to:
  /// **'Ещё'**
  String get chatMore;

  /// No description provided for @chatSoon.
  ///
  /// In ru, this message translates to:
  /// **'Скоро'**
  String get chatSoon;

  /// No description provided for @chatWaitingPeer.
  ///
  /// In ru, this message translates to:
  /// **'Ждём собеседника…'**
  String get chatWaitingPeer;

  /// No description provided for @chatMessageHint.
  ///
  /// In ru, this message translates to:
  /// **'Сообщение'**
  String get chatMessageHint;

  /// No description provided for @chatToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get chatToday;

  /// No description provided for @chatYou.
  ///
  /// In ru, this message translates to:
  /// **'Ты'**
  String get chatYou;

  /// No description provided for @chatDeliveryOnline.
  ///
  /// In ru, this message translates to:
  /// **'в сети'**
  String get chatDeliveryOnline;

  /// No description provided for @chatDeliverySending.
  ///
  /// In ru, this message translates to:
  /// **'отправляется…'**
  String get chatDeliverySending;

  /// No description provided for @chatDeliveryDelivered.
  ///
  /// In ru, this message translates to:
  /// **'доставлено'**
  String get chatDeliveryDelivered;

  /// No description provided for @chatDeliveryError.
  ///
  /// In ru, this message translates to:
  /// **'ошибка'**
  String get chatDeliveryError;

  /// No description provided for @chatSendFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не ушло. Повторим.'**
  String get chatSendFailed;

  /// No description provided for @chatBlockedSnackbar.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь скрыт. Его запросы и сообщения больше не появятся.'**
  String get chatBlockedSnackbar;

  /// No description provided for @chatReportSaved.
  ///
  /// In ru, this message translates to:
  /// **'Жалоба сохранена на устройстве. Мы посмотрим на этот диалог внимательнее.'**
  String get chatReportSaved;

  /// No description provided for @chatQuickReplyHelper1.
  ///
  /// In ru, this message translates to:
  /// **'Я дома'**
  String get chatQuickReplyHelper1;

  /// No description provided for @chatQuickReplyHelper2.
  ///
  /// In ru, this message translates to:
  /// **'Подхожу к входу'**
  String get chatQuickReplyHelper2;

  /// No description provided for @chatQuickReplyHelper3.
  ///
  /// In ru, this message translates to:
  /// **'Спасибо'**
  String get chatQuickReplyHelper3;

  /// No description provided for @chatQuickReplyHelper4.
  ///
  /// In ru, this message translates to:
  /// **'Немного задержусь'**
  String get chatQuickReplyHelper4;

  /// No description provided for @chatQuickReplyResponder1.
  ///
  /// In ru, this message translates to:
  /// **'Я рядом'**
  String get chatQuickReplyResponder1;

  /// No description provided for @chatQuickReplyResponder2.
  ///
  /// In ru, this message translates to:
  /// **'Уже иду'**
  String get chatQuickReplyResponder2;

  /// No description provided for @chatQuickReplyResponder3.
  ///
  /// In ru, this message translates to:
  /// **'Буду через 5 минут'**
  String get chatQuickReplyResponder3;

  /// No description provided for @chatQuickReplyResponder4.
  ///
  /// In ru, this message translates to:
  /// **'Спасибо'**
  String get chatQuickReplyResponder4;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
