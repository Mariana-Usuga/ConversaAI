import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../data/models/conversation_model.dart';
import '../../providers/active_conversation_provider.dart';
import '../../providers/conversation_provider.dart';
import 'conversation_item.dart';
import '../../../../core/router/app_router.dart';

/// Drawer/sidebar con la lista de conversaciones.
class ChatListDrawer extends ConsumerWidget {
  const ChatListDrawer({
    super.key,
    this.onConversationSelected,
    this.isSidebar = false,
  });

  /// Callback cuando se selecciona una conversación (para cerrar drawer en mobile).
  final VoidCallback? onConversationSelected;

  /// Si true, renderiza como sidebar fijo (sin Drawer).
  final bool isSidebar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final activeId = ref.watch(activeConversationIdProvider);
    final user = ref.watch(currentUserProvider);

    final content = Column(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'ConversaAI',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person),
                      onPressed: () {
                        Navigator.pop(context);
                        context.push(AppRoutes.profile);
                      },
                    ),
                  ],
                ),
                if (user?.email != null)
                  Text(
                    user!.email!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: conversationsAsync.when(
            data: (conversations) {
              if (conversations.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No hay conversaciones.\nToca "+" para crear una nueva.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conv = conversations[index];
                  return ConversationItem(
                    conversation: conv,
                    isSelected: conv.id == activeId,
                    onTap: () {
                      ref.read(activeConversationIdProvider.notifier).state =
                          conv.id;
                      Navigator.pop(context);
                      onConversationSelected?.call();
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error: $err',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    if (isSidebar) return content;
    return Drawer(child: content);
  }
}
