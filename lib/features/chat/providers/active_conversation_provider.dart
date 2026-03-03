import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ID de la conversación actualmente seleccionada.
/// Null si no hay ninguna seleccionada.
final activeConversationIdProvider = StateProvider<String?>((ref) => null);
