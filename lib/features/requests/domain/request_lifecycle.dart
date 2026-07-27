import 'help_request.dart';

/// Client-side lifecycle rules for help requests (TTL + active visibility).
class RequestLifecycle {
  const RequestLifecycle._();

  /// Requests older than this leave the radar even without a cancel event.
  static const Duration defaultTtl = Duration(hours: 12);

  static bool isTerminal(RequestStatus status) {
    return status == RequestStatus.completed ||
        status == RequestStatus.rated ||
        status == RequestStatus.cancelled;
  }

  static bool isExpired(HelpRequest request, {DateTime? now}) {
    final createdAt = request.createdAt;
    if (createdAt == null) {
      return false;
    }
    final clock = now ?? DateTime.now();
    return clock.isAfter(createdAt.add(defaultTtl));
  }

  /// Visible on radar / nearby lists for others.
  static bool isActiveNearby(HelpRequest request, {DateTime? now}) {
    if (isTerminal(request.status)) {
      return false;
    }
    if (isExpired(request, now: now)) {
      return false;
    }
    return true;
  }

  /// Owner can cancel open requests that are not finished yet.
  static bool canCancel(HelpRequest request) {
    if (!request.isOwnRequest) {
      return false;
    }
    return request.status == RequestStatus.created ||
        request.status == RequestStatus.visible ||
        request.status == RequestStatus.accepted ||
        request.status == RequestStatus.inProgress;
  }
}
