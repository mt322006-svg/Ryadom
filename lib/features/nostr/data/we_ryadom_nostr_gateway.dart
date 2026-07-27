import 'dart:async';

import 'package:dart_nostr/dart_nostr.dart';

import '../../geo/domain/geo_privacy.dart';
import '../../requests/domain/help_request.dart';
import '../domain/nostr_event.dart' as app_nostr;
import '../domain/we_ryadom_nostr.dart';
import 'nip44_chat_crypto.dart';
import 'nostr_identity_store.dart';

enum NostrConnectionStatus {
  starting,
  connecting,
  online,
  offline,
  test,
  error,
}

class NostrGatewayState {
  const NostrGatewayState({
    required this.relayUrl,
    required this.isConnected,
    required this.isConnecting,
    required this.connectionStatus,
    this.errorMessage,
    this.publicKey,
    this.npub,
  });

  final String relayUrl;
  final bool isConnected;
  final bool isConnecting;
  final NostrConnectionStatus connectionStatus;
  final String? errorMessage;
  final String? publicKey;
  final String? npub;
}

abstract class WeRyadomNostrGateway {
  Stream<app_nostr.NostrEventRecord> get events;

  String? get currentPubkey;

  Future<NostrGatewayState> initialize();

  Future<NostrGatewayState> reconnect([String? relayUrl]);

  Future<bool> publishRequest(HelpRequest request);

  Future<bool> publishResponse({
    required HelpRequest request,
    required String requestEventId,
    required String requestAuthorPubkey,
  });

  Future<bool> publishHelperChosen({
    required String requestId,
    required String requestEventId,
    required String helperPubkey,
  });

  Future<bool> publishRequestState({
    required String requestId,
    required String requestEventId,
    required RequestStatus status,
    String? note,
    String? helperPubkey,
    int? rating,
  });

  Future<String?> publishChatMessage({
    required String requestId,
    required String requestEventId,
    required String requestAuthorPubkey,
    required String recipientPubkey,
    required String message,
  });

  Future<void> dispose();
}

class DisabledWeRyadomNostrGateway implements WeRyadomNostrGateway {
  final Stream<app_nostr.NostrEventRecord> _events =
      const Stream<app_nostr.NostrEventRecord>.empty();

  @override
  Stream<app_nostr.NostrEventRecord> get events => _events;

  @override
  String? get currentPubkey => null;

  @override
  Future<NostrGatewayState> initialize() async {
    return const NostrGatewayState(
      relayUrl: NostrIdentityStore.defaultRelayUrl,
      isConnected: false,
      isConnecting: false,
      connectionStatus: NostrConnectionStatus.test,
    );
  }

  @override
  Future<NostrGatewayState> reconnect([String? relayUrl]) async {
    return NostrGatewayState(
      relayUrl: relayUrl ?? NostrIdentityStore.defaultRelayUrl,
      isConnected: false,
      isConnecting: false,
      connectionStatus: NostrConnectionStatus.test,
    );
  }

  @override
  Future<bool> publishRequest(HelpRequest request) async => false;

  @override
  Future<bool> publishResponse({
    required HelpRequest request,
    required String requestEventId,
    required String requestAuthorPubkey,
  }) async {
    return false;
  }

  @override
  Future<bool> publishHelperChosen({
    required String requestId,
    required String requestEventId,
    required String helperPubkey,
  }) async {
    return false;
  }

  @override
  Future<bool> publishRequestState({
    required String requestId,
    required String requestEventId,
    required RequestStatus status,
    String? note,
    String? helperPubkey,
    int? rating,
  }) async {
    return false;
  }

  @override
  Future<String?> publishChatMessage({
    required String requestId,
    required String requestEventId,
    required String requestAuthorPubkey,
    required String recipientPubkey,
    required String message,
  }) async {
    return null;
  }

  @override
  Future<void> dispose() async {}
}

class LiveWeRyadomNostrGateway implements WeRyadomNostrGateway {
  LiveWeRyadomNostrGateway({
    NostrIdentityStore? identityStore,
    Nostr? nostr,
  })  : _identityStore = identityStore ?? const NostrIdentityStore(),
        _nostr = nostr ?? Nostr() {
    _nostr.disableLogs();
  }

  final NostrIdentityStore _identityStore;
  final Nostr _nostr;
  final StreamController<app_nostr.NostrEventRecord> _eventsController =
      StreamController<app_nostr.NostrEventRecord>.broadcast();

  StreamSubscription<NostrEvent>? _subscription;
  NostrEventsStream? _subscriptionStream;
  NostrIdentity? _identity;
  int _sequence = 100000;

  @override
  Stream<app_nostr.NostrEventRecord> get events => _eventsController.stream;

  @override
  String? get currentPubkey => _identity?.publicKey;

  @override
  Future<NostrGatewayState> initialize() async {
    _identity = await _identityStore.loadOrCreate();
    return reconnect(_identity!.relayUrl);
  }

  @override
  Future<NostrGatewayState> reconnect([String? relayUrl]) async {
    final identity = _identity ?? await _identityStore.loadOrCreate();
    _identity = identity;

    final normalizedRelay = _normalizeRelay(relayUrl ?? identity.relayUrl);
    await _identityStore.saveRelayUrl(normalizedRelay);

    await _closeSubscription();
    await _nostr.disconnect();

    final connectResult = await _nostr.connect([normalizedRelay]);
    if (connectResult.isFailure) {
      return NostrGatewayState(
        relayUrl: normalizedRelay,
        isConnected: false,
        isConnecting: false,
        connectionStatus: NostrConnectionStatus.offline,
        errorMessage: connectResult.failureOrNull?.message,
        publicKey: identity.publicKey,
        npub: identity.npub,
      );
    }

    final subscriptionResult = _nostr.subscribe(
      NostrFilter(
        kinds: const [
          weRyadomRequestKind,
          weRyadomResponseKind,
          weRyadomRequestStateKind,
          weRyadomChatMessageKind,
        ],
        since: DateTime.now().subtract(const Duration(days: 1)),
        limit: 500,
      ),
    );

    subscriptionResult.fold(
      (stream) {
        _subscriptionStream = stream;
        _subscription = stream.stream.listen(
          (event) => unawaited(_handleRelayEvent(event)),
        );
      },
      (_) {},
    );

    return NostrGatewayState(
      relayUrl: normalizedRelay,
      isConnected: subscriptionResult.isSuccess,
      isConnecting: false,
      connectionStatus: subscriptionResult.isSuccess
          ? NostrConnectionStatus.online
          : NostrConnectionStatus.offline,
      errorMessage: subscriptionResult.failureOrNull?.message,
      publicKey: identity.publicKey,
      npub: identity.npub,
    );
  }

  @override
  Future<bool> publishRequest(HelpRequest request) async {
    final identity = _identity;
    if (identity == null || !_nostr.isConnected) {
      return false;
    }

    final event = WeRyadomNostr.toRelayEvent(
      WeRyadomNostr.requestEvent(
        request,
        areaBucket: _areaBucketForRequest(request),
        includePreciseLocation: false,
      ),
      keyPairs: NostrKeyPairs(private: identity.privateKey),
    );

    final result = await _nostr.publish(event);
    if (result.isSuccess) {
      _emitPublishedEvent(event, fallbackId: 'req-${request.id}');
    }
    return result.isSuccess;
  }

  @override
  Future<bool> publishResponse({
    required HelpRequest request,
    required String requestEventId,
    required String requestAuthorPubkey,
  }) async {
    final identity = _identity;
    if (identity == null || !_nostr.isConnected) {
      return false;
    }

    final keyPair = NostrKeyPairs(private: identity.privateKey);
    final responseEvent = WeRyadomNostr.toRelayEvent(
      WeRyadomNostr.responseEvent(
        responseId: 'resp-${request.id}-${DateTime.now().millisecondsSinceEpoch}',
        requestEventId: requestEventId,
        requestAddress:
            '$weRyadomRequestKind:$requestAuthorPubkey:${request.id}',
        requestId: request.id,
        message: 'Я рядом, могу помочь.',
      ),
      keyPairs: keyPair,
    );

    final responseResult = await _nostr.publish(responseEvent);
    if (responseResult.isSuccess) {
      _emitPublishedEvent(responseEvent, fallbackId: responseEvent.id ?? '');
    }
    return responseResult.isSuccess;
  }

  @override
  Future<bool> publishHelperChosen({
    required String requestId,
    required String requestEventId,
    required String helperPubkey,
  }) async {
    final identity = _identity;
    if (identity == null || !_nostr.isConnected) {
      return false;
    }

    return publishRequestState(
      requestId: requestId,
      requestEventId: requestEventId,
      status: RequestStatus.inProgress,
      note: 'Помощник выбран',
      helperPubkey: helperPubkey,
    );
  }

  @override
  Future<bool> publishRequestState({
    required String requestId,
    required String requestEventId,
    required RequestStatus status,
    String? note,
    String? helperPubkey,
    int? rating,
  }) async {
    final identity = _identity;
    if (identity == null || !_nostr.isConnected) {
      return false;
    }

    final stateEvent = WeRyadomNostr.toRelayEvent(
      WeRyadomNostr.requestStateEvent(
        updateId: 'state-$requestId-${DateTime.now().millisecondsSinceEpoch}',
        requestEventId: requestEventId,
        requestId: requestId,
        status: status,
        note: note,
        helperPubkey: helperPubkey,
        rating: rating,
      ),
      keyPairs: NostrKeyPairs(private: identity.privateKey),
    );

    final stateResult = await _nostr.publish(stateEvent);
    return stateResult.isSuccess;
  }

  @override
  Future<String?> publishChatMessage({
    required String requestId,
    required String requestEventId,
    required String requestAuthorPubkey,
    required String recipientPubkey,
    required String message,
  }) async {
    final identity = _identity;
    if (identity == null || !_nostr.isConnected) {
      return null;
    }

    final keyPair = NostrKeyPairs(private: identity.privateKey);
    final messageId = 'msg-$requestId-${DateTime.now().millisecondsSinceEpoch}';
    final plaintextEvent = WeRyadomNostr.chatMessageEvent(
      messageId: messageId,
      requestEventId: requestEventId,
      requestAddress: '$weRyadomRequestKind:$requestAuthorPubkey:$requestId',
      requestId: requestId,
      recipientPubkey: recipientPubkey,
      message: message,
    );

    final encryptedMessage = await Nip44ChatCrypto.encrypt(
      plaintext: message,
      senderPrivateKey: identity.privateKey,
      recipientPubkey: recipientPubkey,
    );

    final wireEvent = WeRyadomNostr.chatMessageEvent(
      messageId: messageId,
      requestEventId: requestEventId,
      requestAddress: '$weRyadomRequestKind:$requestAuthorPubkey:$requestId',
      requestId: requestId,
      recipientPubkey: recipientPubkey,
      message: encryptedMessage,
    );

    final chatEvent = WeRyadomNostr.toRelayEvent(
      wireEvent,
      keyPairs: keyPair,
    );

    final result = await _nostr.publish(chatEvent);
    if (result.isSuccess) {
      _emitPublishedEvent(
        WeRyadomNostr.toRelayEvent(plaintextEvent, keyPairs: keyPair),
        fallbackId: messageId,
      );
      return messageId;
    }
    return null;
  }

  @override
  Future<void> dispose() async {
    await _closeSubscription();
    await _nostr.disconnect();
    await _eventsController.close();
  }

  Future<void> _handleRelayEvent(NostrEvent relayEvent) async {
    final eventId = relayEvent.id;
    if (eventId == null || eventId.isEmpty) {
      return;
    }

    if (!relayEvent.isVerified()) {
      return;
    }

    final identity = _identity;
    if (relayEvent.kind == weRyadomChatMessageKind && identity != null) {
      final recipient = _firstRelayTagValue(relayEvent, 'p');
      final sender = relayEvent.pubkey;
      final isIncoming = recipient == identity.publicKey;
      final isOwnEcho = sender == identity.publicKey;

      if (!isIncoming && !isOwnEcho) {
        return;
      }

      if (isOwnEcho) {
        return;
      }

      final incomingEvent = WeRyadomNostr.fromRelayEvent(relayEvent);
      if (isIncoming && WeRyadomNostr.isEncryptedChatEvent(incomingEvent)) {
        final ciphertext = incomingEvent.content['message'] as String?;
        if (ciphertext == null || ciphertext.isEmpty) {
          return;
        }

        try {
          final plaintext = await Nip44ChatCrypto.decrypt(
            ciphertext: ciphertext,
            recipientPrivateKey: identity.privateKey,
            senderPubkey: sender,
          );
          _emitAppEvent(
            app_nostr.NostrEvent(
              kind: incomingEvent.kind,
              content: {
                'request_id': incomingEvent.content['request_id'],
                'message': plaintext,
              },
              tags: incomingEvent.tags,
              pubkey: incomingEvent.pubkey,
              createdAt: incomingEvent.createdAt,
              signature: incomingEvent.signature,
            ),
            fallbackId: eventId,
          );
          return;
        } catch (_) {
          return;
        }
      }
    }

    _emitPublishedEvent(relayEvent, fallbackId: eventId);
  }

  String? _firstRelayTagValue(NostrEvent relayEvent, String key) {
    final tags = relayEvent.tags;
    if (tags == null) {
      return null;
    }
    for (final tag in tags) {
      if (tag.length >= 2 && tag[0] == key) {
        return tag[1];
      }
    }
    return null;
  }

  void _emitAppEvent(app_nostr.NostrEvent event, {required String fallbackId}) {
    _eventsController.add(
      app_nostr.NostrEventRecord(
        id: fallbackId,
        event: event,
        sequence: _sequence++,
      ),
    );
  }

  void _emitPublishedEvent(NostrEvent relayEvent, {required String fallbackId}) {
    final relayId = relayEvent.id;
    final eventId =
        relayId != null && relayId.isNotEmpty ? relayId : fallbackId;

    final appEvent = WeRyadomNostr.fromRelayEvent(relayEvent);
    _eventsController.add(
      app_nostr.NostrEventRecord(
        id: eventId,
        event: appEvent,
        sequence: _sequence++,
      ),
    );
  }

  Future<void> _closeSubscription() async {
    await _subscription?.cancel();
    _subscription = null;
    _subscriptionStream?.close();
    _subscriptionStream = null;
  }

  String _areaBucketForRequest(HelpRequest request) {
    if (request.latitude != null && request.longitude != null) {
      return GeoPrivacy.areaBucket(request.latitude!, request.longitude!);
    }
    return 'global';
  }

  String _normalizeRelay(String relayUrl) {
    final normalized = relayUrl.trim();
    if (normalized.startsWith('ws://') || normalized.startsWith('wss://')) {
      return normalized;
    }
    return 'wss://$normalized';
  }
}
