import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/models/carrito_item.dart';
import '../../../catalogo/data/models/producto_model.dart';

final carritoProvider = StateNotifierProvider<CarritoNotifier, CarritoState>((ref) {
  return CarritoNotifier();
});

class CarritoState {
  final List<CarritoItem> items;
  final String? comercioSlug;
  final int? comercioId;

  CarritoState({
    this.items = const [],
    this.comercioSlug,
    this.comercioId,
  });

  CarritoState copyWith({
    List<CarritoItem>? items,
    String? comercioSlug,
    int? comercioId,
  }) {
    return CarritoState(
      items: items ?? this.items,
      comercioSlug: comercioSlug ?? this.comercioSlug,
      comercioId: comercioId ?? this.comercioId,
    );
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.cantidad);

  double get subtotalUsd => items.fold(0, (sum, item) => sum + item.subtotalUsd);
  double get subtotalBs => items.fold(0, (sum, item) => sum + item.subtotalBs);

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}

class CarritoNotifier extends StateNotifier<CarritoState> {
  CarritoNotifier() : super(CarritoState()) {
    _loadCarrito();
  }

  Future<void> _loadCarrito() async {
    try {
      final box = await Hive.openBox<CarritoItem>('carrito');
      final items = box.values.toList();
      
      final metaBox = await Hive.openBox('carrito_meta');
      final comercioSlug = metaBox.get('comercio_slug');
      final comercioId = metaBox.get('comercio_id');

      state = state.copyWith(
        items: items,
        comercioSlug: comercioSlug,
        comercioId: comercioId,
      );
    } catch (e) {
      // Si falla, mantener estado vacío
    }
  }

  Future<void> _saveCarrito() async {
    final box = await Hive.openBox<CarritoItem>('carrito');
    await box.clear();
    await box.addAll(state.items);

    final metaBox = await Hive.openBox('carrito_meta');
    await metaBox.put('comercio_slug', state.comercioSlug);
    await metaBox.put('comercio_id', state.comercioId);
  }

  Future<bool> agregarProducto(
    Producto producto, {
    int cantidad = 1,
    List<VarianteSeleccionada>? variantes,
    String? notas,
    String? comercioSlug,
    int? comercioId,
  }) async {
    if (state.isNotEmpty && state.comercioId != comercioId) {
      return false;
    }

    if (!producto.stockIlimitado && producto.stock < cantidad) {
      return false;
    }

    final precioVariantesUsd = variantes?.fold<double>(0.0, (sum, v) => sum + (v.priceUsd ?? 0)) ?? 0.0;
    final precioVariantesBs = variantes?.fold<double>(0.0, (sum, v) => sum + (v.priceBs ?? 0)) ?? 0.0;
    
    final precioUsd = producto.getPrecioFinal('usd') + precioVariantesUsd;
    final precioBs = producto.getPrecioFinal('bs') + precioVariantesBs;

    final nuevoItem = CarritoItem(
      productoId: producto.id,
      nombre: producto.nombre,
      imagenUrl: producto.imagenUrl,
      precioUnitarioUsd: precioUsd,
      precioUnitarioBs: precioBs,
      cantidad: cantidad,
      variantes: variantes,
      notas: notas,
      stockDisponible: producto.stock,
    );

    final index = state.items.indexWhere((item) => 
        item.productoId == producto.id &&
        _variantesIguales(item.variantes, variantes));

    List<CarritoItem> nuevosItems;
    if (index >= 0) {
      final itemExistente = state.items[index];
      final nuevaCantidad = itemExistente.cantidad + cantidad;
      
      if (!producto.stockIlimitado && nuevaCantidad > producto.stock) {
        return false;
      }

      nuevosItems = List.from(state.items);
      nuevosItems[index] = itemExistente.copyWith(cantidad: nuevaCantidad);
    } else {
      nuevosItems = [...state.items, nuevoItem];
    }

    state = state.copyWith(
      items: nuevosItems,
      comercioSlug: comercioSlug ?? state.comercioSlug,
      comercioId: comercioId ?? state.comercioId,
    );

    await _saveCarrito();
    return true;
  }

  Future<void> actualizarCantidad(int index, int nuevaCantidad) async {
    if (index < 0 || index >= state.items.length) return;

    final item = state.items[index];
    
    if (nuevaCantidad <= 0) {
      await removerItem(index);
      return;
    }

    if (nuevaCantidad > item.stockDisponible) {
      return;
    }

    final nuevosItems = List<CarritoItem>.from(state.items);
    nuevosItems[index] = item.copyWith(cantidad: nuevaCantidad);

    state = state.copyWith(items: nuevosItems);
    await _saveCarrito();
  }

  Future<void> removerItem(int index) async {
    final nuevosItems = List<CarritoItem>.from(state.items);
    nuevosItems.removeAt(index);

    state = state.copyWith(items: nuevosItems);
    await _saveCarrito();
  }

  Future<void> limpiarCarrito() async {
    state = CarritoState();
    final box = await Hive.openBox<CarritoItem>('carrito');
    await box.clear();
    final metaBox = await Hive.openBox('carrito_meta');
    await metaBox.clear();
  }

  bool _variantesIguales(
    List<VarianteSeleccionada>? v1,
    List<VarianteSeleccionada>? v2,
  ) {
    if (v1 == null && v2 == null) return true;
    if (v1 == null || v2 == null) return false;
    if (v1.length != v2.length) return false;

    for (var i = 0; i < v1.length; i++) {
      if (v1[i].name != v2[i].name || v1[i].value != v2[i].value) {
        return false;
      }
    }

    return true;
  }
}
