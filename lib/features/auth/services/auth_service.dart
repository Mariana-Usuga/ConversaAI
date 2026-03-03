import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio de autenticación con Supabase OAuth.
class AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  /// Sesión actual del usuario (null si no está autenticado).
  Session? get currentSession => _client.auth.currentSession;

  /// Usuario actual (null si no está autenticado).
  User? get currentUser => _client.auth.currentUser;

  /// Stream de cambios en el estado de autenticación.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Inicia sesión con un proveedor OAuth (Google, GitHub, etc.).
  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    try {
      await _client.auth.signInWithOAuth(
        provider,
        redirectTo: _getRedirectUrl(),
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Cierra la sesión del usuario.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// URL de redirección después del OAuth (para web).
  /// Añade tu URL de Vercel en Supabase: Auth > URL Configuration > Redirect URLs
  String? _getRedirectUrl() {
    if (kIsWeb) {
      return Uri.base.origin;
    }
    return null;
  }
}
