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

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (email.isEmpty || !email.contains('@')) {
      state = state.copyWith(isLoading: false, errorMessage: 'Enter a valid email');
      return;
    }
    if (password.length < 6) {
      state = state.copyWith(isLoading: false, errorMessage: 'Password too short');
      return;
    }
    final name = email.split('@').first;
    await ref.read(settingsProvider.notifier).setLoggedIn(true, userName: name);
    state = const AuthState();
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (name.trim().isEmpty) {
      state = state.copyWith(isLoading: false, errorMessage: 'Name is required');
      return;
    }
    if (!email.contains('@')) {
      state = state.copyWith(isLoading: false, errorMessage: 'Enter a valid email');
      return;
    }
    if (password.length < 6) {
      state = state.copyWith(isLoading: false, errorMessage: 'Password too short');
      return;
    }
    await ref.read(settingsProvider.notifier).setLoggedIn(true, userName: name.trim());
    state = const AuthState();
  }

  Future<void> logout() async {
    await ref.read(settingsProvider.notifier).setLoggedIn(false);
    state = const AuthState();
  }

  void forgotPassword(String email) {
    state = state.copyWith(
      errorMessage: email.contains('@')
          ? null
          : 'Enter a valid email address',
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
