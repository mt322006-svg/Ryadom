import 'package:flutter_test/flutter_test.dart';
import 'package:ryadom/features/nostr/data/local_nostr_request_store.dart';
import 'package:ryadom/features/requests/domain/help_request.dart';

void main() {
  test('publishing a request adds it to own requests', () {
    final store = LocalNostrRequestStore.testOnly();
    const request = HelpRequest(
      id: 'local-123',
      title: 'Нужно донести пакеты',
      description: 'Подняться на 3 этаж без лифта.',
      compensation: RequestCompensation.free,
      areaLabel: 'Вокруг дома',
      timeLabel: 'Сейчас',
      urgency: RequestUrgency.normal,
      status: RequestStatus.visible,
      isOwnRequest: true,
    );

    store.publishRequest(request);

    expect(store.ownRequests.any((item) => item.id == 'local-123'), isTrue);
  });

  test('responding to a request updates response count and state', () {
    final store = LocalNostrRequestStore.testOnly();
    const request = HelpRequest(
      id: 'nearby-1',
      title: 'Нужна помощь',
      description: 'Тест отклика',
      compensation: RequestCompensation.free,
      areaLabel: 'Рядом',
      timeLabel: 'Сейчас',
      urgency: RequestUrgency.normal,
      status: RequestStatus.visible,
      responseCount: 0,
      distanceHintMeters: 500,
    );
    store.installRequestForTests(request, isOwn: false);

    final updated = store.respondToRequest(
      store.nearbyRequests.firstWhere((item) => item.id == 'nearby-1'),
    );

    expect(updated.hasCurrentUserResponded, isTrue);
    expect(updated.responseCount, 1);
    expect(updated.status, RequestStatus.visible);
  });

  test('marks request completed and rated', () {
    final store = LocalNostrRequestStore.testOnly();
    const request = HelpRequest(
      id: 'finish-me',
      title: 'Тест завершения',
      description: 'Проверка статуса',
      compensation: RequestCompensation.free,
      areaLabel: 'Рядом',
      timeLabel: 'Сейчас',
      urgency: RequestUrgency.normal,
      status: RequestStatus.visible,
      isOwnRequest: true,
    );

    store.publishRequest(request);
    final completed = store.updateRequestStatus(
      requestId: 'finish-me',
      status: RequestStatus.completed,
      note: 'Готово',
    );
    expect(completed.status, RequestStatus.completed);

    final rated = store.updateRequestStatus(
      requestId: 'finish-me',
      status: RequestStatus.rated,
      rating: 5,
    );
    expect(rated.status, RequestStatus.rated);
  });
}