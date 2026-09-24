import 'dart:async';

import 'package:dart_nostr/dart_nostr.dart';

import '../../geo/domain/geo_privacy.dart';
import '../../requests/domain/help_request.dart';
import '../domain/nostr_event.dart' as app_nostr;
import '../domain/we_ryadom_nostr.dart';
import 'nostr_identity_store.dart';
import 'ryadom_nip17_chat.dart';

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

  StreamSubscription<NostrEvent>? _publicSubscription;
  StreamSubscription<NostrEvent>? _dmSubscription;
  NostrEventsStream? _publicSubscriptionStream;
  NostrEventsStream? _dmSubscriptionStream;
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

    final publicSubscriptionResult = _nostr.subscribe(
      NostrFilter(
        kinds: const [
          weRyadomRequestKind,
          weRyadomResponseKind,
          weRyadomRequestStateKind,
        ],
        t: const ['we-ryadom'],
        since: DateTime.now().subtract(const Duration(days: 1)),
        limit: 500,
      ),
    );
    final dmSubscriptionResult = _nostr.subscribe(
      NostrFilter(
        kinds: const [nostrNip17GiftWrapKind],
        p: [identity.publicKey],
        since: DateTime.now().subtract(const Duration(days: 2)),
        limit: 500,
      ),
    );

    publicSubscriptionResult.fold(
      (stream) {
        _publicSubscriptionStream = stream;
        _publicSubscription = stream.stream.listen(
          (event) => unawaited(_handleRelayEvent(event)),
        );
      },
      (_) {},
    );
    dmSubscriptionResult.fold(
      (stream) {
        _dmSubscriptionStream = stream;
        _dmSubscription = stream.stream.listen(
          (event) => unawaited(_handleRelayEvent(event)),
        );
      },
      (_) {},
    );

    final connected =
        publicSubscriptionResult.isSuccess && dmSubscriptionResult.isSuccess;
    final error = publicSubscriptionResult.failureOrNull?.message ??
        dmSubscriptionResult.failureOrNull?.message;

    return NostrGatewayState(
      relayUrl: normalizedRelay,
      isConnected: connected,
      isConnecting: false,
      connectionStatus: connected
          ? NostrConnectionStatus.online
          : NostrConnectionStatus.offline,
      errorMessage: error,
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
    if (identity == null ||
        !_nostr.isConnected ||
        message.trim().isEmpty ||
        message.length > 12000) {
      return null;
    }

    final sender = NostrKeyPairs(private: identity.privateKey);
    final rumor = RyadomNip17Chat.createRumor(
      sender: sender,
      recipientPubkey: recipientPubkey,
      requestId: requestId,
      message: message,
    );

    final recipientWrap = await RyadomNip17Chat.wrapRumor(
      rumor: rumor,
      sender: sender,
      recipientPubkey: recipientPubkey,
    );
    final recipientResult = await _nostr.publish(recipientWrap);
    if (!recipientResult.isSuccess) {
      return null;
    }

    // NIP-17 keeps an encrypted sender copy too. It lets a restarted app
    // rebuild chat history from the relay without persisting plaintext locally.
    final senderWrap = await RyadomNip17Chat.wrapRumor(
      rumor: rumor,
      sender: sender,
      recipientPubkey: identity.publicKey,
    );
    await _nostr.publish(senderWrap);

    _emitAppEvent(
      app_nostr.NostrEvent(
        kind: weRyadomChatMessageKind,
        content: {
          'request_id': requestId,
          'message': message,
        },
        tags: rumor.tags ?? const <List<String>>[],
        pubkey: identity.publicKey,
        createdAt: rumor.createdAt,
      ),
      fallbackId: rumor.id ??
          'msg-$requestId-${DateTime.now().millisecondsSinceEpoch}',
    );

    return rumor.id;
  }

  @override
  Future<void> dispose() async {
    await _closeSubscription();
    await _nostr.disconnect();
    await _eventsController.close();
  }

  Future<void> _handleRelayEvent(NostrEvent relayEvent) async {
    final eventId = relayEvent.id;
    if (eventId == null || eventId.isEmpty || !relayEvent.isVerified()) {
      return;
    }

    final identity = _identity;
    if (relayEvent.kind == nostrNip17GiftWrapKind) {
      if (identity == null) {
        return;
      }
      final decoded = await RyadomNip17Chat.unwrap(
        giftWrap: relayEvent,
        recipient: NostrKeyPairs(private: identity.privateKey),
      );
      if (decoded == null) {
        return;
      }

      _emitAppEvent(
        app_nostr.NostrEvent(
          kind: weRyadomChatMessageKind,
          content: {
            'request_id': decoded.requestId,
            'message': decoded.message,
          },
          tags: decoded.tags,
          pubkey: decoded.senderPubkey,
          createdAt: decoded.createdAt,
        ),
        fallbackId: decoded.id,
      );
      return;
    }

    _emitPublishedEvent(relayEvent, fallbackId: eventId);
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

    final appEvent = WeRyadomNostr.tryFromRelayEvent(relayEvent);
    if (appEvent == null) {
      return;
    }
    _eventsController.add(
      app_nostr.NostrEventRecord(
        id: eventId,
        event: appEvent,
        sequence: _sequence++,
      ),
    );
  }

  Future<void> _closeSubscription() async {
    await _publicSubscription?.cancel();
    await _dmSubscription?.cancel();
    _publicSubscription = null;
    _dmSubscription = null;
    _publicSubscriptionStream?.close();
    _dmSubscriptionStream?.close();
    _publicSubscriptionStream = null;
    _dmSubscriptionStream = null;
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
