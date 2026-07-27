// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Мы Рядом';

  @override
  String get appTagline => 'Помощь рядом';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsAppearance => 'Оформление';

  @override
  String get settingsAppearanceHint =>
      'Тема меняет весь интерфейс: радар, запросы, кнопки и профиль.';

  @override
  String get settingsConnectionAndMap => 'Связь и карта';

  @override
  String get settingsNostrRelay => 'Nostr relay';

  @override
  String get settingsNostrRelayHint =>
      'Один URL на всех — иначе телефоны не видят друг друга';

  @override
  String get settingsGeoRadius => 'Геолокация и радиус';

  @override
  String get settingsGeoRadiusHint => 'Точка на карте и дистанция поиска';

  @override
  String get settingsChat => 'Чат';

  @override
  String get settingsChatHint =>
      'Внутри переписки можно отдельно выбрать палитру (иконка палитры в чате). По умолчанию «Ночная» совпадает с темой приложения.';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageHint =>
      'Русский по умолчанию. English — в настройках.';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';

  @override
  String get themeClassicTitle => 'Классическая';

  @override
  String get themeClassicSubtitle => 'Зелёная, как было раньше';

  @override
  String get themeNightTitle => 'Ночная';

  @override
  String get themeNightSubtitle => 'Синяя, глубокая';

  @override
  String get themeLightTitle => 'Светлая';

  @override
  String get themeLightSubtitle => 'Дневная, спокойная';

  @override
  String get themeCyberpunkTitle => 'Киберпанк';

  @override
  String get themeCyberpunkSubtitle => 'Неон, магента и циан';

  @override
  String get navRadar => 'Радар';

  @override
  String get navRequests => 'Запросы';

  @override
  String get navProfile => 'Профиль';

  @override
  String get tooltipSettings => 'Настройки';

  @override
  String get tooltipNeedHelp => 'Нужна помощь';

  @override
  String get tooltipDismiss => 'Скрыть';

  @override
  String get tooltipCopyNpub => 'Скопировать npub';

  @override
  String get headerConnection => 'Связь';

  @override
  String get headerGeo => 'Гео';

  @override
  String get filterAll => 'Все';

  @override
  String get filterRequests => 'Запросы';

  @override
  String get filterPeople => 'Люди';

  @override
  String get filterSignals => 'Сигналы';

  @override
  String get relayTipTitle => 'Два телефона — один relay';

  @override
  String get relayTipBody =>
      'На обоих укажи один и тот же relay в Nostr. Тапни сюда, чтобы открыть настройки связи.';

  @override
  String get urgencyLow => 'Спокойно';

  @override
  String get urgencyNormal => 'Сегодня';

  @override
  String get urgencyUrgent => 'Срочно';

  @override
  String get compensationFree => 'Бесплатно';

  @override
  String get compensationPaid => 'Платно';

  @override
  String get compensationPaidAction => 'Оплачу';

  @override
  String get distanceNearby => 'рядом';

  @override
  String distanceKm(String km) {
    return '$km км';
  }

  @override
  String distanceMeters(int m) {
    return '$m м';
  }

  @override
  String get distanceApproxNearby => '~рядом';

  @override
  String distanceApproxMeters(int m) {
    return '~$m м';
  }

  @override
  String distanceApproxKm(String km) {
    return '~$km км';
  }

  @override
  String get cancelRequest => 'Отменить запрос';

  @override
  String get noteRequestCancelled => 'Запрос отменён';

  @override
  String get snackRequestCancelled => 'Запрос снят с радара';

  @override
  String radiusKmInt(int km) {
    return '$km км';
  }

  @override
  String radiusKmDecimal(String km) {
    return '$km км';
  }

  @override
  String radiusMeters(int m) {
    return '$m м';
  }

  @override
  String get statusCreated => 'создан';

  @override
  String get statusVisible => 'виден';

  @override
  String get statusAccepted => 'принят';

  @override
  String get statusInProgress => 'в работе';

  @override
  String get statusCompleted => 'завершён';

  @override
  String get statusRated => 'оценён';

  @override
  String get statusCancelled => 'отменён';

  @override
  String responseCountChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count откликов',
      many: '$count откликов',
      few: '$count отклика',
      one: '$count отклик',
      zero: 'ждёт отклик',
    );
    return '$_temp0';
  }

  @override
  String get radarNearbySummaryEmpty =>
      'Пока рядом тихо — можно создать первый сигнал.';

  @override
  String radarNearbySummary(int requestCount, int responseCount) {
    String _temp0 = intl.Intl.pluralLogic(
      requestCount,
      locale: localeName,
      other: '$requestCount ситуаций',
      many: '$requestCount ситуаций',
      few: '$requestCount ситуации',
      one: '$requestCount ситуация',
    );
    String _temp1 = intl.Intl.pluralLogic(
      responseCount,
      locale: localeName,
      other: '$responseCount откликов',
      many: '$responseCount откликов',
      few: '$responseCount отклика',
      one: '$responseCount отклик',
    );
    return '$_temp0 рядом · $_temp1';
  }

  @override
  String get relayStateLocalOnly => 'только здесь';

  @override
  String get relayStateSentToRelay => 'в relay';

  @override
  String get relayStateSeenFromRelay => 'с сети';

  @override
  String get nostrStatusStarting => 'Nostr старт';

  @override
  String get nostrStatusConnecting => 'Nostr подключается';

  @override
  String get nostrStatusOnline => 'Nostr онлайн';

  @override
  String get nostrStatusOffline => 'Nostr офлайн';

  @override
  String get nostrStatusTest => 'Nostr тест';

  @override
  String get nostrStatusError => 'Nostr ошибка';

  @override
  String headerStatusOk(String label) {
    return '$label ok';
  }

  @override
  String headerStatusNo(String label) {
    return '$label нет';
  }

  @override
  String headerStatusProgress(String label) {
    return '$label...';
  }

  @override
  String headerStatusOff(String label) {
    return '$label выкл.';
  }

  @override
  String get headerGeoPrecise => 'Гео точно';

  @override
  String get headerGeoStable => 'Гео стаб.';

  @override
  String get headerGeoApprox => 'Гео прим.';

  @override
  String get geoSearching => 'Ищем точку';

  @override
  String get geoPrecise => 'Гео точное';

  @override
  String get geoStable => 'Гео стабильное';

  @override
  String get geoNearby => 'Гео рядом';

  @override
  String get geoDisabled => 'Гео выкл.';

  @override
  String get geoCaptured => 'Точка поймана';

  @override
  String geoAccuracy(int m) {
    return 'точность $m м';
  }

  @override
  String geoUpdated(String time) {
    return 'обновлено $time';
  }

  @override
  String get geoMetaWithoutGeo =>
      'Можно продолжать и без гео, но фильтр по расстоянию станет условным.';

  @override
  String get geoMetaOptional =>
      'Гео опционально, но для живой проверки на двух телефонах лучше включить.';

  @override
  String get geoDetailsEnabled =>
      'Телефон знает твою точку, но наружу мы показываем только приблизительную зону и фильтруем запросы по выбранному радиусу.';

  @override
  String get geoDetailsLoading =>
      'Спокойно, телефон сейчас пытается поймать точку и не изображать спутник из фильма.';

  @override
  String get geoDetailsError =>
      'Сейчас геолокация не готова. Без нее приложение живет, но «рядом» превращается в догадку, а нам нужна уверенность.';

  @override
  String get geoDetailsDefault =>
      'Геолокация у нас не для красоты. Она нужна, чтобы радиус и близость вели себя честно.';

  @override
  String get geoErrorServiceDisabled => 'Включи геолокацию на телефоне';

  @override
  String get geoErrorPermissionDenied => 'Геодоступ не выдан';

  @override
  String get geoErrorFailed => 'Геолокация не поймалась';

  @override
  String get geoTitle => 'Геолокация';

  @override
  String get geoRefresh => 'Обновить точку';

  @override
  String get geoEnable => 'Включить гео';

  @override
  String get geoDisable => 'Выключить';

  @override
  String geoRadiusButton(String radius) {
    return 'Радиус $radius';
  }

  @override
  String geoPublicZone(String zone) {
    return 'Публично мы показываем только приблизительную зону: $zone';
  }

  @override
  String get mapCoordsTitle => 'Координаты (примерно)';

  @override
  String get mapCoordsHint =>
      'Это центр зоны, не точный подъезд. Для ориентира на карте.';

  @override
  String get mapOpenYandex => 'Яндекс.Карты';

  @override
  String get mapOpenGoogle => 'Google Карты';

  @override
  String get mapOpenFailed => 'Не удалось открыть карты';

  @override
  String get mapCoordsCopied => 'Координаты скопированы';

  @override
  String get radiusPickerTitle => 'Радиус рядом';

  @override
  String get radiusPickerHint =>
      'Можно выбрать от 500 м до 10 км. Это опционально и всегда под твоим контролем.';

  @override
  String get needHelpTitle => 'Нужна помощь';

  @override
  String get requestCreationIntro =>
      'Собери короткий понятный сигнал. Его увидят люди рядом.';

  @override
  String get requestWhatTitle => 'Что нужно';

  @override
  String get requestWhatSubtitle => 'Одна ясная фраза про ситуацию';

  @override
  String get requestWhatHint => 'Например: Нужно прикурить автомобиль';

  @override
  String get requestContextTitle => 'Контекст';

  @override
  String get requestContextSubtitle =>
      'Пара деталей, чтобы было легче откликнуться';

  @override
  String get requestContextHint =>
      'Например: Машина стоит у торгового центра, нужны провода на 10 минут.';

  @override
  String get requestWhenTitle => 'Когда нужно';

  @override
  String get requestWhenSubtitle => 'Без лишних календарей в первой версии';

  @override
  String get requestWhenNow => 'Сейчас';

  @override
  String get requestWhenWithinHour => 'В течение часа';

  @override
  String get requestWhenToday => 'Сегодня';

  @override
  String get requestWhereTitle => 'Где примерно';

  @override
  String get requestWhereSubtitle => 'Показываем район, не точную точку';

  @override
  String get requestWhereHint => 'Район, ориентир или ближайшая улица';

  @override
  String get requestWherePrivacy =>
      'Точную точку мы не публикуем. В сеть уйдет только приблизительная зона.';

  @override
  String get requestUrgencyTitle => 'Насколько срочно';

  @override
  String get requestUrgencySubtitle =>
      'Это поможет показать запрос правильным людям';

  @override
  String get requestPaymentTitle => 'Оплата';

  @override
  String get requestPaymentSubtitle => 'Можно оставить запрос бесплатным';

  @override
  String get requestPreviewTitle => 'Как это увидят рядом';

  @override
  String get requestPreviewTitlePlaceholder => 'Нужно прикурить автомобиль';

  @override
  String get requestPreviewDescriptionPlaceholder =>
      'Короткое описание появится здесь после ввода.';

  @override
  String get requestPublish => 'Опубликовать запрос';

  @override
  String get requestTitleRequired =>
      'Добавь короткую фразу о том, какая помощь нужна.';

  @override
  String get requestDefaultDescription =>
      'Описание можно уточнить после первых откликов.';

  @override
  String get requestDefaultArea => 'Район рядом с тобой';

  @override
  String get snackPublishedRelay =>
      'Запрос ушёл в relay. Теперь ждём второй телефон.';

  @override
  String get snackPublishedLocal =>
      'Пока запрос живёт только на этом телефоне. Связь с relay ещё не схватилась.';

  @override
  String get snackAuthorBlocked => 'Этот автор скрыт. Отклик недоступен.';

  @override
  String snackRateLimited(int remaining) {
    return 'Слишком много откликов за час. Подожди немного (осталось $remaining).';
  }

  @override
  String get snackResponseSent =>
      'Отклик отправлен. Запрос теперь знает, что ты рядом.';

  @override
  String snackNewRequestNearby(String title) {
    return 'Новый запрос рядом: $title';
  }

  @override
  String get snackUntitledRequest => 'без названия';

  @override
  String get nostrSettingsTitle => 'Связь между телефонами';

  @override
  String get nostrSettingsHint =>
      'Оба телефона должны смотреть в один и тот же relay. Иначе это как две рации на разных частотах: романтично, но бесполезно.';

  @override
  String get nostrYourNpub => 'Твой npub';

  @override
  String get nostrNpubCopied => 'npub скопирован';

  @override
  String get nostrReconnect => 'Переподключить';

  @override
  String get snackRelayRefreshed => 'Обновили ленту с relay';

  @override
  String get snackRelayUnavailable => 'Relay недоступен — проверь URL и сеть';

  @override
  String get activityNearby => 'Активность рядом';

  @override
  String get filterActiveRequests => 'активных запросов';

  @override
  String get filterNearbyResponses => 'откликов рядом';

  @override
  String get myRequests => 'Мои запросы';

  @override
  String get myRequestsShort => 'Мои';

  @override
  String get nearbySection => 'Рядом';

  @override
  String get radarFooterHint =>
      'Радар — чужие сигналы (точки). Свои запросы в блоке «Мои». Потяни вниз — обновить с relay.';

  @override
  String get requestsTabSubtitle => 'Твои сигналы и то, что видно рядом.';

  @override
  String get profileSubtitle => 'Идентичность Nostr на этом телефоне.';

  @override
  String get profileNostr => 'Nostr';

  @override
  String get profileRelay => 'Relay';

  @override
  String profileTheme(String theme) {
    return 'Тема: $theme';
  }

  @override
  String get aboutBuild => 'О сборке';

  @override
  String aboutVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get profileLiveTestTitle => 'Проверка на двух телефонах';

  @override
  String get profileLiveTestStep1 =>
      'На обоих — один и тот же relay (Nostr в профиле, статус «онлайн»).';

  @override
  String get profileLiveTestStep2 =>
      'Включи геолокацию — радар и «рядом» работают честнее.';

  @override
  String get profileLiveTestStep3 =>
      'На телефоне А: «Нужна помощь» → опубликуй запрос.';

  @override
  String get profileLiveTestStep4 =>
      'На телефоне Б: вкладка «Запросы» или радар → откликнись.';

  @override
  String get profileLiveTestStep5 =>
      'Открой чат, договоритесь о встрече. Без предоплаты.';

  @override
  String get aboutBuildNote =>
      'Данные на этом телефоне. Чужие запросы приходят с relay, когда связь общая.';

  @override
  String get filterShowRequests => 'Фильтр: запросы';

  @override
  String get filterShowAll => 'Смотреть все';

  @override
  String get youResponded => 'ты откликнулся';

  @override
  String get responseChip => 'отклик';

  @override
  String get safetyPaid =>
      'Не отправляй деньги заранее. Сначала договоритесь в чате и встретьтесь безопасно.';

  @override
  String get safetyFree =>
      'Держи точный адрес при себе, пока не появится доверие и понятная точка встречи.';

  @override
  String get rateHelpTitle => 'Как прошла помощь?';

  @override
  String rateStarsTooltip(int stars) {
    return '$stars из 5';
  }

  @override
  String get report => 'Пожаловаться';

  @override
  String get block => 'Заблокировать';

  @override
  String get snackReported =>
      'Жалоба отмечена. Проверим ситуацию внимательнее.';

  @override
  String get snackBlocked =>
      'Пользователь скрыт. Бережем нервы и здравый смысл.';

  @override
  String get helpReceived => 'Помощь получена';

  @override
  String get openChat => 'Открыть чат';

  @override
  String get respond => 'Откликнуться';

  @override
  String get later => 'Позже';

  @override
  String get emptyMyRequestsTitle => 'Твоих запросов пока нет';

  @override
  String get emptyMyRequestsBody =>
      'Создай сигнал — «Нужна помощь» на главной или иконка в шапке.';

  @override
  String get emptyPeopleTitle => 'Люди рядом';

  @override
  String get emptyPeopleBody =>
      'Слой «Люди» появится, когда подключим профили помощников.';

  @override
  String get emptySignalsTitle => 'Сигналы';

  @override
  String get emptySignalsBody =>
      'Быстрые сигналы добавим позже — сейчас работаем с запросами.';

  @override
  String get emptyFilterTitle => 'Нет запросов в фильтре';

  @override
  String get emptyFilterBody =>
      'Переключи радар на «Все» или создай свой сигнал.';

  @override
  String get emptyQuietTitle => 'Рядом тихо';

  @override
  String get emptyQuietBody =>
      'Создай первый сигнал — кнопка «Нужна помощь» ниже.';

  @override
  String get waitingResponses => 'Ждём откликов';

  @override
  String get chooseHelper => 'Выбрать помощника';

  @override
  String get snackNoResponses => 'Откликов пока нет — подожди немного.';

  @override
  String get snackChooseHelper => 'Выбери помощника, чтобы открыть чат.';

  @override
  String get snackChatNoRelay =>
      'Чат пока не знает, к к какой заявке привязаться в relay.';

  @override
  String get chatHelperNearby => 'Помощник рядом';

  @override
  String get chatRequestAuthor => 'Автор запроса';

  @override
  String get chatNoResponseYet => 'Отклик ещё не пришёл';

  @override
  String get chatWaitingResponse => 'Ждём отклик';

  @override
  String get chatHasResponse => 'Есть отклик';

  @override
  String get chatHelpTitle => 'Чат помощи';

  @override
  String get chatResponseTitle => 'Чат отклика';

  @override
  String get chatNoParticipant => 'Собеседник ещё не найден';

  @override
  String get chatReady => 'Связь готова';

  @override
  String get snackRequestCompleted => 'Запрос завершён. Можно оценить помощь.';

  @override
  String snackRatingSaved(int stars) {
    return 'Спасибо! Оценка $stars сохранена.';
  }

  @override
  String get noteHelpReceived => 'Помощь получена';

  @override
  String noteRating(int stars) {
    return 'Оценка $stars';
  }

  @override
  String get radarTitle => 'Радар';

  @override
  String radarRadius(String radius) {
    return 'Радиус $radius';
  }

  @override
  String get radarHelperNearby => 'Помощник рядом';

  @override
  String get radarSignal => 'Сигнал';

  @override
  String get radarSoon => 'скоро';

  @override
  String get radarLegendMulti => 'точка — тап, название ниже';

  @override
  String get radarLegendSingle => 'запрос рядом';

  @override
  String get radarLegendUrgent => 'срочный запрос';

  @override
  String get radarLegendZones => 'кольца — зоны близости';

  @override
  String get helperSelectionTitle => 'Кто помогает?';

  @override
  String helperSelectionSubtitle(String title) {
    return '«$title» — выбери одного помощника для чата.';
  }

  @override
  String get chatPaletteCalmTitle => 'Спокойная';

  @override
  String get chatPaletteNightTitle => 'Ночная';

  @override
  String get chatPaletteWarmTitle => 'Теплая';

  @override
  String get chatPaletteCyberpunkTitle => 'Киберпанк';

  @override
  String get chatStartHint =>
      '«Я рядом», «Уже иду» — так проще договориться без звонков.';

  @override
  String get chatReportReason => 'Жалоба из чата';

  @override
  String get chatMenuTooltip => 'Меню чата';

  @override
  String get chatThemeTitle => 'Тема чата';

  @override
  String get chatThemeSheetTitle => 'Тема чата';

  @override
  String get chatThemeSheetHint =>
      'Выбери настроение разговора. Это только про ощущение, не про функциональность.';

  @override
  String get chatPaletteCalm =>
      'Сдержанная и мягкая, для спокойного согласования.';

  @override
  String get chatPaletteNight => 'Глубже и контрастнее, если хочется тишины.';

  @override
  String get chatPaletteWarm =>
      'Чуть теплее по тону, когда нужен живой контакт.';

  @override
  String get chatPaletteCyberpunk =>
      'Неон и контраст, как на радаре в киберпанке.';

  @override
  String get chatNoPrepay => 'Без предоплаты';

  @override
  String get chatStartMessage => 'Начни с короткого сообщения';

  @override
  String get chatLess => 'Меньше';

  @override
  String get chatMore => 'Ещё';

  @override
  String get chatSoon => 'Скоро';

  @override
  String get chatWaitingPeer => 'Ждём собеседника…';

  @override
  String get chatMessageHint => 'Сообщение';

  @override
  String get chatToday => 'Сегодня';

  @override
  String get chatYou => 'Ты';

  @override
  String get chatDeliveryOnline => 'в сети';

  @override
  String get chatDeliverySending => 'отправляется…';

  @override
  String get chatDeliveryDelivered => 'доставлено';

  @override
  String get chatDeliveryError => 'ошибка';

  @override
  String get chatSendFailed => 'Не ушло. Повторим.';

  @override
  String get chatBlockedSnackbar =>
      'Пользователь скрыт. Его запросы и сообщения больше не появятся.';

  @override
  String get chatReportSaved =>
      'Жалоба сохранена на устройстве. Мы посмотрим на этот диалог внимательнее.';

  @override
  String get chatQuickReplyHelper1 => 'Я дома';

  @override
  String get chatQuickReplyHelper2 => 'Подхожу к входу';

  @override
  String get chatQuickReplyHelper3 => 'Спасибо';

  @override
  String get chatQuickReplyHelper4 => 'Немного задержусь';

  @override
  String get chatQuickReplyResponder1 => 'Я рядом';

  @override
  String get chatQuickReplyResponder2 => 'Уже иду';

  @override
  String get chatQuickReplyResponder3 => 'Буду через 5 минут';

  @override
  String get chatQuickReplyResponder4 => 'Спасибо';
}
