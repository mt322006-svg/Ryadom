import 'package:flutter_test/flutter_test.dart';
import 'package:ryadom/features/nostr/data/local_nostr_request_store.dart';
import 'package:ryadom/features/nostr/domain/nostr_event.dart';
import 'package:ryadom/features/nostr/domain/we_ryadom_nostr.dart';
import 'package:ryadom/features/requests/domain/help_request.dart';

void main() {
  test('links relay response to local request via request_id', () {
    final store = LocalNostrRequestStore(persist: false);
    const request = HelpRequest(
      id: 'req-two-phone',
      title: 'Прикурить',
      description: 'Нужен провод',
      compensation: RequestCompensation.free,
      areaLabel: 'Рядом',
      timeLabel: 'Сейчас',
      urgency: RequestUrgency.normal,
      status: RequestStatus.visible,
      isOwnRequest: true,
    );

    store.publishRequest(request, authorPubkey: 'author-pubkey');

    final relayRequest = NostrEventRecord(
      id: 'relay-event-abc',
      sequence: 50,
      event: appRequestEventWithPubkey(
        WeRyadomNostr.requestEvent(request, areaBucket: 'u4xj'),
        'author-pubkey',
      ),
    );
    store.ingestEventRecord(relayRequest, currentPubkey: 'author-pubkey');

    final relayResponse = NostrEventRecord(
      id: 'relay-response-1',
      sequence: 51,
      event: appRequestEventWithPubkey(
        WeRyadomNostr.responseEvent(
          responseId: 'resp-remote-1',
          requestEventId: 'relay-event-abc',
          requestAddress: '$weRyadomRequestKind:author-pubkey:req-two-phone',
          requestId: 'req-two-phone',
          message: 'Я рядом, могу помочь.',
        ),
        'helper-pubkey',
      ),
    );
    store.ingestEventRecord(relayResponse);

    final own = store.ownRequests.firstWhere((item) => item.id == 'req-two-phone');
    expect(own.responseCount, 1);
    expect(store.respondersFor('req-two-phone'), hasLength(1));
    expect(store.respondersFor('req-two-phone').first.pubkey, 'helper-pubkey');
  });
}