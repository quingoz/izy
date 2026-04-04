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

    WebSocketClient.subscribe(
      'pedido.$_pedidoId.tracking.repartidor.ubicacion.actualizada',
      (data) {
        state = state.copyWith(
          ubicacionRepartidor: UbicacionRepartidor(
            lat: (data['lat'] as num).toDouble(),
            lng: (data['lng'] as num).toDouble(),
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
