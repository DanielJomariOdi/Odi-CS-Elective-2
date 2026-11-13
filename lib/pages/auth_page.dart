import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../state/auth_controller.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key, required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        final signedIn = authController.isSignedIn;
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(title: const Text('Account')),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            signedIn
                                ? Icons.account_circle_rounded
                                : Icons.lock_outline_rounded,
                            color: theme.colorScheme.primary,
                            size: 56,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            signedIn ? 'Your Google account' : 'Welcome to Odi Shop',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 12),
                          if (signedIn) ...[
                            Text(
                              authController.displayName,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium,
                            ),
                            if (authController.user?.email != null)
                              Text(
                                authController.user!.email!,
                                textAlign: TextAlign.center,
                              ),
                          ] else
                            const Text(
                              'Sign in securely with your Google account.',
                              textAlign: TextAlign.center,
                            ),
                          if (authController.error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              authController.error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ],
                          const SizedBox(height: 24),
                          if (authController.isBusy)
                            const Center(child: CircularProgressIndicator()),
                          if (!authController.isBusy)
                            signedIn
                                ? OutlinedButton.icon(
                                    key: const Key('google-sign-out'),
                                    onPressed: authController.signOut,
                                    icon: const Icon(Icons.logout_rounded),
                                    label: const Text('Sign out'),
                                  )
                                : FilledButton.icon(
                                    key: const Key('google-sign-in'),
                                    onPressed: authController.signInWithGoogle,
                                    icon: const Text(
                                      'G',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    label: const Text('Continue with Google'),
                                  ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () => context.go('/'),
                            icon: const Icon(Icons.storefront_outlined),
                            label: const Text('Browse products'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
