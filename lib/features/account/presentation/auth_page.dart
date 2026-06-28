import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_screen.dart';
import '../application/firebase_auth_service.dart';

enum _AuthMode { signIn, register }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  _AuthMode mode = _AuthMode.signIn;
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => loading = true);
    try {
      await action();
      if (mounted) Navigator.of(context).maybePop();
    } on ScanLenoAuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_authErrorMessage(context, error.code))),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.authFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _emailAction() {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (mode == _AuthMode.register) {
      return _run(
        () => firebaseAuthService.registerWithEmail(email, password),
      );
    }
    return _run(() => firebaseAuthService.signInWithEmail(email, password));
  }

  Future<void> _resetPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;
    await _run(() => firebaseAuthService.resetPassword(email));
  }

  String _authErrorMessage(BuildContext context, String code) {
    final l = context.l10n;
    return switch (code) {
      'googleSignInCancelled' => l.googleSignInCancelled,
      'googleSignInPopupBlocked' => l.googleSignInPopupBlocked,
      'googleSignInUnauthorizedDomain' => l.googleSignInUnauthorizedDomain,
      'googleSignInConfigError' => l.googleSignInConfigError,
      'googleSignInUiUnavailable' => l.googleSignInUiUnavailable,
      'googleSignInInterrupted' => l.googleSignInInterrupted,
      'networkError' => l.networkError,
      'accountExistsWithDifferentCredential' => l.accountExistsWithDifferentCredential,
      _ => l.googleSignInFailed,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppScreen(
      title: l.signIn,
      showBack: true,
      child: ListView(
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.softBlue,
                  child: Icon(Icons.person_rounded, color: AppColors.interactive),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l.accountAccess,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l.accountOptionalDescription,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SegmentedButton<_AuthMode>(
            segments: [
              ButtonSegment(value: _AuthMode.signIn, label: Text(l.signIn)),
              ButtonSegment(value: _AuthMode.register, label: Text(l.createAccount)),
            ],
            selected: {mode},
            onSelectionChanged: (value) => setState(() => mode = value.first),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: l.email,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l.password,
              prefixIcon: const Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: loading ? null : _emailAction,
            icon: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login_rounded),
            label: Text(mode == _AuthMode.register ? l.createAccount : l.signIn),
          ),
          TextButton(onPressed: loading ? null : _resetPassword, child: Text(l.forgotPassword)),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: loading
                ? null
                : () => _run(firebaseAuthService.signInAnonymously),
            icon: const Icon(Icons.person_outline_rounded),
            label: Text(l.continueAsGuest),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: loading
                ? null
                : () => _run(firebaseAuthService.signInWithGoogle),
            icon: const Icon(Icons.g_mobiledata_rounded),
            label: Text(l.signInWithGoogle),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: loading
                ? null
                : () => _run(firebaseAuthService.signInWithApple),
            icon: const Icon(Icons.apple_rounded),
            label: Text(l.signInWithApple),
          ),
        ],
      ),
    );
  }
}
