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
