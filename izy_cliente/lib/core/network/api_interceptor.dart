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
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _handleUnauthorized();
    }
    
    handler.next(err);
  }

  Future<void> _handleUnauthorized() async {
    final box = await Hive.openBox('auth');
    await box.clear();
  }
}
