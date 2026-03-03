import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/auth_provider.dart';

/// Pantalla de login con botones OAuth.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ConversaAI',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Inicia sesión para continuar',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 48),
                _OAuthButton(
                  provider: OAuthProvider.google,
                  label: 'Continuar con Google',
                  icon: Icons.g_mobiledata,
                ),
                const SizedBox(height: 16),
                _OAuthButton(
                  provider: OAuthProvider.github,
                  label: 'Continuar con GitHub',
                  icon: Icons.code,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OAuthButton extends ConsumerStatefulWidget {
  const _OAuthButton({
    required this.provider,
    required this.label,
    required this.icon,
  });

  final OAuthProvider provider;
  final String label;
  final IconData icon;

  @override
  ConsumerState<_OAuthButton> createState() => _OAuthButtonState();
}

class _OAuthButtonState extends ConsumerState<_OAuthButton> {
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithOAuth(widget.provider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar sesión: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isLoading ? null : _signIn,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(widget.icon),
        label: Text(_isLoading ? 'Conectando...' : widget.label),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
