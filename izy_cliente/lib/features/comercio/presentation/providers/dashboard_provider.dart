import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/comercio_repository.dart';
import '../../domain/entities/estadisticas.dart';
import '../../domain/entities/pedido_activo.dart';

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});

class DashboardState {
  final Estadisticas? estadisticas;
  final List<PedidoActivo> pedidosActivos;
  final bool isLoading;
  final String? error;

  DashboardState({
    this.estadisticas,
    this.pedidosActivos = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    Estadisticas? estadisticas,
    List<PedidoActivo>? pedidosActivos,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      estadisticas: estadisticas ?? this.estadisticas,
      pedidosActivos: pedidosActivos ?? this.pedidosActivos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final ComercioRepository _repository = ComercioRepository();

  DashboardNotifier() : super(DashboardState()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true);

    try {
      final stats = await _repository.getEstadisticas();
      final pedidos = await _repository.getPedidosActivos();

      state = state.copyWith(
        estadisticas: stats,
        pedidosActivos: pedidos,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() => loadDashboard();
}
