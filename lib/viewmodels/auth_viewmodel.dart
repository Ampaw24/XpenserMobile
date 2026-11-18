import 'package:expenser/data/repositories/notification_repository.dart';
import 'package:expenser/services/auth/auth_result.dart';
import 'package:expenser/services/auth/firebase_auth_service.dart';
import 'package:expenser/services/auth/i_auth_service.dart';
import 'package:expenser/services/notification/fcm_service.dart';
import 'package:expenser/services/notification/savings_reminder_service.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;

  const AuthState({this.isLoading = false, this.errorMessage});

  AuthState copyWith({bool? isLoading, String? errorMessage}) => AuthState(
    isLoading: isLoading ?? this.isLoading,
    errorMessage: errorMessage,
  );
}

final authServiceProvider = Provider<IAuthService>(
  (ref) => FirebaseAuthService(),
);

class AuthNotifier extends Notifier<AuthState> {
  late IAuthService _authService;

  @override
  AuthState build() {
    _authService = ref.read(authServiceProvider);
    return const AuthState();
  }

  Future<void> signInWithGoogle() =>
      _socialSignIn(_authService.signInWithGoogle);

  Future<void> signInWithFacebook() =>
      _socialSignIn(_authService.signInWithFacebook);

  Future<void> _socialSignIn(Future<AuthResult> Function() signIn) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await signIn();
    if (result.cancelled) {
      state = state.copyWith(isLoading: false);
      return;
    }
    if (!result.isSuccess) {
      state = state.copyWith(isLoading: false, errorMessage: result.error);
      return;
    }
    await _completeSignIn(result);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _authService.signInWithEmailPassword(email, password);
    if (!result.isSuccess) {
      state = state.copyWith(isLoading: false, errorMessage: result.error);
      return;
    }
    await _completeSignIn(result);
  }

  Future<void> register(String name, String email, String password) async {
    if (name.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Name is required');
      return;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _authService.register(name, email, password);
    if (!result.isSuccess) {
      state = state.copyWith(isLoading: false, errorMessage: result.error);
      return;
    }
    await _completeSignIn(result);
  }

  Future<void> _completeSignIn(AuthResult result) async {
    await ref
        .read(settingsProvider.notifier)
        .setLoggedIn(
          true,
          userName: result.userName!,
          uid: result.uid,
          photoUrl: result.photoUrl,
          isNewUser: result.isNewUser,
          countryCode: result.countryCode,
          currencyCode: result.currencyCode,
        );
    await ref.read(fcmServiceProvider).initialize(result.uid!);
    if (!result.isNewUser) _warnIfLocaleMissing(result.uid!);
    state = const AuthState();
  }

  /// Existing accounts created before country and currency were required
  /// get a one-off notification; the setup screen then blocks the app.
  void _warnIfLocaleMissing(String uid) {
    if (ref.read(settingsProvider).hasLocale) return;
    final id = 'profile-locale-missing-$uid';
    if (ref.read(notificationRepositoryProvider).exists(id)) return;
    ref
        .read(fcmServiceProvider)
        .showLocalNotification(
          id: id,
          type: 'account',
          route: '/shell/dashboard',
          title: 'Add your country and currency',
          body:
              'Your account is missing your country and currency. '
              'Add them to keep using Xpenser.',
        )
        .catchError((Object e) => debugPrint('Locale reminder failed: $e'));
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      ref.read(fcmServiceProvider).dispose();
      await ref.read(savingsReminderServiceProvider).cancelAll();
      await _authService.signOut();
      await ref.read(settingsProvider.notifier).setLoggedIn(false);
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sign out failed. Please try again.',
      );
    }
  }

  Future<void> forgotPassword(String email) async {
    if (!email.contains('@')) {
      state = state.copyWith(errorMessage: 'Enter a valid email address');
      return;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.sendPasswordReset(email);
      state = const AuthState();
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to send reset email.',
      );
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
