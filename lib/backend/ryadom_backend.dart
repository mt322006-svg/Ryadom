import '../features/requests/domain/help_request.dart';
import 'backend_models.dart';
import 'encrypted_payload.dart';

abstract interface class RyadomBackend {
  Stream<List<HelpRequest>> watchNearbyRequests({
    required SearchRadius radius,
    ApproxArea? area,
  });

  Future<String> publishRequest(NewHelpRequest request);

  Future<void> respondToRequest({
    required String requestId,
    required HelpResponse response,
  });

  Future<void> selectHelper({
    required String requestId,
    required IdentityId helper,
  });

  Stream<EncryptedChatMessage> watchChat({
    required ChatId chatId,
  });

  Future<void> sendEncryptedChat({
    required ChatId chatId,
    required IdentityId recipient,
    required EncryptedPayload payload,
  });

  Future<void> updateRequestState(RequestStateUpdate update);

  Future<void> report(BackendReport report);

  Future<void> block(IdentityId identity);

  Future<void> unblock(IdentityId identity);

  Future<void> dispose();
}
