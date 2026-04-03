# Issue #19: Setup App Android Comercio (Flutter Flavor)

**Epic:** App Comercio  
**Prioridad:** Alta  
**Estimación:** 1 día  
**Sprint:** Sprint 3

---

## Descripción

Configurar proyecto Flutter con flavor "comercio" para app Android de gestión de pedidos.

## Objetivos

- Configurar flavor comercio
- Estructura específica para comercio
- Tema con colores IZY
- Firebase configurado
- Build APK funcional

## Tareas Técnicas

### 1. Configurar Flavors

**Archivo:** `android/app/build.gradle`

```gradle
android {
    flavorDimensions "app"
    
    productFlavors {
        comercio {
            dimension "app"
            applicationIdSuffix ".comercio"
            versionNameSuffix "-comercio"
            resValue "string", "app_name", "IZY Comercio"
        }
        
        repartidor {
            dimension "app"
            applicationIdSuffix ".repartidor"
            versionNameSuffix "-repartidor"
            resValue "string", "app_name", "IZY Repartidor"
        }
    }
}
```

### 2. Main Comercio

**Archivo:** `lib/main_comercio.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_config.dart';
import 'core/config/theme_config.dart';
import 'features/comercio/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  AppConfig.setFlavor(AppFlavor.comercio);
  
  runApp(
    const ProviderScope(
      child: IzyComercioApp(),
    ),
  );
}

class IzyComercioApp extends StatelessWidget {
  const IzyComercioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IZY Comercio',
      theme: ThemeConfig.lightTheme,
      home: const ComercioHomeScreen(),
    );
  }
}
```

### 3. Estructura de Carpetas Comercio

```
lib/
├── features/
│   └── comercio/
│       ├── data/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   └── entities/
│       └── presentation/
│           ├── providers/
│           ├── screens/
│           │   ├── home_screen.dart
│           │   ├── pedidos_screen.dart
│           │   ├── productos_screen.dart
│           │   └── estadisticas_screen.dart
│           └── widgets/
```

### 4. Comandos de Build

```bash
# Desarrollo
flutter run --flavor comercio

# Release APK
flutter build apk --flavor comercio --release

# Debug APK
flutter build apk --flavor comercio --debug
```

## Definición de Hecho (DoD)

- [ ] Flavor comercio configurado
- [ ] App ejecuta en Android
- [ ] Tema aplicado correctamente
- [ ] Firebase configurado
- [ ] APK genera sin errores
- [ ] Estructura de carpetas creada

## Comandos de Verificación

```bash
flutter run --flavor comercio
flutter build apk --flavor comercio --release
```

## Dependencias

- Issue #12: Setup Proyecto Flutter Web

## Siguiente Issue

Issue #20: Dashboard de Comercio
