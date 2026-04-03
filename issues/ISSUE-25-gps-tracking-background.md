# Issue #25: GPS Tracking en Segundo Plano

**Epic:** App Repartidor  
**Prioridad:** Crítica  
**Estimación:** 3 días  
**Sprint:** Sprint 4

---

## Descripción

Implementar tracking GPS continuo en segundo plano que actualiza ubicación al servidor cada 10 segundos.

## Objetivos

- Servicio de ubicación en background
- Actualización cada 10 segundos
- Broadcast a WebSocket
- Optimización de batería
- Manejo de permisos

## Tareas Técnicas

### 1. Location Service

```dart
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationService {
  StreamSubscription<Position>? _positionStream;
  
  Future<void> startTracking(int pedidoId) async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _updateLocation(position, pedidoId);
    });
  }

  Future<void> _updateLocation(Position position, int pedidoId) async {
    // Enviar al servidor
    await ApiService().post('/repartidor/ubicacion', data: {
      'lat': position.latitude,
      'lng': position.longitude,
      'accuracy': position.accuracy,
      'speed': position.speed,
      'pedido_id': pedidoId,
    });
  }

  void stopTracking() {
    _positionStream?.cancel();
  }
}
```

### 2. Background Service

```dart
import 'package:flutter_background_service/flutter_background_service.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Iniciar tracking GPS
  final locationService = LocationService();
  await locationService.startTracking(pedidoId);
}
```

## Definición de Hecho (DoD)

- [ ] GPS tracking en background funcional
- [ ] Actualización cada 10 segundos
- [ ] Optimización de batería
- [ ] Permisos manejados correctamente
- [ ] Servicio persiste al cerrar app
- [ ] Tests pasando

## Dependencias

- Issue #24: Setup App Android Repartidor

## Siguiente Issue

Issue #26: Gestión de Pedidos Disponibles
