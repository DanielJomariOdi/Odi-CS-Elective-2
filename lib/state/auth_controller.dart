import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Must match the redirect URL in Supabase Auth settings and native platforms.
const mobileAuthRedirectUrl = 'io.odishop.app://login-callback/';

/// Provides Google OAuth sign-in and a reactive view of the Supabase session.
class AuthController extends ChangeNotifier {
  AuthController({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client {
    _subscription = _client.auth.onAuthStateChange.listen(
      (_) {
        if (!_disposed) notifyListeners();
      },
      onError: (Object error, StackTrace stackTrace) {
        if (_disposed) return;
        _error = 'Authentication failed. Please try again.';
        notifyListeners();
      },
    );
  }

  final SupabaseClient _client;
  late final StreamSubscription<AuthState> _subscription;
  bool _isBusy = false;
  bool _disposed = false;
  String? _error;

  User? get user => _client.auth.currentUser;
  bool get isSignedIn => user != null;
  bool get isBusy => _isBusy;
  String? get error => _error;

  String get displayName {
    final metadata = user?.userMetadata;
    final name = metadata?['full_name'] ?? metadata?['name'];
    if (name is String && name.trim().isNotEmpty) return name;
    return user?.email ?? 'Google account';
  }

  Future<void> signInWithGoogle() async {
    if (_isBusy) return;
    _isBusy = true;
    _error = null;
    notifyListeners();

    try {
      // OAuth launches a browser; success is reported later via auth state.
      final launched = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : mobileAuthRedirectUrl,
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );
      if (!launched) {
        _error = 'Could not open Google sign-in. Please try again.';
      }
    } on AuthException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Could not start Google sign-in. Please try again.';
    } finally {
      if (!_disposed) {
        _isBusy = false;
        notifyListeners();
      }
    }
  }

  Future<void> signOut() async {
    if (_isBusy) return;
    _isBusy = true;
    _error = null;
    notifyListeners();

    try {
      await _client.auth.signOut();
    } on AuthException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Could not sign out. Please try again.';
    } finally {
      if (!_disposed) {
        _isBusy = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription.cancel();
    super.dispose();
  }
}
