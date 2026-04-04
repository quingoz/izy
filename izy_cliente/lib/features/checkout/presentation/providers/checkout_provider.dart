import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../carrito/presentation/providers/carrito_provider.dart';
import '../../data/repositories/pedido_repository.dart';
import '../../data/models/direccion.dart';

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(ref);
});

class CheckoutState {
  final Direccion? direccion;
  final String? metodoPago;
  final Map<String, dynamic>? pagoMovilData;
  final double? vueltoDe;
  final double deliveryFeeUsd;
  final double deliveryFeeBs;
  final bool isLoading;
  final String? error;

  CheckoutState({
    this.direccion,
    this.metodoPago,
    this.pagoMovilData,
    this.vueltoDe,
    this.deliveryFeeUsd = 2.0,
    this.deliveryFeeBs = 70.0,
    this.isLoading = false,
    this.error,
  });

  CheckoutState copyWith({
    Direccion? direccion,
    String? metodoPago,
    Map<String, dynamic>? pagoMovilData,
    double? vueltoDe,
    double? deliveryFeeUsd,
    double? deliveryFeeBs,
    bool? isLoading,
    String? error,
  }) {
    return CheckoutState(
      direccion: direccion ?? this.direccion,
      metodoPago: metodoPago ?? this.metodoPago,
      pagoMovilData: pagoMovilData ?? this.pagoMovilData,
      vueltoDe: vueltoDe ?? this.vueltoDe,
      deliveryFeeUsd: deliveryFeeUsd ?? this.deliveryFeeUsd,
      deliveryFeeBs: deliveryFeeBs ?? this.deliveryFeeBs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get canConfirm => 
      direccion != null && 
      metodoPago != null &&
      !isLoading;
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final Ref _ref;
  final PedidoRepository _repository = PedidoRepository();

  CheckoutNotifier(this._ref) : super(CheckoutState());

  void setDireccion(Direccion direccion) {
    state = state.copyWith(direccion: direccion);
  }

  void setMetodoPago(String metodo) {
    state = state.copyWith(metodoPago: metodo);
  }

  void setPagoMovilData(Map<String, dynamic> data) {
    state = state.copyWith(pagoMovilData: data);
  }

  void setVueltoDe(double monto) {
    state = state.copyWith(vueltoDe: monto);
  }

  Future<bool> crearPedido({String? notasCliente}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final carritoState = _ref.read(carritoProvider);
      
      if (carritoState.isEmpty) {
        throw Exception('El carrito está vacío');
      }

      if (state.direccion == null) {
        throw Exception('Selecciona una dirección de entrega');
      }

      if (state.metodoPago == null) {
        throw Exception('Selecciona un método de pago');
      }

      final pedidoData = {
        'comercio_id': carritoState.comercioId,
        'items': carritoState.items.map((item) => item.toJson()).toList(),
        'tipo_pago': state.metodoPago,
        'direccion': state.direccion!.toJson(),
        'notas_cliente': notasCliente,
        if (state.metodoPago == 'efectivo' && state.vueltoDe != null)
          'vuelto_de': state.vueltoDe,
        if (state.metodoPago == 'pago_movil' && state.pagoMovilData != null)
          'pago_movil': state.pagoMovilData,
      };

      await _repository.crearPedido(pedidoData);

      await _ref.read(carritoProvider.notifier).limpiarCarrito();

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
}
