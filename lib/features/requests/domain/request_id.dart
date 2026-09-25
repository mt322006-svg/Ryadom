import 'dart:math';

class RequestId {
  const RequestId._();

  static final Random _random = Random.secure();

  /// 128 bits of local entropy keeps request IDs independent of clocks and
  /// avoids cross-device collisions in a decentralized feed.
  static String generate() {
    final buffer = StringBuffer('req-');
    for (var i = 0; i < 16; i++) {
      buffer.write(_random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
