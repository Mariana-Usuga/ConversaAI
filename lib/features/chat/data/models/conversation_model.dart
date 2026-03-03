/// Modelo de conversación.
class Conversation {
  const Conversation({
    required this.id,
    required this.userId,
    required this.title,
    this.model = 'gpt-4',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required this.lastMessageAt,
  });

  final String id;
  final String userId;
  final String title;
  final String model;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastMessageAt;

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      model: json['model'] as String? ?? 'gpt-4',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastMessageAt: DateTime.parse(json['last_message_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'model': model,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_message_at': lastMessageAt.toIso8601String(),
    };
  }
}
