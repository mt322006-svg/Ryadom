// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'We\'re Nearby';

  @override
  String get appTagline => 'Help nearby';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAppearanceHint =>
      'Theme changes the whole interface: radar, requests, buttons, and profile.';

  @override
  String get settingsConnectionAndMap => 'Connection & map';

  @override
  String get settingsNostrRelay => 'Nostr relay';

  @override
  String get settingsNostrRelayHint =>
      'One URL for everyone — otherwise phones won\'t see each other';

  @override
  String get settingsGeoRadius => 'Location & radius';

  @override
  String get settingsGeoRadiusHint => 'Map point and search distance';

  @override
  String get settingsChat => 'Chat';

  @override
  String get settingsChatHint =>
      'Inside a conversation you can pick a separate palette (palette icon in chat). By default, Night matches the app theme.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageHint =>
      'Russian is the default. Switch to English here.';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';

  @override
  String get themeClassicTitle => 'Classic';

  @override
  String get themeClassicSubtitle => 'Green, like before';

  @override
  String get themeNightTitle => 'Night';

  @override
  String get themeNightSubtitle => 'Deep blue';

  @override
  String get themeLightTitle => 'Light';

  @override
  String get themeLightSubtitle => 'Calm daytime';

  @override
  String get themeCyberpunkTitle => 'Cyberpunk';

  @override
  String get themeCyberpunkSubtitle => 'Neon magenta and cyan';

  @override
  String get navRadar => 'Radar';

  @override
  String get navRequests => 'Requests';

  @override
  String get navProfile => 'Profile';

  @override
  String get tooltipSettings => 'Settings';

  @override
  String get tooltipNeedHelp => 'Need help';

  @override
  String get tooltipDismiss => 'Dismiss';

  @override
  String get tooltipCopyNpub => 'Copy npub';

  @override
  String get headerConnection => 'Link';

  @override
  String get headerGeo => 'Geo';

  @override
  String get filterAll => 'All';

  @override
  String get filterRequests => 'Requests';

  @override
  String get filterPeople => 'People';

  @override
  String get filterSignals => 'Signals';

  @override
  String get relayTipTitle => 'Two phones — one relay';

  @override
  String get relayTipBody =>
      'Set the same relay on both phones in Nostr. Tap here to open connection settings.';

  @override
  String get urgencyLow => 'Relaxed';

  @override
  String get urgencyNormal => 'Today';

  @override
  String get urgencyUrgent => 'Urgent';

  @override
  String get compensationFree => 'Free';

  @override
  String get compensationPaid => 'Paid';

  @override
  String get compensationPaidAction => 'I\'ll pay';

  @override
  String get distanceNearby => 'nearby';

  @override
  String distanceKm(String km) {
    return '$km km';
  }

  @override
  String distanceMeters(int m) {
    return '$m m';
  }

  @override
  String get distanceApproxNearby => '~nearby';

  @override
  String distanceApproxMeters(int m) {
    return '~$m m';
  }

  @override
  String distanceApproxKm(String km) {
    return '~$km km';
  }

  @override
  String get cancelRequest => 'Cancel request';

  @override
  String get noteRequestCancelled => 'Request cancelled';

  @override
  String get snackRequestCancelled => 'Request removed from radar';

  @override
  String radiusKmInt(int km) {
    return '$km km';
  }

  @override
  String radiusKmDecimal(String km) {
    return '$km km';
  }

  @override
  String radiusMeters(int m) {
    return '$m m';
  }

  @override
  String get statusCreated => 'created';

  @override
  String get statusVisible => 'visible';

  @override
  String get statusAccepted => 'accepted';

  @override
  String get statusInProgress => 'in progress';

  @override
  String get statusCompleted => 'completed';

  @override
  String get statusRated => 'rated';

  @override
  String get statusCancelled => 'cancelled';

  @override
  String responseCountChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count responses',
      one: '$count response',
      zero: 'waiting for response',
    );
    return '$_temp0';
  }

  @override
  String get radarNearbySummaryEmpty =>
      'It\'s quiet nearby — you can create the first signal.';

  @override
  String radarNearbySummary(int requestCount, int responseCount) {
    String _temp0 = intl.Intl.pluralLogic(
      requestCount,
      locale: localeName,
      other: '$requestCount situations',
      one: '$requestCount situation',
    );
    String _temp1 = intl.Intl.pluralLogic(
      responseCount,
      locale: localeName,
      other: '$responseCount responses',
      one: '$responseCount response',
    );
    return '$_temp0 nearby · $_temp1';
  }

  @override
  String get relayStateLocalOnly => 'local only';

  @override
  String get relayStateSentToRelay => 'on relay';

  @override
  String get relayStateSeenFromRelay => 'from network';

  @override
  String get nostrStatusStarting => 'Nostr starting';

  @override
  String get nostrStatusConnecting => 'Nostr connecting';

  @override
  String get nostrStatusOnline => 'Nostr online';

  @override
  String get nostrStatusOffline => 'Nostr offline';

  @override
  String get nostrStatusTest => 'Nostr test';

  @override
  String get nostrStatusError => 'Nostr error';

  @override
  String headerStatusOk(String label) {
    return '$label ok';
  }

  @override
  String headerStatusNo(String label) {
    return '$label no';
  }

  @override
  String headerStatusProgress(String label) {
    return '$label...';
  }

  @override
  String headerStatusOff(String label) {
    return '$label off';
  }

  @override
  String get headerGeoPrecise => 'Geo precise';

  @override
  String get headerGeoStable => 'Geo stable';

  @override
  String get headerGeoApprox => 'Geo approx.';

  @override
  String get geoSearching => 'Finding location';

  @override
  String get geoPrecise => 'Precise geo';

  @override
  String get geoStable => 'Stable geo';

  @override
  String get geoNearby => 'Geo nearby';

  @override
  String get geoDisabled => 'Geo off';

  @override
  String get geoCaptured => 'Location captured';

  @override
  String geoAccuracy(int m) {
    return 'accuracy $m m';
  }

  @override
  String geoUpdated(String time) {
    return 'updated $time';
  }

  @override
  String get geoMetaWithoutGeo =>
      'You can continue without geo, but distance filtering becomes approximate.';

  @override
  String get geoMetaOptional =>
      'Geo is optional, but for live two-phone testing it\'s better to enable it.';

  @override
  String get geoDetailsEnabled =>
      'Your phone knows your point, but we only show an approximate zone publicly and filter requests by the selected radius.';

  @override
  String get geoDetailsLoading =>
      'Relax — your phone is trying to get a fix without pretending to be a movie satellite.';

  @override
  String get geoDetailsError =>
      'Location isn\'t ready. The app works without it, but \"nearby\" becomes a guess — we need confidence.';

  @override
  String get geoDetailsDefault =>
      'We don\'t use location for show. It keeps radius and proximity honest.';

  @override
  String get geoErrorServiceDisabled => 'Enable location on your phone';

  @override
  String get geoErrorPermissionDenied => 'Location permission denied';

  @override
  String get geoErrorFailed => 'Couldn\'t get location';

  @override
  String get geoTitle => 'Location';

  @override
  String get geoRefresh => 'Refresh location';

  @override
  String get geoEnable => 'Enable geo';

  @override
  String get geoDisable => 'Turn off';

  @override
  String geoRadiusButton(String radius) {
    return 'Radius $radius';
  }

  @override
  String geoPublicZone(String zone) {
    return 'Publicly we only show an approximate zone: $zone';
  }

  @override
  String get mapCoordsTitle => 'Coordinates (approx.)';

  @override
  String get mapCoordsHint =>
      'Zone center, not an exact pin. For map orientation.';

  @override
  String get mapOpenYandex => 'Yandex Maps';

  @override
  String get mapOpenGoogle => 'Google Maps';

  @override
  String get mapOpenFailed => 'Couldn\'t open maps';

  @override
  String get mapCoordsCopied => 'Coordinates copied';

  @override
  String get radiusPickerTitle => 'Nearby radius';

  @override
  String get radiusPickerHint =>
      'Choose from 500 m to 10 km. Optional and always under your control.';

  @override
  String get needHelpTitle => 'Need help';

  @override
  String get requestCreationIntro =>
      'Build a short clear signal. People nearby will see it.';

  @override
  String get requestWhatTitle => 'What\'s needed';

  @override
  String get requestWhatSubtitle => 'One clear phrase about the situation';

  @override
  String get requestWhatHint => 'For example: Need a jump start for my car';

  @override
  String get requestContextTitle => 'Context';

  @override
  String get requestContextSubtitle =>
      'A few details to make it easier to respond';

  @override
  String get requestContextHint =>
      'For example: Car is at the mall, need jumper cables for 10 minutes.';

  @override
  String get requestWhenTitle => 'When needed';

  @override
  String get requestWhenSubtitle => 'No extra calendars in the first version';

  @override
  String get requestWhenNow => 'Now';

  @override
  String get requestWhenWithinHour => 'Within an hour';

  @override
  String get requestWhenToday => 'Today';

  @override
  String get requestWhereTitle => 'Roughly where';

  @override
  String get requestWhereSubtitle => 'We show the area, not the exact point';

  @override
  String get requestWhereHint => 'Area, landmark, or nearest street';

  @override
  String get requestWherePrivacy =>
      'We don\'t publish the exact point. Only an approximate zone goes to the network.';

  @override
  String get requestUrgencyTitle => 'How urgent';

  @override
  String get requestUrgencySubtitle =>
      'Helps show the request to the right people';

  @override
  String get requestPaymentTitle => 'Payment';

  @override
  String get requestPaymentSubtitle => 'You can keep the request free';

  @override
  String get requestPreviewTitle => 'How it will look nearby';

  @override
  String get requestPreviewTitlePlaceholder => 'Need a jump start for my car';

  @override
  String get requestPreviewDescriptionPlaceholder =>
      'A short description will appear here after you type.';

  @override
  String get requestPublish => 'Publish request';

  @override
  String get requestTitleRequired =>
      'Add a short phrase about what help is needed.';

  @override
  String get requestDefaultDescription =>
      'You can clarify the description after the first responses.';

  @override
  String get requestDefaultArea => 'Area near you';

  @override
  String get snackPublishedRelay =>
      'Request sent to relay. Now we wait for the second phone.';

  @override
  String get snackPublishedLocal =>
      'For now the request lives only on this phone. Relay connection hasn\'t caught yet.';

  @override
  String get snackAuthorBlocked => 'This author is hidden. You can\'t respond.';

  @override
  String snackRateLimited(int remaining) {
    return 'Too many responses this hour. Wait a bit (remaining $remaining).';
  }

  @override
  String get snackResponseSent =>
      'Response sent. The request now knows you\'re nearby.';

  @override
  String snackNewRequestNearby(String title) {
    return 'New request nearby: $title';
  }

  @override
  String get snackUntitledRequest => 'untitled';

  @override
  String get nostrSettingsTitle => 'Connection between phones';

  @override
  String get nostrSettingsHint =>
      'Both phones must use the same relay. Otherwise it\'s like two radios on different frequencies: romantic, but useless.';

  @override
  String get nostrYourNpub => 'Your npub';

  @override
  String get nostrNpubCopied => 'npub copied';

  @override
  String get nostrReconnect => 'Reconnect';

  @override
  String get snackRelayRefreshed => 'Refreshed feed from relay';

  @override
  String get snackRelayUnavailable =>
      'Relay unavailable — check URL and network';

  @override
  String get activityNearby => 'Activity nearby';

  @override
  String get filterActiveRequests => 'active requests';

  @override
  String get filterNearbyResponses => 'responses nearby';

  @override
  String get myRequests => 'My requests';

  @override
  String get myRequestsShort => 'Mine';

  @override
  String get nearbySection => 'Nearby';

  @override
  String get radarFooterHint =>
      'Radar — other people\'s signals (dots). Your requests are in \"Mine\". Pull down to refresh from relay.';

  @override
  String get requestsTabSubtitle => 'Your signals and what\'s visible nearby.';

  @override
  String get profileSubtitle => 'Nostr identity on this phone.';

  @override
  String get profileNostr => 'Nostr';

  @override
  String get profileRelay => 'Relay';

  @override
  String profileTheme(String theme) {
    return 'Theme: $theme';
  }

  @override
  String get aboutBuild => 'About this build';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get profileLiveTestTitle => 'Two-phone check';

  @override
  String get profileLiveTestStep1 =>
      'Same relay on both phones (Nostr in profile, status online).';

  @override
  String get profileLiveTestStep2 =>
      'Enable location — radar and \"nearby\" work more honestly.';

  @override
  String get profileLiveTestStep3 =>
      'On phone A: Need help → publish a request.';

  @override
  String get profileLiveTestStep4 =>
      'On phone B: Requests tab or radar → respond.';

  @override
  String get profileLiveTestStep5 =>
      'Open chat and agree on a meetup. No prepayment.';

  @override
  String get aboutBuildNote =>
      'Data on this phone. Others\' requests arrive via relay when connection is shared.';

  @override
  String get filterShowRequests => 'Filter: requests';

  @override
  String get filterShowAll => 'View all';

  @override
  String get youResponded => 'you responded';

  @override
  String get responseChip => 'response';

  @override
  String get safetyPaid =>
      'Don\'t send money upfront. Agree in chat first and meet safely.';

  @override
  String get safetyFree =>
      'Keep the exact address private until there\'s trust and a clear meeting point.';

  @override
  String get rateHelpTitle => 'How did the help go?';

  @override
  String rateStarsTooltip(int stars) {
    return '$stars of 5';
  }

  @override
  String get report => 'Report';

  @override
  String get block => 'Block';

  @override
  String get snackReported =>
      'Report noted. We\'ll look into this more carefully.';

  @override
  String get snackBlocked => 'User hidden. Protecting nerves and common sense.';

  @override
  String get helpReceived => 'Help received';

  @override
  String get openChat => 'Open chat';

  @override
  String get respond => 'Respond';

  @override
  String get later => 'Later';

  @override
  String get emptyMyRequestsTitle => 'No requests yet';

  @override
  String get emptyMyRequestsBody =>
      'Create a signal — \"Need help\" on the home screen or the header icon.';

  @override
  String get emptyPeopleTitle => 'People nearby';

  @override
  String get emptyPeopleBody =>
      'The People layer will appear when we connect helper profiles.';

  @override
  String get emptySignalsTitle => 'Signals';

  @override
  String get emptySignalsBody =>
      'Quick signals coming later — we\'re working with requests for now.';

  @override
  String get emptyFilterTitle => 'No requests in filter';

  @override
  String get emptyFilterBody =>
      'Switch radar to \"All\" or create your own signal.';

  @override
  String get emptyQuietTitle => 'Quiet nearby';

  @override
  String get emptyQuietBody =>
      'Create the first signal — \"Need help\" button below.';

  @override
  String get waitingResponses => 'Waiting for responses';

  @override
  String get chooseHelper => 'Choose helper';

  @override
  String get snackNoResponses => 'No responses yet — wait a bit.';

  @override
  String get snackChooseHelper => 'Choose a helper to open chat.';

  @override
  String get snackChatNoRelay =>
      'Chat doesn\'t know which request to link to on relay yet.';

  @override
  String get chatHelperNearby => 'Helper nearby';

  @override
  String get chatRequestAuthor => 'Request author';

  @override
  String get chatNoResponseYet => 'No response yet';

  @override
  String get chatWaitingResponse => 'Waiting for response';

  @override
  String get chatHasResponse => 'Has response';

  @override
  String get chatHelpTitle => 'Help chat';

  @override
  String get chatResponseTitle => 'Response chat';

  @override
  String get chatNoParticipant => 'No participant yet';

  @override
  String get chatReady => 'Connection ready';

  @override
  String get snackRequestCompleted =>
      'Request completed. You can rate the help.';

  @override
  String snackRatingSaved(int stars) {
    return 'Thanks! Rating $stars saved.';
  }

  @override
  String get noteHelpReceived => 'Help received';

  @override
  String noteRating(int stars) {
    return 'Rating $stars';
  }

  @override
  String get radarTitle => 'Radar';

  @override
  String radarRadius(String radius) {
    return 'Radius $radius';
  }

  @override
  String get radarHelperNearby => 'Helper nearby';

  @override
  String get radarSignal => 'Signal';

  @override
  String get radarSoon => 'soon';

  @override
  String get radarLegendMulti => 'dot — tap, title below';

  @override
  String get radarLegendSingle => 'request nearby';

  @override
  String get radarLegendUrgent => 'urgent request';

  @override
  String get radarLegendZones => 'rings — proximity zones';

  @override
  String get helperSelectionTitle => 'Who\'s helping?';

  @override
  String helperSelectionSubtitle(String title) {
    return '\"$title\" — pick one helper for the chat.';
  }

  @override
  String get chatPaletteCalmTitle => 'Calm';

  @override
  String get chatPaletteNightTitle => 'Night';

  @override
  String get chatPaletteWarmTitle => 'Warm';

  @override
  String get chatPaletteCyberpunkTitle => 'Cyberpunk';

  @override
  String get chatStartHint =>
      '\"I\'m nearby\", \"On my way\" — easier to coordinate without calls.';

  @override
  String get chatReportReason => 'Report from chat';

  @override
  String get chatMenuTooltip => 'Chat menu';

  @override
  String get chatThemeTitle => 'Chat theme';

  @override
  String get chatThemeSheetTitle => 'Chat theme';

  @override
  String get chatThemeSheetHint =>
      'Pick the mood of the conversation. Feeling only, not functionality.';

  @override
  String get chatPaletteCalm => 'Restrained and soft, for calm coordination.';

  @override
  String get chatPaletteNight =>
      'Deeper and more contrast, when you want quiet.';

  @override
  String get chatPaletteWarm =>
      'A bit warmer in tone when you need lively contact.';

  @override
  String get chatPaletteCyberpunk =>
      'Neon contrast, matching the cyberpunk radar.';

  @override
  String get chatNoPrepay => 'No prepayment';

  @override
  String get chatStartMessage => 'Start with a short message';

  @override
  String get chatLess => 'Less';

  @override
  String get chatMore => 'More';

  @override
  String get chatSoon => 'Soon';

  @override
  String get chatWaitingPeer => 'Waiting for participant…';

  @override
  String get chatMessageHint => 'Message';

  @override
  String get chatToday => 'Today';

  @override
  String get chatYou => 'You';

  @override
  String get chatDeliveryOnline => 'online';

  @override
  String get chatDeliverySending => 'sending…';

  @override
  String get chatDeliveryDelivered => 'delivered';

  @override
  String get chatDeliveryError => 'error';

  @override
  String get chatSendFailed => 'Didn\'t send. We\'ll retry.';

  @override
  String get chatBlockedSnackbar =>
      'User hidden. Their requests and messages won\'t appear anymore.';

  @override
  String get chatReportSaved =>
      'Report saved on device. We\'ll review this conversation more carefully.';

  @override
  String get chatQuickReplyHelper1 => 'I\'m home';

  @override
  String get chatQuickReplyHelper2 => 'Heading to the entrance';

  @override
  String get chatQuickReplyHelper3 => 'Thanks';

  @override
  String get chatQuickReplyHelper4 => 'Running a bit late';

  @override
  String get chatQuickReplyResponder1 => 'I\'m nearby';

  @override
  String get chatQuickReplyResponder2 => 'On my way';

  @override
  String get chatQuickReplyResponder3 => 'Be there in 5 minutes';

  @override
  String get chatQuickReplyResponder4 => 'Thanks';
}
