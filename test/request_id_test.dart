import 'package:flutter_test/flutter_test.dart';
import 'package:ryadom/features/requests/domain/request_id.dart';

void main() {
  test('request ids are random, well-formed and unique in a local batch', () {
    final ids = List.generate(1000, (_) => RequestId.generate());

    expect(ids.toSet(), hasLength(ids.length));
    for (final id in ids) {
      expect(id, matches(RegExp(r'^req-[0-9a-f]{32}$')));
    }
  });
}
