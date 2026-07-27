class RequestResponder {
  const RequestResponder({
    required this.responseId,
    required this.pubkey,
    required this.message,
    required this.createdAt,
  });

  final String responseId;
  final String pubkey;
  final String message;
  final DateTime createdAt;
}