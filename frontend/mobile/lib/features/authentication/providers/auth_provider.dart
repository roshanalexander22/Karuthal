import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient);
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    checkStatus();
  }

  Future<void> checkStatus() async {
    final isAuth = await _repo.checkAuthStatus();
    state = state.copyWith(isAuthenticated: isAuth);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final success = await _repo.login(email, password);
    state = state.copyWith(
      isAuthenticated: success,
      isLoading: false,
      errorMessage: success
          ? null
          : 'Invalid credentials. Please verify your email and password.',
    );
    return success;
  }

  Future<bool> register(
    String email,
    String password,
    String fullName, {
    String? phone,
    String languagePreference = 'ml',
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final success = await _repo.register(
      email,
      password,
      fullName,
      phone: phone,
      languagePreference: languagePreference,
    );
    state = state.copyWith(
      isAuthenticated: success,
      isLoading: false,
      errorMessage: success
          ? null
          : 'Registration failed. An account with this email may already exist.',
    );
    return success;
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _repo.logout();
    state = const AuthState(isAuthenticated: false, isLoading: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
