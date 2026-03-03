import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/message_model.dart';

/// Repositorio para operaciones CRUD de mensajes.
class MessageRepository {
  MessageRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Obtiene todos los mensajes de una conversación, ordenados por fecha.
  Future<List<Message>> getMessages(String conversationId) async {
    final response = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Inserta un nuevo mensaje.
  Future<Message> insertMessage({
    required String conversationId,
    required MessageRole role,
    required String content,
    String? model,
    int tokensUsed = 0,
  }) async {
    final response = await _client.from('messages').insert({
      'conversation_id': conversationId,
      'role': role.name,
      'content': content,
      'model': model,
      'tokens_used': tokensUsed,
    }).select().single();

    return Message.fromJson(response as Map<String, dynamic>);
  }
}
