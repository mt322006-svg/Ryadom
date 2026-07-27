import 'package:flutter_test/flutter_test.dart';
import 'package:ryadom/features/geo/domain/geo_privacy.dart';
import 'package:ryadom/features/nostr/data/local_nostr_request_store.dart';
import 'package:ryadom/features/nostr/domain/nostr_event.dart';
import 'package:ryadom/features/nostr/domain/we_ryadom_nostr.dart';
import 'package:ryadom/features/requests/domain/help_request.dart';
import 'package:ryadom/features/trust/domain/trust_guard.dart';

void main() {
  test('strips precise coordinates from public request content', () {
    final sanitized = TrustGuard.sanitizePublicRequestContent({
      'title': 'Помощь',
      'latitude': 56.84,
      'longitude': 60.61,
    });

    expect(sanitized.containsKey('latitude'), isFalse);
    expect(sanitized.containsKey('longitude'), isFalse);
    expect(sanitized['title'], 'Помощь');
  });

  test('ignores forged request state updates from non-author', () {
    final store = LocalNostrRequestStore(persist: false);
    const request = HelpRequest(
      id: 'req-forge',
      title: 'Тест',
      description: 'Проверка',
      compensation: RequestCompensation.free,
      areaLabel: 'Рядом',
      timeLabel: 'Сейчас',
      urgency: RequestUrgency.normal,
      status: RequestStatus.visible,
      isOwnRequest: true,
    );

    store.publishRequest(request, authorPubkey: 'author-pubkey');

    store.ingestEventRecord(
      NostrEventRecord(
        id: 'fake-state',
        sequence: 10,
        event: appRequestEventWithPubkey(
          WeRyadomNostr.requestStateEvent(
            updateId: 'fake-1',
            requestEventId: 'req-event-req-forge',
            requestId: 'req-forge',
            status: RequestStatus.completed,
            note: 'Взлом',
          ),
          'attacker-pubkey',
        ),
      ),
    );

    final own = store.ownRequests.firstWhere((item) => item.id == 'req-forge');
    expect(own.status, RequestStatus.visible);
  });

  test('chat visibility requires recipient tag', () {
    final visible = TrustGuard.isChatVisibleToParticipant(
      event: NostrEvent(
        kind: weRyadomChatMessageKind,
        content: {'request_id': 'req-1', 'message': 'Привет'},
        tags: [
          ['p', 'helper-pubkey'],
        ],
        pubkey: 'author-pubkey',
      ),
      currentPubkey: 'helper-pubkey',
      requestAuthorPubkey: 'author-pubkey',
      activeParticipantPubkey: 'helper-pubkey',
    );

    final hidden = TrustGuard.isChatVisibleToParticipant(
      event: NostrEvent(
        kind: weRyadomChatMessageKind,
        content: {'request_id': 'req-1', 'message': 'Секрет'},
        tags: const [],
        pubkey: 'author-pubkey',
      ),
      currentPubkey: 'stranger-pubkey',
      requestAuthorPubkey: 'author-pubkey',
      activeParticipantPubkey: 'helper-pubkey',
    );

    expect(visible, isTrue);
    expect(hidden, isFalse);
  });

  test('uses approximate area bucket for distance hints', () {
    final coords = GeoPrivacy.parseAreaBucket('56.84:60.60');
    expect(coords?.latitude, 56.84);
    expect(coords?.longitude, 60.60);
  });
}