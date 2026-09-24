import 'package:flutter_test/flutter_test.dart';
import 'package:ryadom/features/chat/domain/shared_location_payload.dart';

void main() {
  group('SharedLocationPayload', () {
    test('round-trips valid coordinates', () {
      const original = SharedLocationPayload(
        latitude: 54.31712,
        longitude: 59.37841,
      );

      final decoded = SharedLocationPayload.tryParse(original.encode());

      expect(decoded, isNotNull);
      expect(decoded!.latitude, original.latitude);
      expect(decoded.longitude, original.longitude);
    });

    test('ignores ordinary chat text', () {
      expect(SharedLocationPayload.tryParse('Я рядом'), isNull);
    });

    test('rejects coordinates outside the valid range', () {
      expect(
        SharedLocationPayload.tryParse(
          '{"type":"ryadom.location.v1","latitude":91,"longitude":10}',
        ),
        isNull,
      );
      expect(
        SharedLocationPayload.tryParse(
          '{"type":"ryadom.location.v1","latitude":10,"longitude":181}',
        ),
        isNull,
      );
    });
  });
}
