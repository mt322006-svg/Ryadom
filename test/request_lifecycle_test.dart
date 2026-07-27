import 'package:flutter_test/flutter_test.dart';
import 'package:ryadom/features/requests/domain/help_request.dart';
import 'package:ryadom/features/requests/domain/request_lifecycle.dart';

HelpRequest _req({
  RequestStatus status = RequestStatus.visible,
  DateTime? createdAt,
  bool isOwn = false,
}) {
  return HelpRequest(
    id: 'r1',
    title: 'Тест',
    description: 'd',
    compensation: RequestCompensation.free,
    areaLabel: 'Зона',
    timeLabel: 'Сейчас',
    urgency: RequestUrgency.normal,
    status: status,
    isOwnRequest: isOwn,
    createdAt: createdAt,
  );
}

void main() {
  test('hides expired requests from nearby after TTL', () {
    final old = _req(createdAt: DateTime.now().subtract(const Duration(hours: 13)));
    final fresh = _req(createdAt: DateTime.now().subtract(const Duration(hours: 1)));

    expect(RequestLifecycle.isExpired(old), isTrue);
    expect(RequestLifecycle.isActiveNearby(old), isFalse);
    expect(RequestLifecycle.isActiveNearby(fresh), isTrue);
  });

  test('cancelled and completed are not nearby-active', () {
    expect(
      RequestLifecycle.isActiveNearby(_req(status: RequestStatus.cancelled)),
      isFalse,
    );
    expect(
      RequestLifecycle.isActiveNearby(_req(status: RequestStatus.completed)),
      isFalse,
    );
  });

  test('owner can cancel open requests only', () {
    expect(
      RequestLifecycle.canCancel(_req(isOwn: true, status: RequestStatus.visible)),
      isTrue,
    );
    expect(
      RequestLifecycle.canCancel(
        _req(isOwn: true, status: RequestStatus.completed),
      ),
      isFalse,
    );
    expect(
      RequestLifecycle.canCancel(
        _req(isOwn: false, status: RequestStatus.visible),
      ),
      isFalse,
    );
  });
}
