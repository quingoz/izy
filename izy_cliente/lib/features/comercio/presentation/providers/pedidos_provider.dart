import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pedido.dart';
import '../../domain/entities/pedido_item.dart';

final pedidosProvider = StateNotifierProvider<PedidosNotifier, PedidosState>((ref) {
  return PedidosNotifier();
});

class PedidosState {
  final List<Pedido> pendientes;
  final List<Pedido> preparando;
  final List<Pedido> listos;
  final List<Pedido> enCamino;
  final bool isLoading;
  final String? error;

  PedidosState({
    this.pendientes = const [],
    this.preparando = const [],
    this.listos = const [],
    this.enCamino = const [],
    this.isLoading = false,
    this.error,
  });

  PedidosState copyWith({
    List<Pedido>? pendientes,
    List<Pedido>? preparando,
    List<Pedido>? listos,
    List<Pedido>? enCamino,
    bool? isLoading,
    String? error,
  }) {
    return PedidosState(
      pendientes: pendientes ?? this.pendientes,
      preparando: preparando ?? this.preparando,
      listos: listos ?? this.listos,
      enCamino: enCamino ?? this.enCamino,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<Pedido> get todosPedidos => [
        ...pendientes,
        ...preparando,
        ...listos,
        ...enCamino,
      ];
}

class PedidosNotifier extends StateNotifier<PedidosState> {
  PedidosNotifier() : super(PedidosState()) {
    loadPedidos();
  }

  Future<void> loadPedidos() async {
    state = state.copyWith(isLoading: true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final pedidosMock = _generarPedidosMock();

      final pendientes = pedidosMock.where((p) => p.estado == 'pendiente').toList();
      final preparando = pedidosMock.where((p) => p.estado == 'preparando').toList();
      final listos = pedidosMock.where((p) => p.estado == 'listo').toList();
      final enCamino = pedidosMock.where((p) => p.estado == 'en_camino').toList();

      state = state.copyWith(
        pendientes: pendientes,
        preparando: preparando,
        listos: listos,
        enCamino: enCamino,
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

  Future<void> cambiarEstado(String pedidoId, String nuevoEstado) async {
    try {
      final todosPedidos = state.todosPedidos;
      final pedidoIndex = todosPedidos.indexWhere((p) => p.id == pedidoId);

      if (pedidoIndex == -1) return;

      final pedidoActualizado = todosPedidos[pedidoIndex].copyWith(
        estado: nuevoEstado,
        updatedAt: DateTime.now(),
      );

      await Future.delayed(const Duration(milliseconds: 300));

      final pedidosActualizados = List<Pedido>.from(todosPedidos);
      pedidosActualizados[pedidoIndex] = pedidoActualizado;

      final pendientes = pedidosActualizados.where((p) => p.estado == 'pendiente').toList();
      final preparando = pedidosActualizados.where((p) => p.estado == 'preparando').toList();
      final listos = pedidosActualizados.where((p) => p.estado == 'listo').toList();
      final enCamino = pedidosActualizados.where((p) => p.estado == 'en_camino').toList();

      state = state.copyWith(
        pendientes: pendientes,
        preparando: preparando,
        listos: listos,
        enCamino: enCamino,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refresh() => loadPedidos();

  List<Pedido> _generarPedidosMock() {
    return [
      Pedido(
        id: '1',
        numeroPedido: 'ORD-001',
        clienteId: 'c1',
        clienteNombre: 'Juan Pérez',
        estado: 'pendiente',
        items: [
          PedidoItem(
            id: 'i1',
            productoId: 'p1',
            nombreProducto: 'Hamburguesa Clásica',
            cantidad: 2,
            precioUnitarioUsd: 8.50,
            subtotalUsd: 17.00,
          ),
          PedidoItem(
            id: 'i2',
            productoId: 'p2',
            nombreProducto: 'Papas Fritas',
            cantidad: 1,
            precioUnitarioUsd: 3.50,
            subtotalUsd: 3.50,
          ),
        ],
        totalUsd: 20.50,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        notasCliente: 'Sin cebolla por favor',
        direccionEntrega: 'Av. Principal #123',
      ),
      Pedido(
        id: '2',
        numeroPedido: 'ORD-002',
        clienteId: 'c2',
        clienteNombre: 'María González',
        estado: 'pendiente',
        items: [
          PedidoItem(
            id: 'i3',
            productoId: 'p3',
            nombreProducto: 'Pizza Margarita',
            cantidad: 1,
            precioUnitarioUsd: 12.00,
            subtotalUsd: 12.00,
          ),
        ],
        totalUsd: 12.00,
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        direccionEntrega: 'Calle Secundaria #456',
      ),
      Pedido(
        id: '3',
        numeroPedido: 'ORD-003',
        clienteId: 'c3',
        clienteNombre: 'Carlos Rodríguez',
        estado: 'preparando',
        items: [
          PedidoItem(
            id: 'i4',
            productoId: 'p4',
            nombreProducto: 'Ensalada César',
            cantidad: 2,
            precioUnitarioUsd: 7.50,
            subtotalUsd: 15.00,
          ),
          PedidoItem(
            id: 'i5',
            productoId: 'p5',
            nombreProducto: 'Refresco',
            cantidad: 2,
            precioUnitarioUsd: 2.00,
            subtotalUsd: 4.00,
          ),
        ],
        totalUsd: 19.00,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        direccionEntrega: 'Urbanización Los Pinos #789',
      ),
      Pedido(
        id: '4',
        numeroPedido: 'ORD-004',
        clienteId: 'c4',
        clienteNombre: 'Ana Martínez',
        estado: 'listo',
        items: [
          PedidoItem(
            id: 'i6',
            productoId: 'p6',
            nombreProducto: 'Sushi Roll',
            cantidad: 3,
            precioUnitarioUsd: 10.00,
            subtotalUsd: 30.00,
          ),
        ],
        totalUsd: 30.00,
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        notasCliente: 'Sin wasabi',
        direccionEntrega: 'Torre Empresarial #101',
      ),
      Pedido(
        id: '5',
        numeroPedido: 'ORD-005',
        clienteId: 'c5',
        clienteNombre: 'Luis Fernández',
        estado: 'en_camino',
        items: [
          PedidoItem(
            id: 'i7',
            productoId: 'p7',
            nombreProducto: 'Tacos al Pastor',
            cantidad: 4,
            precioUnitarioUsd: 3.50,
            subtotalUsd: 14.00,
          ),
        ],
        totalUsd: 14.00,
        createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
        direccionEntrega: 'Centro Comercial #202',
      ),
    ];
  }
}
