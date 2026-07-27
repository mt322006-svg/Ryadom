import 'package:ryadom/features/nostr/data/local_nostr_request_store.dart';
import 'package:ryadom/features/requests/domain/help_request.dart';

/// Fixture data for widget/unit tests only — not used in the app.
const testNearbyJumpStart = HelpRequest(
  id: 'test-nearby-2',
  title: 'Прикурить автомобиль',
  description: 'Сел аккумулятор, нужны провода на 10 минут.',
  compensation: RequestCompensation.paid,
  areaLabel: 'Рядом с ТЦ Гринвич',
  timeLabel: 'В ближайшие 15 минут',
  urgency: RequestUrgency.urgent,
  status: RequestStatus.visible,
  responseCount: 0,
  distanceHintMeters: 1400,
);

const testOwnLampRequest = HelpRequest(
  id: 'test-own-1',
  title: 'Помочь заменить лампу',
  description: 'Нужна помощь с заменой лампы.',
  compensation: RequestCompensation.free,
  areaLabel: 'Район Автовокзал',
  timeLabel: 'Сегодня',
  urgency: RequestUrgency.normal,
  status: RequestStatus.inProgress,
  responseCount: 1,
  isOwnRequest: true,
  distanceHintMeters: 600,
);

LocalNostrRequestStore createWidgetTestStore() {
  final store = LocalNostrRequestStore.testOnly();
  store.installRequestForTests(testNearbyJumpStart, isOwn: false);
  store.installRequestForTests(testOwnLampRequest, isOwn: true);
  store.chooseHelper(
    requestId: testOwnLampRequest.id,
    helperPubkey: 'test-helper-pubkey',
  );
  return store;
}