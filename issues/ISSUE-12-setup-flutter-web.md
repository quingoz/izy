# Issue #12: Setup Proyecto Flutter Web

**Epic:** PWA Cliente  
**Prioridad:** Alta  
**Estimación:** 1 día  
**Sprint:** Sprint 2

---

## Descripción

Configurar proyecto Flutter para PWA con estructura Clean Architecture y Riverpod.

## Objetivos

- Crear proyecto Flutter Web
- Configurar dependencias necesarias
- Estructura Clean Architecture
- PWA manifest configurado
- Temas y constantes del proyecto

## Tareas Técnicas

### 1. Crear Proyecto

```bash
flutter create izy_cliente
cd izy_cliente
```

### 2. Configurar pubspec.yaml

```yaml
name: izy_cliente
description: PWA Cliente para IZY Delivery
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  
  # HTTP & API
  dio: ^5.4.0
  retrofit: ^4.1.0
  json_annotation: ^4.8.1
  
  # Navigation
  go_router: ^13.2.0
  
  # Maps
  google_maps_flutter_web: ^0.5.6
  
  # WebSockets
  socket_io_client: ^2.0.3
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Utils
  freezed_annotation: ^2.4.1
  intl: ^0.19.0
  cached_network_image: ^3.3.1
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  
  # Code Generation
  build_runner: ^2.4.8
  riverpod_generator: ^2.3.11
  retrofit_generator: ^8.1.0
  json_serializable: ^6.7.1
  freezed: ^2.4.7
  hive_generator: ^2.0.1

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
```

### 3. Estructura de Carpetas

```
lib/
├── main.dart
├── core/
│   ├── config/
│   │   ├── app_config.dart
│   │   ├── api_config.dart
│   │   └── theme_config.dart
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── api_constants.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   ├── api_interceptor.dart
│   │   └── websocket_client.dart
│   └── utils/
│       ├── validators.dart
│       ├── formatters.dart
│       └── helpers.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── datasources/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   ├── catalogo/
│   ├── carrito/
│   ├── checkout/
│   └── tracking/
└── shared/
    ├── widgets/
    ├── models/
    └── providers/
```

### 4. Configurar PWA Manifest

**Archivo:** `web/manifest.json`

```json
{
  "name": "IZY Cliente",
  "short_name": "IZY",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#FFFFFF",
  "theme_color": "#1B3A57",
  "description": "Plataforma de delivery IZY",
  "orientation": "portrait-primary",
  "prefer_related_applications": false,
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

### 5. Configurar Theme

**Archivo:** `lib/core/config/theme_config.dart`

```dart
import 'package:flutter/material.dart';

class ThemeConfig {
  // Colores del logo IZY
  static const Color primaryColor = Color(0xFF1B3A57); // Azul oscuro
  static const Color secondaryColor = Color(0xFF5FD4A0); // Verde mint
  static const Color accentColor = Color(0xFF4CAF50); // Verde
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: secondaryColor,
      secondary: primaryColor,
    ),
  );
}
```

### 6. App Config

**Archivo:** `lib/core/config/app_config.dart`

```dart
class AppConfig {
  static const String appName = 'IZY Cliente';
  static const String apiBaseUrl = 'http://localhost:8000/api';
  static const String wsUrl = 'http://localhost:8080';
  
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int itemsPerPage = 20;
  
  static void initialize() {
    // Inicialización de la app
  }
}
```

### 7. Main Entry Point

**Archivo:** `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/config/app_config.dart';
import 'core/config/theme_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Hive
  await Hive.initFlutter();
  
  // Inicializar configuración
  AppConfig.initialize();
  
  runApp(
    const ProviderScope(
      child: IzyClienteApp(),
    ),
  );
}

class IzyClienteApp extends StatelessWidget {
  const IzyClienteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      home: const Scaffold(
        body: Center(
          child: Text('IZY Cliente - Setup Completo'),
        ),
      ),
    );
  }
}
```

### 8. Analysis Options

**Archivo:** `analysis_options.yaml`

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - avoid_print
    - prefer_single_quotes
    - always_declare_return_types
```

## Definición de Hecho (DoD)

- [ ] Proyecto Flutter creado
- [ ] Dependencias instaladas
- [ ] Estructura de carpetas creada
- [ ] PWA manifest configurado
- [ ] Tema con colores del logo IZY
- [ ] App ejecuta sin errores
- [ ] Hot reload funciona

## Comandos de Verificación

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en Chrome
flutter run -d chrome

# Build para web
flutter build web --release

# Verificar análisis
flutter analyze
```

## Dependencias

Ninguna (primer issue de Flutter)

## Siguiente Issue

Issue #13: Cliente HTTP y State Management
