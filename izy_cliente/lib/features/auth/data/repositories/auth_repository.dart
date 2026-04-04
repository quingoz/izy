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
