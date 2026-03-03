/// Rol del mensaje en la conversación.
enum MessageRole {
  user,
  assistant,
  system;

  static MessageRole fromString(String value) {
    return MessageRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MessageRole.user,
    );
  }
}

/// Modelo de mensaje.
class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.tokensUsed = 0,
    this.model,
    required this.createdAt,
  });

  final String id;
  final String conversationId;
  final MessageRole role;
  final String content;
  final int tokensUsed;
  final String? model;
  final DateTime createdAt;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      role: MessageRole.fromString(json['role'] as String),
      content: json['content'] as String,
      tokensUsed: json['tokens_used'] as int? ?? 0,
      model: json['model'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'role': role.name,
      'content': content,
      'tokens_used': tokensUsed,
      'model': model,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
