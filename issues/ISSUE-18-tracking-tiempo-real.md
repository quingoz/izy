# Issue #18: Tracking en Tiempo Real

**Epic:** PWA Cliente  
**Prioridad:** Alta  
**Estimación:** 3 días  
**Sprint:** Sprint 3

---

## Descripción

Implementar tracking en tiempo real del pedido con mapa, estados y ubicación del repartidor vía WebSockets.

## Objetivos

- Mapa con Google Maps
- Tracking de estados en tiempo real
- Ubicación GPS del repartidor
- Timeline de estados
- Notificaciones de cambios
- Compartir tracking público

## Tareas Técnicas

### 1. WebSocket Client

**Archivo:** `lib/core/network/websocket_client.dart`

```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/app_config.dart';

class WebSocketClient {
  static IO.Socket? _socket;

  static IO.Socket get instance {
    _socket ??= IO.io(
      AppConfig.wsUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    return _socket!;
  }

  static void connect() {
    instance.connect();
  }

  static void disconnect() {
    instance.disconnect();
  }

  static void subscribe(String channel, Function(dynamic) callback) {
    instance.on(channel, callback);
  }

  static void unsubscribe(String channel) {
    instance.off(channel);
  }
}
```

### 2. Tracking Provider

**Archivo:** `lib/features/tracking/presentation/providers/tracking_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/websocket_client.dart';
import '../../data/repositories/tracking_repository.dart';
import '../../data/models/pedido_tracking.dart';

final trackingProvider = StateNotifierProvider.family<TrackingNotifier, TrackingState, int>(
  (ref, pedidoId) => TrackingNotifier(pedidoId),
);

class TrackingState {
  final PedidoTracking? pedido;
  final UbicacionRepartidor? ubicacionRepartidor;
  final bool isLoading;
  final String? error;

  TrackingState({
    this.pedido,
    this.ubicacionRepartidor,
    this.isLoading = false,
    this.error,
  });

  TrackingState copyWith({
    PedidoTracking? pedido,
    UbicacionRepartidor? ubicacionRepartidor,
    bool? isLoading,
    String? error,
  }) {
    return TrackingState(
      pedido: pedido ?? this.pedido,
      ubicacionRepartidor: ubicacionRepartidor ?? this.ubicacionRepartidor,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TrackingNotifier extends StateNotifier<TrackingState> {
  final int _pedidoId;
  final TrackingRepository _repository = TrackingRepository();

  TrackingNotifier(this._pedidoId) : super(TrackingState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadTracking();
    _subscribeToUpdates();
  }

  Future<void> loadTracking() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final pedido = await _repository.getTracking(_pedidoId);
      state = state.copyWith(
        pedido: pedido,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void _subscribeToUpdates() {
    // Suscribirse a cambios de estado
    WebSocketClient.subscribe(
      'pedido.$_pedidoId.estado.actualizado',
      (data) {
        if (state.pedido != null) {
          state = state.copyWith(
            pedido: state.pedido!.copyWith(
              estado: data['estado'],
            ),
          );
        }
      },
    );

    // Suscribirse a ubicación del repartidor
    WebSocketClient.subscribe(
      'pedido.$_pedidoId.tracking.repartidor.ubicacion.actualizada',
      (data) {
        state = state.copyWith(
          ubicacionRepartidor: UbicacionRepartidor(
            lat: data['lat'],
            lng: data['lng'],
            timestamp: DateTime.parse(data['timestamp']),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    WebSocketClient.unsubscribe('pedido.$_pedidoId.estado.actualizado');
    WebSocketClient.unsubscribe('pedido.$_pedidoId.tracking.repartidor.ubicacion.actualizada');
    super.dispose();
  }
}
```

### 3. Tracking Screen

**Archivo:** `lib/features/tracking/presentation/screens/tracking_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import '../providers/tracking_provider.dart';
import '../widgets/estado_timeline.dart';
import '../widgets/info_pedido_card.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  final int pedidoId;

  const TrackingScreen({
    super.key,
    required this.pedidoId,
  });

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackingProvider(widget.pedidoId));
    final theme = Theme.of(context);

    if (trackingState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (trackingState.error != null) {
      return Scaffold(
        body: Center(
          child: Text('Error: ${trackingState.error}'),
        ),
      );
    }

    final pedido = trackingState.pedido!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #${pedido.numeroPedido}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Compartir link de tracking
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Mapa
          Expanded(
            flex: 2,
            child: _buildMapa(trackingState),
          ),

          // Info del pedido
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoPedidoCard(pedido: pedido),
                  const SizedBox(height: 16),
                  Text(
                    'Estado del Pedido',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  EstadoTimeline(
                    estadoActual: pedido.estado,
                    historial: pedido.historialEstados,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapa(TrackingState state) {
    final pedido = state.pedido!;

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
          pedido.comercio.lat,
          pedido.comercio.lng,
        ),
        zoom: 14,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
      },
      markers: {
        // Marcador del comercio
        Marker(
          markerId: const MarkerId('comercio'),
          position: LatLng(pedido.comercio.lat, pedido.comercio.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: pedido.comercio.nombre),
        ),
        
        // Marcador del cliente
        Marker(
          markerId: const MarkerId('cliente'),
          position: LatLng(pedido.cliente.lat, pedido.cliente.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Tu ubicación'),
        ),
        
        // Marcador del repartidor (si existe)
        if (state.ubicacionRepartidor != null)
          Marker(
            markerId: const MarkerId('repartidor'),
            position: LatLng(
              state.ubicacionRepartidor!.lat,
              state.ubicacionRepartidor!.lng,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            infoWindow: const InfoWindow(title: 'Repartidor'),
          ),
      },
    );
  }
}
```

### 4. Estado Timeline Widget

**Archivo:** `lib/features/tracking/presentation/widgets/estado_timeline.dart`

```dart
import 'package:flutter/material.dart';

class EstadoTimeline extends StatelessWidget {
  final String estadoActual;
  final List<EstadoHistorial> historial;

  const EstadoTimeline({
    super.key,
    required this.estadoActual,
    required this.historial,
  });

  @override
  Widget build(BuildContext context) {
    final estados = [
      EstadoInfo('pendiente', 'Pendiente', Icons.schedule),
      EstadoInfo('confirmado', 'Confirmado', Icons.check_circle_outline),
      EstadoInfo('preparando', 'Preparando', Icons.restaurant),
      EstadoInfo('listo', 'Listo', Icons.done_all),
      EstadoInfo('en_camino', 'En Camino', Icons.delivery_dining),
      EstadoInfo('entregado', 'Entregado', Icons.check_circle),
    ];

    final indexActual = estados.indexWhere((e) => e.codigo == estadoActual);

    return Column(
      children: List.generate(estados.length, (index) {
        final estado = estados[index];
        final isCompleted = index <= indexActual;
        final isCurrent = index == indexActual;

        return _buildEstadoItem(
          context,
          estado,
          isCompleted,
          isCurrent,
          isLast: index == estados.length - 1,
        );
      }),
    );
  }

  Widget _buildEstadoItem(
    BuildContext context,
    EstadoInfo estado,
    bool isCompleted,
    bool isCurrent, {
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    final color = isCompleted 
        ? theme.colorScheme.primary 
        : Colors.grey[400]!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? color : Colors.white,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(
                estado.icono,
                color: isCompleted ? Colors.white : color,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? color : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  estado.nombre,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted ? Colors.black87 : Colors.grey[600],
                  ),
                ),
                if (isCurrent)
                  Text(
                    'Estado actual',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class EstadoInfo {
  final String codigo;
  final String nombre;
  final IconData icono;

  EstadoInfo(this.codigo, this.nombre, this.icono);
}

class EstadoHistorial {
  final String estado;
  final DateTime fecha;

  EstadoHistorial({
    required this.estado,
    required this.fecha,
  });
}
```

## Definición de Hecho (DoD)

- [ ] Mapa con Google Maps funcionando
- [ ] WebSockets conectados
- [ ] Estados se actualizan en tiempo real
- [ ] Ubicación del repartidor en tiempo real
- [ ] Timeline de estados visual
- [ ] Compartir link de tracking
- [ ] Responsive design
- [ ] Tests pasando

## Comandos de Verificación

```bash
flutter test
flutter run -d chrome
```

## Dependencias

- Issue #17: Checkout y Métodos de Pago

## Siguiente Issue

Issue #19: Setup App Android Comercio
