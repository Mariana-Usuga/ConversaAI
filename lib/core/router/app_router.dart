import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';

/// Rutas de la aplicación.
class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String profile = '/profile';
}

/// Notifier para refrescar el redirect sin recrear el GoRouter.
/// Evita que "Refresh session" de Supabase recree el ChatScreen y pierda el estado.
final _authRefreshNotifier = ChangeNotifier();

final _authRefreshSetupProvider = Provider<void>((ref) {
  ref.listen(authStateProvider, (_, __) {
    _authRefreshNotifier.notifyListeners();
  });
});

final goRouterProvider = Provider<GoRouter>((ref) {
  ref.watch(_authRefreshSetupProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: _authRefreshNotifier,
    redirect: (context, state) {
      final container = ProviderScope.containerOf(context);
      final authState = container.read(authStateProvider);
      final isLoading = authState.isLoading;
      final isLoggedIn = authState.valueOrNull != null;
      final isLoginRoute = state.matchedLocation == AppRoutes.login;

      if (isLoading) return null;

      if (!isLoggedIn && !isLoginRoute) {
        return AppRoutes.login;
      }

      if (isLoggedIn && isLoginRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});

