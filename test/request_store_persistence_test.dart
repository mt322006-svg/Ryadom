import 'package:flutter_test/flutter_test.dart';
import 'package:ryadom/features/nostr/data/local_nostr_request_persistence.dart';
import 'package:ryadom/features/nostr/data/local_nostr_request_store.dart';
import 'package:ryadom/features/nostr/data/nostr_event_codec.dart';
import 'package:ryadom/features/nostr/domain/nostr_event.dart';
import 'package:ryadom/features/nostr/domain/we_ryadom_nostr.dart';
import 'package:ryadom/features/requests/domain/help_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists and restores request store snapshot', () async {
    const request = HelpRequest(
      id: 'persist-1',
      title: 'Нужна помощь с колесом',
      description: 'Пробило колесо у магазина.',
      compensation: RequestCompensation.free,
      areaLabel: 'Рядом',
      timeLabel: 'Сейчас',
      urgency: RequestUrgency.normal,
      status: RequestStatus.visible,
    );

    final event = WeRyadomNostr.requestEvent(request, areaBucket: '55.80:49.21');
    final record = NostrEventRecord(id: 'evt-1', event: event, sequence: 3);
    final snapshot = RequestStoreSnapshot(
      events: [record],
      ownRequestIds: {'persist-1'},
      respondedRequestIds: {},
      chosenHelperByRequestId: {},
      sequence: 4,
    );

    await LocalNostrRequestPersistence.save(snapshot);
    final loaded = await LocalNostrRequestPersistence.load();

    expect(loaded, isNotNull);
    expect(loaded!.ownRequestIds, contains('persist-1'));
    expect(loaded.events, hasLength(1));
    expect(loaded.events.first.id, 'evt-1');
    expect(loaded.events.first.event.kind, weRyadomRequestKind);
  });

  test('upgrade removes decrypted chat from persisted snapshot', () async {
    final chat = NostrEventRecord(
      id: 'chat-1',
      sequence: 1,
      event: NostrEvent(
        kind: weRyadomChatMessageKind,
        content: const {
          'request_id': 'req-private',
          'message':
              '{"type":"ryadom.location.v1","latitude":55.1,"longitude":37.2}',
        },
        tags: const [
          ['p', 'peer'],
        ],
        pubkey: 'sender',
      ),
    );
    await LocalNostrRequestPersistence.save(
      RequestStoreSnapshot(
        events: [chat],
        ownRequestIds: const {},
        respondedRequestIds: const {},
        chosenHelperByRequestId: const {},
        sequence: 2,
      ),
    );

    await LocalNostrRequestStore.open();
    final sanitized = await LocalNostrRequestPersistence.load();

    expect(sanitized, isNotNull);
    expect(sanitized!.events, isEmpty);
  });

  test('completion purges exact location from in-memory chat', () {
    const request = HelpRequest(
      id: 'req-location',
      title: 'Нужна помощь',
      description: 'Тест',
      compensation: RequestCompensation.free,
      areaLabel: 'Рядом',
      timeLabel: 'Сейчас',
      urgency: RequestUrgency.normal,
      status: RequestStatus.visible,
      isOwnRequest: true,
    );

    final store = LocalNostrRequestStore.testOnly();
    store.installRequestForTests(
      request,
      isOwn: true,
      authorPubkey: 'owner',
    );

    store.ingestEventRecord(
      NostrEventRecord(
        id: 'chat-location',
        sequence: 10,
        event: NostrEvent(
          kind: weRyadomChatMessageKind,
          content: const {
            'request_id': 'req-location',
            'message':
                '{"type":"ryadom.location.v1","latitude":55.1,"longitude":37.2}',
          },
          tags: const [
            ['p', 'helper'],
          ],
          pubkey: 'owner',
        ),
      ),
      currentPubkey: 'owner',
    );
    store.ingestEventRecord(
      NostrEventRecord(
        id: 'chat-text',
        sequence: 11,
        event: const NostrEvent(
          kind: weRyadomChatMessageKind,
          content: {
            'request_id': 'req-location',
            'message': 'Подхожу через пять минут',
          },
          tags: [
            ['p', 'helper'],
          ],
          pubkey: 'owner',
        ),
      ),
      currentPubkey: 'owner',
    );

    expect(
      store.chatMessagesFor(
        requestId: 'req-location',
        currentPubkey: 'owner',
        participantName: 'Помощник',
        requestAuthorPubkey: 'owner',
        activeParticipantPubkey: 'helper',
      ),
      hasLength(2),
    );

    store.updateRequestStatus(
      requestId: 'req-location',
      status: RequestStatus.completed,
    );

    final remaining = store.chatMessagesFor(
      requestId: 'req-location',
      currentPubkey: 'owner',
      participantName: 'Помощник',
      requestAuthorPubkey: 'owner',
      activeParticipantPubkey: 'helper',
    );
    expect(remaining, hasLength(1));
    expect(remaining.single.text, 'Подхожу через пять минут');
  });


  test('remote completion purges exact location from in-memory chat', () {
    const request = HelpRequest(
      id: 'req-remote-complete',
      title: 'Нужна помощь',
      description: 'Тест',
      compensation: RequestCompensation.free,
      areaLabel: 'Рядом',
      timeLabel: 'Сейчас',
      urgency: RequestUrgency.normal,
      status: RequestStatus.visible,
      isOwnRequest: true,
    );

    final store = LocalNostrRequestStore.testOnly();
    store.installRequestForTests(
      request,
      isOwn: true,
      authorPubkey: 'owner',
    );

    store.ingestEventRecord(
      NostrEventRecord(
        id: 'chat-location-remote',
        sequence: 10,
        event: const NostrEvent(
          kind: weRyadomChatMessageKind,
          content: {
            'request_id': 'req-remote-complete',
            'message':
                '{"type":"ryadom.location.v1","latitude":55.1,"longitude":37.2}',
          },
          tags: [
            ['p', 'helper'],
          ],
          pubkey: 'owner',
        ),
      ),
      currentPubkey: 'owner',
    );

    final stateEvent = appRequestEventWithPubkey(
      WeRyadomNostr.requestStateEvent(
        updateId: 'remote-complete-1',
        requestEventId: 'req-event-req-remote-complete',
        requestId: 'req-remote-complete',
        status: RequestStatus.completed,
      ),
      'owner',
    );

    store.ingestEventRecord(
      NostrEventRecord(
        id: 'remote-complete-1',
        sequence: 11,
        event: stateEvent,
      ),
      currentPubkey: 'owner',
    );

    expect(
      store.chatMessagesFor(
        requestId: 'req-remote-complete',
        currentPubkey: 'owner',
        participantName: 'Помощник',
        requestAuthorPubkey: 'owner',
        activeParticipantPubkey: 'helper',
      ),
      isEmpty,
    );
  });



}
