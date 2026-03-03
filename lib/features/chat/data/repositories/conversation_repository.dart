import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/conversation_model.dart';

/// Repositorio para operaciones CRUD de conversaciones.
class ConversationRepository {
  ConversationRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Obtiene todas las conversaciones del usuario actual, ordenadas por última actividad.
  Future<List<Conversation>> getConversations() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    final response = await _client
        .from('conversations')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('last_message_at', ascending: false);

    return (response as List)
        .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Crea una nueva conversación.
  Future<Conversation> createConversation({
    String title = 'Nueva conversación',
    String model = 'gpt-4',
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    final response = await _client.from('conversations').insert({
      'user_id': userId,
      'title': title,
      'model': model,
    }).select().single();

    return Conversation.fromJson(response as Map<String, dynamic>);
  }

  /// Actualiza el título de una conversación.
  Future<void> updateTitle(String conversationId, String title) async {
    await _client
        .from('conversations')
        .update({'title': title, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', conversationId);
  }

  /// Elimina (desactiva) una conversación.
  Future<void> deleteConversation(String conversationId) async {
    await _client
        .from('conversations')
        .update({'is_active': false, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', conversationId);
  }

  /// Elimina permanentemente una conversación y sus mensajes.
  Future<void> permanentlyDeleteConversation(String conversationId) async {
    await _client.from('conversations').delete().eq('id', conversationId);
  }
}
