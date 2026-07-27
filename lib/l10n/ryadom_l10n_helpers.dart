import '../features/home/presentation/home_models.dart';
import '../features/nostr/data/we_ryadom_nostr_gateway.dart';
import '../features/requests/domain/help_request.dart';
import '../theme/ryadom_app_theme.dart';
import 'app_localizations.dart';

extension RyadomL10nHelpers on AppLocalizations {
  String radarFilterLabel(RadarFilter filter) => switch (filter) {
        RadarFilter.all => filterAll,
        RadarFilter.requests => filterRequests,
        RadarFilter.people => filterPeople,
        RadarFilter.signals => filterSignals,
      };

  String relayStateLabel(RequestRelayState state) => switch (state) {
        RequestRelayState.localOnly => relayStateLocalOnly,
        RequestRelayState.sentToRelay => relayStateSentToRelay,
        RequestRelayState.seenFromRelay => relayStateSeenFromRelay,
      };

  String themeTitle(RyadomAppTheme theme) => switch (theme) {
        RyadomAppTheme.classic => themeClassicTitle,
        RyadomAppTheme.night => themeNightTitle,
        RyadomAppTheme.light => themeLightTitle,
        RyadomAppTheme.cyberpunk => themeCyberpunkTitle,
      };

  String themeSubtitle(RyadomAppTheme theme) => switch (theme) {
        RyadomAppTheme.classic => themeClassicSubtitle,
        RyadomAppTheme.night => themeNightSubtitle,
        RyadomAppTheme.light => themeLightSubtitle,
        RyadomAppTheme.cyberpunk => themeCyberpunkSubtitle,
      };

  String urgencyLabel(RequestUrgency urgency) => switch (urgency) {
        RequestUrgency.low => urgencyLow,
        RequestUrgency.normal => urgencyNormal,
        RequestUrgency.urgent => urgencyUrgent,
      };

  String compensationLabel(RequestCompensation compensation) =>
      switch (compensation) {
        RequestCompensation.free => compensationFree,
        RequestCompensation.paid => compensationPaid,
      };

  String compensationActionLabel(RequestCompensation compensation) =>
      switch (compensation) {
        RequestCompensation.free => compensationFree,
        RequestCompensation.paid => compensationPaidAction,
      };

  String statusLabel(RequestStatus status) => switch (status) {
        RequestStatus.created => statusCreated,
        RequestStatus.visible => statusVisible,
        RequestStatus.accepted => statusAccepted,
        RequestStatus.inProgress => statusInProgress,
        RequestStatus.completed => statusCompleted,
        RequestStatus.rated => statusRated,
        RequestStatus.cancelled => statusCancelled,
      };

  String formatRadius(int value) {
    if (value >= 1000) {
      final km = value / 1000;
      return km == km.roundToDouble()
          ? radiusKmInt(km.toInt())
          : radiusKmDecimal(km.toStringAsFixed(1));
    }
    return radiusMeters(value);
  }

  /// Honest proximity bands — public points are zone centers, not exact pins.
  String formatDistance(double? meters) {
    if (meters == null) {
      return distanceNearby;
    }
    if (meters < 350) {
      return distanceApproxNearby;
    }
    if (meters < 850) {
      return distanceApproxMeters(500);
    }
    if (meters < 1600) {
      return distanceApproxKm('1');
    }
    if (meters < 4000) {
      return distanceApproxKm('2–3');
    }
    if (meters < 8000) {
      return distanceApproxKm('5');
    }
    return distanceApproxKm('10');
  }

  String responseCountChipLabel(int count) => responseCountChip(count);

  String formatRadarNearbySummary({
    required int requestCount,
    required int responseCount,
  }) {
    if (requestCount == 0) {
      return radarNearbySummaryEmpty;
    }
    return radarNearbySummary(requestCount, responseCount);
  }

  String nostrConnectionStatus(NostrConnectionStatus status) =>
      switch (status) {
        NostrConnectionStatus.starting => nostrStatusStarting,
        NostrConnectionStatus.connecting => nostrStatusConnecting,
        NostrConnectionStatus.online => nostrStatusOnline,
        NostrConnectionStatus.offline => nostrStatusOffline,
        NostrConnectionStatus.test => nostrStatusTest,
        NostrConnectionStatus.error => nostrStatusError,
      };

  String compactNostrStatus(NostrConnectionStatus status) =>
      nostrConnectionStatus(status);

  String compactHeaderLabel(String label, {required String fallback}) {
    final lower = label.toLowerCase();

    if (lower.contains('подключа') ||
        lower.contains('старту') ||
        lower.contains('connect') ||
        lower.contains('start')) {
      return headerStatusProgress(fallback);
    }
    if (lower.contains('онлайн') || lower.contains('online')) {
      return headerStatusOk(fallback);
    }
    if (lower.contains('ошиб') ||
        lower.contains('оффлайн') ||
        lower.contains('error') ||
        lower.contains('offline')) {
      return headerStatusNo(fallback);
    }
    if (lower.contains('ищем') || lower.contains('finding')) {
      return headerStatusProgress(fallback);
    }
    if (lower.contains('точное') || lower.contains('precise geo')) {
      return headerGeoPrecise;
    }
    if (lower.contains('стабильное') || lower.contains('stable geo')) {
      return headerGeoStable;
    }
    if (lower.contains('примерное') ||
        lower.contains('рядом') && lower.contains('гео') ||
        lower.contains('geo nearby')) {
      return headerGeoApprox;
    }
    if (lower.contains('выключ') ||
        lower.contains('выкл') ||
        lower.contains('geo off') ||
        lower.contains('disabled')) {
      return headerStatusOff(fallback);
    }

    return label;
  }

  String formatClock(DateTime value) {
    final hours = value.hour.toString().padLeft(2, '0');
    final minutes = value.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}

String shortNpub(String npub) {
  if (npub.length <= 16) {
    return npub;
  }
  return '${npub.substring(0, 8)}...${npub.substring(npub.length - 6)}';
}

int totalResponses(List<HelpRequest> requests) {
  return requests.fold(0, (sum, request) => sum + request.responseCount);
}

String overviewResponseLabel(List<HelpRequest> requests) {
  final total = totalResponses(requests);
  return total == 0 ? '—' : '$total';
}