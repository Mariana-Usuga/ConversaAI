import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/chat_api_service.dart';

final chatApiServiceProvider = Provider<ChatApiService>((ref) {
  return ChatApiService();
});
