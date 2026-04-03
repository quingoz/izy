# Issue #24: Setup App Android Repartidor (Flutter Flavor)

**Epic:** App Repartidor  
**Prioridad:** Alta  
**Estimación:** 1 día  
**Sprint:** Sprint 4

---

## Descripción

Configurar proyecto Flutter con flavor "repartidor" para app Android de entregas.

## Objetivos

- Configurar flavor repartidor
- Permisos de ubicación
- Firebase configurado
- Background services
- Build APK funcional

## Tareas Técnicas

### 1. Main Repartidor

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: IzyRepartidorApp(),
    ),
  );
}

class IzyRepartidorApp extends StatelessWidget {
  const IzyRepartidorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IZY Repartidor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B3A57)),
      ),
      home: const RepartidorHomeScreen(),
    );
  }
}
```

### 2. Permisos Android

**Archivo:** `android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

## Definición de Hecho (DoD)

- [ ] Flavor repartidor configurado
- [ ] Permisos de ubicación solicitados
- [ ] Firebase configurado
- [ ] APK genera sin errores

## Dependencias

- Issue #19: Setup App Android Comercio

## Siguiente Issue

Issue #25: GPS Tracking en Segundo Plano
