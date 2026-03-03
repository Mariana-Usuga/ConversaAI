import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/conversation_model.dart';
import '../data/repositories/conversation_repository.dart';

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ConversationRepository();
});

/// Lista de conversaciones del usuario actual.
final conversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final repo = ref.watch(conversationRepositoryProvider);
  return repo.getConversations();
});
