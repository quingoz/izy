class AppConfig {
  static const String appName = 'IZY Cliente';
  static const String apiBaseUrl = 'http://localhost:8000/api';
  static const String wsUrl = 'http://localhost:8000';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int itemsPerPage = 20;

  static void initialize() {
    // Inicialización de configuraciones
  }
}
