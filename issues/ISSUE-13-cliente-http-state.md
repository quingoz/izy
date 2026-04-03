# Issue #13: Cliente HTTP y State Management

**Epic:** PWA Cliente  
**Prioridad:** Alta  
**Estimación:** 2 días  
**Sprint:** Sprint 2

---

## Descripción

Configurar cliente HTTP con Dio, interceptores y state management con Riverpod para la PWA.

## Objetivos

- Cliente Dio configurado
- Interceptores de autenticación
- Providers Riverpod para API
- Manejo de errores centralizado
- Storage local con Hive

## Tareas Técnicas

### 1. Dio Client

**Archivo:** `lib/core/network/dio_client.dart`

```dart
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'api_interceptor.dart';

class DioClient {
  static Dio? _instance;

  static Dio get instance {
    _instance ??= Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.apiTimeout,
        receiveTimeout: AppConfig.apiTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    )..interceptors.addAll([
        ApiInterceptor(),
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
        ),
      ]);

    return _instance!;
  }
}
```

### 2. API Interceptor

**Archivo:** `lib/core/network/api_interceptor.dart`

```dart
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final box = await Hive.openBox('auth');
    final token = box.get('token');
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expirado, limpiar y redirigir a login
      _handleUnauthorized();
    }
    
    handler.next(err);
  }

  Future<void> _handleUnauthorized() async {
    final box = await Hive.openBox('auth');
    await box.clear();
    // Navegar a login
  }
}
```

### 3. API Service Base

**Archivo:** `lib/core/network/api_service.dart`

```dart
import 'package:dio/dio.dart';
import 'dio_client.dart';

class ApiService {
  final Dio _dio = DioClient.instance;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Tiempo de espera agotado');
      case DioExceptionType.badResponse:
        return Exception(error.response?.data['message'] ?? 'Error del servidor');
      case DioExceptionType.cancel:
        return Exception('Solicitud cancelada');
      default:
        return Exception('Error de conexión');
    }
  }
}
```

### 4. Auth Provider

**Archivo:** `lib/features/auth/presentation/providers/auth_provider.dart`

```dart
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
        user: User.fromJson(userData),
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

  Future<void> logout() async {
    try {
      await _repository.logout();
    } finally {
      final box = await Hive.openBox('auth');
      await box.clear();
      state = AuthState();
    }
  }
}
```

### 5. Auth Repository

**Archivo:** `lib/features/auth/data/repositories/auth_repository.dart`

```dart
import '../../../../core/network/api_service.dart';

class AuthRepository {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
      'device_name': 'web',
    });

    return response['data'];
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await _api.post('/auth/register', data: data);
    return response['data'];
  }

  Future<void> logout() async {
    await _api.post('/auth/logout');
  }

  Future<Map<String, dynamic>> me() async {
    final response = await _api.get('/auth/me');
    return response['data'];
  }
}
```

### 6. User Entity

**Archivo:** `lib/features/auth/domain/entities/user.dart`

```dart
class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'avatar_url': avatarUrl,
    };
  }
}
```

## Definición de Hecho (DoD)

- [ ] Dio client configurado
- [ ] Interceptores funcionando
- [ ] Auth provider con Riverpod
- [ ] Storage local con Hive
- [ ] Manejo de errores centralizado
- [ ] Login/logout funcional
- [ ] Tests unitarios pasando

## Comandos de Verificación

```bash
flutter test
flutter analyze
```

## Dependencias

- Issue #12: Setup Proyecto Flutter Web

## Siguiente Issue

Issue #14: Sistema de Branding Dinámico
