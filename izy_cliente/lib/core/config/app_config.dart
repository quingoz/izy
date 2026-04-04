enum AppFlavor {
  cliente,
  comercio,
  repartidor,
}

class AppConfig {
  static AppFlavor _currentFlavor = AppFlavor.cliente;
  
  static AppFlavor get currentFlavor => _currentFlavor;
  
  static String get appName {
    switch (_currentFlavor) {
      case AppFlavor.cliente:
        return 'IZY Cliente';
      case AppFlavor.comercio:
        return 'IZY Comercio';
      case AppFlavor.repartidor:
        return 'IZY Repartidor';
    }
  }
  
  static const String apiBaseUrl = 'http://localhost:8000/api';
  static const String wsUrl = 'http://localhost:8000';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int itemsPerPage = 20;

  static void setFlavor(AppFlavor flavor) {
    _currentFlavor = flavor;
  }

  static void initialize() {
    // Inicialización de configuraciones
  }
}
