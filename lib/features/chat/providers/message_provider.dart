import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/message_model.dart';
import '../data/repositories/message_repository.dart';
import 'conversation_provider.dart';

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository();
});

/// Mensajes de una conversación específica.
final messagesProvider =
    FutureProvider.family<List<Message>, String>((ref, conversationId) async {
  final repo = ref.watch(messageRepositoryProvider);
  return repo.getMessages(conversationId);
});

/// Mensajes pendientes (optimistas) - sobrevive a rebuilds del ChatScreen.
/// Se usa cuando el router o auth refrescan y recrean la pantalla.
final pendingMessagesProvider =
    StateProvider.family<List<Message>, String>((ref, conversationId) => []);
