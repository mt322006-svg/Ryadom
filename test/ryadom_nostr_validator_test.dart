import 'package:flutter_test/flutter_test.dart';
import 'package:ryadom/features/nostr/data/ryadom_nostr_validator.dart';
import 'package:ryadom/features/nostr/domain/nostr_event.dart';

const _pubkey =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
const _eventId =
    'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';

NostrEvent _requestEvent({Map<String, Object?>? content}) {
  return NostrEvent(
    kind: RyadomNostrValidator.requestKind,
    content: content ??
        const {
          'title': 'Нужна помощь',
          'description': 'Короткое описание',
          'area_label': 'Примерная зона',
          'time_label': 'Сейчас',
        },
    tags: const [
      ['d', 'req-1'],
      ['t', 'we-ryadom'],
      ['t', 'request'],
      ['g', '55.00:37.00'],
      ['status', 'visible'],
      ['urgent', 'normal'],
      ['comp', 'free'],
    ],
    pubkey: _pubkey,
    signature: 'signature-present',
    createdAt: DateTime(2026, 9, 24),
  );
}

void main() {
  test('accepts a well-formed public request', () {
    expect(
      RyadomNostrValidator.isValidRemoteAppEvent(_requestEvent()),
      isTrue,
    );
  });

  test('rejects precise coordinates in public request content', () {
    final event = _requestEvent(
      content: const {
        'title': 'Нужна помощь',
        'description': 'Короткое описание',
        'area_label': 'Примерная зона',
        'time_label': 'Сейчас',
        'latitude': 55.123456,
        'longitude': 37.654321,
      },
    );

    expect(
      RyadomNostrValidator.isValidRemoteAppEvent(event),
      isFalse,
    );
  });

  test('rejects wrong field types instead of trusting relay JSON', () {
    final event = _requestEvent(
      content: const {
        'title': ['not', 'text'],
        'description': 'Описание',
        'area_label': 'Зона',
        'time_label': 'Сейчас',
      },
    );

    expect(
      RyadomNostrValidator.isValidRemoteAppEvent(event),
      isFalse,
    );
  });

  test('accepts a well-formed response reference', () {
    final event = NostrEvent(
      kind: RyadomNostrValidator.responseKind,
      content: const {
        'request_id': 'req-1',
        'message': 'Я рядом',
      },
      tags: const [
        ['d', 'resp-1'],
        ['e', _eventId],
        ['t', 'we-ryadom'],
        ['t', 'response'],
        ['status', 'sent'],
      ],
      pubkey: _pubkey,
      signature: 'signature-present',
      createdAt: DateTime(2026, 9, 24),
    );

    expect(
      RyadomNostrValidator.isValidRemoteAppEvent(event),
      isTrue,
    );
  });
}
