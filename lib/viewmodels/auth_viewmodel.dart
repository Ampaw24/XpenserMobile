import 'package:expenser/services/auth/firebase_auth_service.dart';
import 'package:expenser/services/auth/i_auth_service.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
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

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _authService.signInWithGoogle();
    if (result.cancelled) {
      state = state.copyWith(isLoading: false);
      return;
    }
    if (!result.isSuccess) {
      state = state.copyWith(isLoading: false, errorMessage: result.error);
      return;
    }
    await ref.read(settingsProvider.notifier).setLoggedIn(
          true,
          userName: result.userName!,
          uid: result.uid,
          photoUrl: result.photoUrl,
          isNewUser: result.isNewUser,
        );
    state = const AuthState();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _authService.signInWithEmailPassword(email, password);
    if (!result.isSuccess) {
      state = state.copyWith(isLoading: false, errorMessage: result.error);
      return;
    }
    await ref.read(settingsProvider.notifier).setLoggedIn(
          true,
          userName: result.userName!,
          uid: result.uid,
          isNewUser: result.isNewUser,
        );
    state = const AuthState();
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
    await ref.read(settingsProvider.notifier).setLoggedIn(
          true,
          userName: result.userName!,
          uid: result.uid,
          isNewUser: result.isNewUser,
        );
    state = const AuthState();
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.signOut();
      await ref.read(settingsProvider.notifier).setLoggedIn(false);
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: 'Sign out failed. Please try again.');
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
          isLoading: false, errorMessage: 'Failed to send reset email.');
    }
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
