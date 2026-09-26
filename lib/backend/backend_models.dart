import '../features/requests/domain/help_request.dart';
import 'encrypted_payload.dart';

class ApproxArea {
  const ApproxArea({
    required this.bucket,
    required this.label,
  });

  final String bucket;
  final String label;
}

class SearchRadius {
  const SearchRadius(this.meters) : assert(meters > 0);

  final int meters;
}

class NewHelpRequest {
  const NewHelpRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.compensation,
    required this.areaLabel,
    required this.timeLabel,
    required this.urgency,
    required this.approxArea,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final RequestCompensation compensation;
  final String areaLabel;
  final String timeLabel;
  final RequestUrgency urgency;
  final ApproxArea approxArea;
  final DateTime? createdAt;
}

class HelpResponse {
  const HelpResponse({required this.message});

  final String message;
}

class RequestStateUpdate {
  const RequestStateUpdate({
    required this.requestId,
    required this.status,
    this.note,
    this.helperIdentity,
    this.rating,
  });

  final String requestId;
  final RequestStatus status;
  final String? note;
  final IdentityId? helperIdentity;
  final int? rating;
}

class ChatId {
  const ChatId(this.value);

  final String value;
}

class IdentityId {
  const IdentityId(this.value);

  final String value;
}

class EncryptedChatMessage {
  const EncryptedChatMessage({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.recipient,
    required this.payload,
    required this.createdAt,
  });

  final String id;
  final ChatId chatId;
  final IdentityId sender;
  final IdentityId recipient;
  final EncryptedPayload payload;
  final DateTime createdAt;
}

class BackendReport {
  const BackendReport({
    required this.reportedIdentity,
    required this.reason,
    this.requestId,
    this.evidence = const <EncryptedPayload>[],
  });

  final IdentityId reportedIdentity;
  final String reason;
  final String? requestId;

  /// Evidence is explicit user-submitted encrypted material.
  /// Backends must not gain ambient plaintext chat access for moderation.
  final List<EncryptedPayload> evidence;
}
