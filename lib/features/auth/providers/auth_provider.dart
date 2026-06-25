import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';

class AuthState {
  final bool isAuthenticated;
  final Map<String, dynamic>? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAdmin => user?['is_admin'] == true;

  AuthState copyWith({
    bool? isAuthenticated,
    Map<String, dynamic>? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api;

  AuthNotifier(this._api) : super(const AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = _api.token;
    if (token == null) return;
    try {
      state = state.copyWith(isLoading: true);
      final res = await _api.getMe();
      state = AuthState(isAuthenticated: true, user: res.data);
    } catch (_) {
      await _api.clearToken();
      state = const AuthState();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final res = await _api.login(email, password);
      
      // Check if response contains token
      if (res.data['access_token'] == null) {
        throw Exception('No access token received');
      }
      
      await _api.saveToken(res.data['access_token']);
      final meRes = await _api.getMe();
      state = AuthState(isAuthenticated: true, user: meRes.data, isLoading: false);
      return true;
    } catch (e) {
      String errorMessage = 'Invalid email or password';
      
      // More specific error messages
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          errorMessage = 'Invalid email or password';
        } else if (e.response?.statusCode == 404) {
          errorMessage = 'User not found';
        } else if (e.type == DioExceptionType.connectionTimeout) {
          errorMessage = 'Connection timeout. Please check your internet.';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'Cannot connect to server. Please check if the server is running.';
        } else {
          errorMessage = 'An error occurred. Please try again.';
        }
      }
      
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _api.register(data);
      return await login(data['email'], data['password']);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Registration failed. Email may already be in use.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _api.clearToken();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(apiServiceProvider));
});
