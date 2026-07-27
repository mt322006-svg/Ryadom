import 'package:flutter_test/flutter_test.dart';
import 'package:ryadom/features/nostr/domain/we_ryadom_nostr.dart';
import 'package:ryadom/features/requests/domain/help_request.dart';

bool _hasTag(List<List<String>> tags, String key, String value) {
  return tags.any((tag) => tag.length >= 2 && tag[0] == key && tag[1] == value);
}

void main() {
  test('maps help request into a nostr request event', () {
    const request = HelpRequest(
      id: 'req-1',
      title: 'Прикурить автомобиль',
      description: 'Сел аккумулятор, нужны провода на 10 минут.',
      compensation: RequestCompensation.paid,
      areaLabel: 'Рядом с ТЦ Гринвич',
      timeLabel: 'В ближайшие 15 минут',
      urgency: RequestUrgency.urgent,
      status: RequestStatus.visible,
    );

    final event = WeRyadomNostr.requestEvent(request, areaBucket: 'u4xj');

    expect(event.kind, weRyadomRequestKind);
    expect(event.content['title'], 'Прикурить автомобиль');
    expect(_hasTag(event.tags, 'd', 'req-1'), isTrue);
    expect(_hasTag(event.tags, 'g', 'u4xj'), isTrue);
    expect(_hasTag(event.tags, 'urgent', 'urgent'), isTrue);
    expect(_hasTag(event.tags, 'comp', 'paid'), isTrue);
    expect(_hasTag(event.tags, 'status', 'visible'), isTrue);
  });

  test('maps response into a nostr response event', () {
    final event = WeRyadomNostr.responseEvent(
      responseId: 'resp-1',
      requestEventId: 'event-1',
      requestAddress: '31101:pubkey:req-1',
      requestId: 'req-1',
      message: 'Я рядом, могу подойти через 5 минут.',
    );

    expect(event.kind, weRyadomResponseKind);
    expect(event.content['request_id'], 'req-1');
    expect(_hasTag(event.tags, 'e', 'event-1'), isTrue);
    expect(_hasTag(event.tags, 'a', '31101:pubkey:req-1'), isTrue);
    expect(_hasTag(event.tags, 'status', 'sent'), isTrue);
  });

  test('maps status update into a nostr state event', () {
    final event = WeRyadomNostr.requestStateEvent(
      updateId: 'upd-1',
      requestEventId: 'event-1',
      requestId: 'req-1',
      status: RequestStatus.completed,
      note: 'Помощь оказана',
    );

    expect(event.kind, weRyadomRequestStateKind);
    expect(event.content['status'], 'completed');
    expect(event.content['note'], 'Помощь оказана');
    expect(_hasTag(event.tags, 'status', 'completed'), isTrue);
    expect(_hasTag(event.tags, 't', 'request-state'), isTrue);
  });
}
