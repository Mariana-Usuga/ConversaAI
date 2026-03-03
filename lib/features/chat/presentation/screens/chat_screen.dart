import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';
import '../../providers/active_conversation_provider.dart';
import '../../providers/chat_api_provider.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/message_provider.dart';
import '../widgets/chat_list_drawer.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

/// Pantalla principal del chat.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSending = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _createConversation() async {
    try {
      final repo = ref.read(conversationRepositoryProvider);
      final conversation = await repo.createConversation();
      ref.invalidate(conversationsProvider);
      ref.read(activeConversationIdProvider.notifier).state = conversation.id;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _sendMessage(String text) async {
    final conversationId = ref.read(activeConversationIdProvider);
    if (conversationId == null) return;

    setState(() => _isSending = true);

    // 1. Mostrar mensaje del usuario de forma optimista (inmediato)
    final now = DateTime.now();
    final userMessage = Message(
      id: 'pending-user-${now.millisecondsSinceEpoch}',
      conversationId: conversationId,
      role: MessageRole.user,
      content: text,
      createdAt: now,
    );
    ref.read(pendingMessagesProvider(conversationId).notifier).state = [
      ...ref.read(pendingMessagesProvider(conversationId)),
      userMessage,
    ];
    _scrollToBottom();

    try {
      final chatApi = ref.read(chatApiServiceProvider);
      final convRepo = ref.read(conversationRepositoryProvider);

      final messagesBefore =
          await ref.read(messageRepositoryProvider).getMessages(conversationId);

      // 2. Llamar a la API (puede tardar varios segundos)
      final assistantContent = await chatApi.sendMessage(
        conversationId: conversationId,
        message: text,
      );

      // 3. Añadir respuesta de la IA con setState (garantiza rebuild de la UI)
      final assistantMessage = Message(
        id: 'pending-assistant-${DateTime.now().millisecondsSinceEpoch}',
        conversationId: conversationId,
        role: MessageRole.assistant,
        content: assistantContent,
        createdAt: DateTime.now(),
      );
      if (mounted) {
        ref.read(pendingMessagesProvider(conversationId).notifier).state = [
          ...ref.read(pendingMessagesProvider(conversationId)),
          assistantMessage,
        ];
        _scrollToBottom();
      }

      // No invalidar aquí: evita pasar a loading y mostrar pantalla vacía.
      // Los mensajes se sincronizarán al cambiar de conversación o recargar.

      if (messagesBefore.isEmpty) {
        final title = text.length > 50 ? '${text.substring(0, 50)}...' : text;
        await convRepo.updateTitle(conversationId, title);
        ref.invalidate(conversationsProvider);
      }
    } catch (e) {
      if (mounted) {
        ref.read(pendingMessagesProvider(conversationId).notifier).state = [];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeId = ref.watch(activeConversationIdProvider);
    final isWideScreen = MediaQuery.of(context).size.width >= 600;

    // Limpiar pending solo al cambiar de conversación
    ref.listen(activeConversationIdProvider, (prev, next) {
      if (prev != null && next != null && prev != next) {
        ref.read(pendingMessagesProvider(prev).notifier).state = [];
        ref.invalidate(messagesProvider(next));
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: isWideScreen
            ? null
            : IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
        title: activeId != null
            ? _ConversationTitle(conversationId: activeId)
            : const Text('ConversaAI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createConversation,
            tooltip: 'Nueva conversación',
          ),
        ],
      ),
      drawer: isWideScreen ? null : const ChatListDrawer(),
      body: Row(
        children: [
          if (isWideScreen)
            SizedBox(
              width: 280,
              child: ChatListDrawer(isSidebar: true),
            ),
          Expanded(
            child: activeId == null
                ? _EmptyState(onCreateConversation: _createConversation)
                : _ChatContent(
                    conversationId: activeId,
                    scrollController: _scrollController,
                    onSendMessage: _sendMessage,
                    isSending: _isSending,
                    onScrollToBottom: _scrollToBottom,
                    onClearPending: () {
                      ref.read(pendingMessagesProvider(activeId).notifier).state =
                          [];
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTitle extends ConsumerWidget {
  const _ConversationTitle({required this.conversationId});

  final String conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return conversationsAsync.when(
      data: (conversations) {
        Conversation? conv;
        for (final c in conversations) {
          if (c.id == conversationId) {
            conv = c;
            break;
          }
        }
        return Text(conv?.title ?? 'Conversación');
      },
      loading: () => const Text('Conversación'),
      error: (_, __) => const Text('Conversación'),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreateConversation});

  final VoidCallback onCreateConversation;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 24),
          Text(
            'No hay conversación seleccionada',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Crea una nueva o selecciona una de la lista',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onCreateConversation,
            icon: const Icon(Icons.add),
            label: const Text('Nueva conversación'),
          ),
        ],
      ),
    );
  }
}

class _ChatContent extends ConsumerWidget {
  const _ChatContent({
    required this.conversationId,
    required this.scrollController,
    required this.onSendMessage,
    required this.isSending,
    required this.onScrollToBottom,
    this.onClearPending,
  });

  final String conversationId;
  final ScrollController scrollController;
  final void Function(String) onSendMessage;
  final bool isSending;
  final VoidCallback onScrollToBottom;
  final VoidCallback? onClearPending;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messagesProvider(conversationId));
    final pending = ref.watch(pendingMessagesProvider(conversationId));

    return Column(
      children: [
        Expanded(
          child: messagesAsync.when(
            data: (messages) {
              final display = _mergeMessages(messages, pending);
              if (display.isEmpty) {
                return Center(
                  child: Text(
                    'Escribe un mensaje para comenzar',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                );
              }
              return _buildMessageList(display);
            },
            loading: () {
              // Con pending: mostrarlos aunque el provider esté en loading
              if (pending.isNotEmpty) {
                return _buildMessageList(pending);
              }
              return const Center(child: CircularProgressIndicator());
            },
            error: (err, _) {
              if (pending.isNotEmpty) {
                return _buildMessageList(pending);
              }
              return Center(
                child: Text(
                  'Error: $err',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            },
          ),
        ),
        MessageInput(
          onSend: onSendMessage,
          enabled: true,
          isLoading: isSending,
        ),
      ],
    );
  }

  List<Message> _mergeMessages(List<Message> fromDb, List<Message> pending) {
    if (pending.isEmpty) return fromDb;
    if (fromDb.isEmpty) return pending;
    // Si el último de DB coincide con el último pending, el provider ya los tiene
    final lastDb = fromDb.last;
    final lastPending = pending.last;
    if (lastDb.content == lastPending.content && lastDb.role == lastPending.role) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onClearPending?.call();
      });
      return fromDb;
    }
    return [...fromDb, ...pending];
  }

  Widget _buildMessageList(List<Message> messages) {
    return ListView.builder(
      key: ValueKey('msg-${messages.length}-${messages.lastOrNull?.id}'),
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) => MessageBubble(message: messages[index]),
    );
  }
}
