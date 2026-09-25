import 'backend_models.dart';
import 'encrypted_payload.dart';

class ChatCryptoContext {
  const ChatCryptoContext({
    required this.chatId,
    this.requestId,
  });

  final ChatId chatId;
  final String? requestId;
}

abstract interface class ChatCrypto {
  Future<EncryptedPayload> encryptFor({
    required String plaintext,
    required IdentityId recipient,
    ChatCryptoContext? context,
  });

  Future<String> decrypt({
    required EncryptedPayload payload,
    required IdentityId sender,
    ChatCryptoContext? context,
  });
}
