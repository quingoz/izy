import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => user != null && token != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState()) {
    _loadSavedAuth();
  }

  Future<void> _loadSavedAuth() async {
    final box = await Hive.openBox('auth');
    final token = box.get('token');
    final userData = box.get('user');

    if (token != null && userData != null) {
      state = state.copyWith(
        token: token,
        user: User.fromJson(Map<String, dynamic>.from(userData)),
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.login(email, password);
      
      final box = await Hive.openBox('auth');
      await box.put('token', result['token']);
      await box.put('user', result['user']);

      state = state.copyWith(
        user: User.fromJson(result['user']),
        token: result['token'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.register(data);
      
      final box = await Hive.openBox('auth');
      await box.put('token', result['token']);
      await box.put('user', result['user']);

      state = state.copyWith(
        user: User.fromJson(result['user']),
        token: result['token'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } finally {
      final box = await Hive.openBox('auth');
      await box.clear();
      state = AuthState();
    }
  }

  Future<void> refreshUser() async {
    try {
      final userData = await _repository.me();
      state = state.copyWith(
        user: User.fromJson(userData),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
