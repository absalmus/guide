enum AiMessageRole { user, assistant }

class AiMessage {
  const AiMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  final String id;
  final AiMessageRole role;
  final String content;
  final DateTime timestamp;
}
