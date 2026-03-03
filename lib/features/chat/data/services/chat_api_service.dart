import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio para llamar a la Edge Function de chat-completion.
class ChatApiService {
  ChatApiService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Envía un mensaje a la IA y obtiene la respuesta.
  /// La Edge Function guarda el mensaje del usuario y la respuesta en la BD.
  Future<String> sendMessage({
    required String conversationId,
    required String message,
  }) async {
    var session = _client.auth.currentSession;
    if (session == null) {
      throw Exception('Debes iniciar sesión para enviar mensajes');
    }

    try {
      final refreshed = await _client.auth.refreshSession();
      session = refreshed.session ?? session;
    } catch (_) {}

    final token = session!.accessToken;
    final response = await _client.functions.invoke(
      'chat-completion',
      body: {
        'message': message,
        'conversation_id': conversationId,
      },
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.status != 200) {
      throw Exception(
        response.data?['error'] ?? 'Error ${response.status}',
      );
    }

    final content = response.data?['content'] as String?;
    if (content == null) {
      throw Exception('Respuesta vacía de la IA');
    }

    return content;
  }
}
