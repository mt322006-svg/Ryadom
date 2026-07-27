import '../../nostr/domain/nostr_event.dart';
import '../../nostr/domain/we_ryadom_nostr.dart';

/// Product-side guardrails on top of raw Nostr events.
class TrustGuard {
  const TrustGuard._();

  static const int maxResponsesPerHour = 12;

  static Map<String, Object?> sanitizePublicRequestContent(
    Map<String, Object?> content,
  ) {
    return Map<String, Object?>.from(content)
      ..remove('latitude')
      ..remove('longitude');
  }

  static NostrEvent sanitizePublicRequestEvent(NostrEvent event) {
    if (event.kind != weRyadomRequestKind) {
      return event;
    }

    return NostrEvent(
      kind: event.kind,
      content: sanitizePublicRequestContent(event.content),
      tags: event.tags,
      pubkey: event.pubkey,
      createdAt: event.createdAt,
      signature: event.signature,
    );
  }

  static bool isBlockedAuthor({
    required String? authorPubkey,
    required Set<String> blockedPubkeys,
  }) {
    if (authorPubkey == null || authorPubkey.isEmpty) {
      return false;
    }
    return blockedPubkeys.contains(authorPubkey);
  }

  static bool canTrustRequestStateUpdate({
    required String? eventPubkey,
    required String? requestAuthorPubkey,
  }) {
    if (eventPubkey == null ||
        eventPubkey.isEmpty ||
        requestAuthorPubkey == null ||
        requestAuthorPubkey.isEmpty) {
      return false;
    }
    return eventPubkey == requestAuthorPubkey;
  }

  static bool isChatVisibleToParticipant({
    required NostrEvent event,
    required String? currentPubkey,
    required String requestAuthorPubkey,
    required String? activeParticipantPubkey,
  }) {
    if (currentPubkey == null || currentPubkey.isEmpty) {
      return false;
    }

    final sender = event.pubkey;
    if (sender == null || sender.isEmpty) {
      return false;
    }

    if (sender == currentPubkey) {
      return true;
    }

    final allowedSenders = <String>{
      requestAuthorPubkey,
      if (activeParticipantPubkey != null && activeParticipantPubkey.isNotEmpty)
        activeParticipantPubkey,
    };
    if (!allowedSenders.contains(sender)) {
      return false;
    }

    final recipient = WeRyadomNostr.firstTagValue(event, 'p');
    if (recipient == null || recipient.isEmpty) {
      return false;
    }

    return recipient == currentPubkey;
  }
}