import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/producto.dart';

final productosProvider = StateNotifierProvider<ProductosNotifier, ProductosState>((ref) {
  return ProductosNotifier();
});

class ProductosState {
  final List<Producto> productos;
  final List<Producto> productosFiltrados;
  final String categoriaSeleccionada;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  ProductosState({
    this.productos = const [],
    this.productosFiltrados = const [],
    this.categoriaSeleccionada = 'Todos',
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  ProductosState copyWith({
    List<Producto>? productos,
    List<Producto>? productosFiltrados,
    String? categoriaSeleccionada,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return ProductosState(
      productos: productos ?? this.productos,
      productosFiltrados: productosFiltrados ?? this.productosFiltrados,
      categoriaSeleccionada: categoriaSeleccionada ?? this.categoriaSeleccionada,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<String> get categorias {
    final cats = productos.map((p) => p.categoria).toSet().toList();
    return ['Todos', ...cats];
  }
}

class ProductosNotifier extends StateNotifier<ProductosState> {
  ProductosNotifier() : super(ProductosState()) {
    loadProductos();
  }

  Future<void> loadProductos() async {
    state = state.copyWith(isLoading: true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final productos = _generarProductosMock();

      state = state.copyWith(
        productos: productos,
        productosFiltrados: productos,
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

  void filtrarPorCategoria(String categoria) {
    state = state.copyWith(categoriaSeleccionada: categoria);
    _aplicarFiltros();
  }

  void buscar(String query) {
    state = state.copyWith(searchQuery: query);
    _aplicarFiltros();
  }

  void _aplicarFiltros() {
    var filtrados = state.productos;

    if (state.categoriaSeleccionada != 'Todos') {
      filtrados = filtrados
          .where((p) => p.categoria == state.categoriaSeleccionada)
          .toList();
    }

    if (state.searchQuery.isNotEmpty) {
      filtrados = filtrados
          .where((p) =>
              p.nombre.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
              p.descripcion.toLowerCase().contains(state.searchQuery.toLowerCase()))
          .toList();
    }

    state = state.copyWith(productosFiltrados: filtrados);
  }

  Future<void> crearProducto(Producto producto) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final nuevosProductos = [...state.productos, producto];

      state = state.copyWith(productos: nuevosProductos);
      _aplicarFiltros();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> actualizarProducto(Producto producto) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = state.productos.indexWhere((p) => p.id == producto.id);
      if (index == -1) return;

      final nuevosProductos = List<Producto>.from(state.productos);
      nuevosProductos[index] = producto.copyWith(updatedAt: DateTime.now());

      state = state.copyWith(productos: nuevosProductos);
      _aplicarFiltros();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> eliminarProducto(String productoId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final nuevosProductos = state.productos.where((p) => p.id != productoId).toList();

      state = state.copyWith(productos: nuevosProductos);
      _aplicarFiltros();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleActivo(String productoId) async {
    try {
      final index = state.productos.indexWhere((p) => p.id == productoId);
      if (index == -1) return;

      final producto = state.productos[index];
      final productoActualizado = producto.copyWith(
        activo: !producto.activo,
        updatedAt: DateTime.now(),
      );

      await actualizarProducto(productoActualizado);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> actualizarStock(String productoId, int nuevoStock) async {
    try {
      final index = state.productos.indexWhere((p) => p.id == productoId);
      if (index == -1) return;

      final producto = state.productos[index];
      final productoActualizado = producto.copyWith(
        stock: nuevoStock,
        updatedAt: DateTime.now(),
      );

      await actualizarProducto(productoActualizado);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refresh() => loadProductos();

  List<Producto> _generarProductosMock() {
    return [
      Producto(
        id: '1',
        nombre: 'Hamburguesa Clásica',
        descripcion: 'Hamburguesa de carne con queso, lechuga y tomate',
        precioUsd: 8.50,
        categoria: 'Comida',
        stock: 25,
        activo: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Producto(
        id: '2',
        nombre: 'Pizza Margarita',
        descripcion: 'Pizza con salsa de tomate, mozzarella y albahaca',
        precioUsd: 12.00,
        categoria: 'Comida',
        stock: 15,
        activo: true,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      Producto(
        id: '3',
        nombre: 'Coca Cola',
        descripcion: 'Refresco de cola 500ml',
        precioUsd: 2.00,
        categoria: 'Bebidas',
        stock: 50,
        activo: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Producto(
        id: '4',
        nombre: 'Ensalada César',
        descripcion: 'Lechuga romana, pollo, crutones y aderezo césar',
        precioUsd: 7.50,
        categoria: 'Comida',
        stock: 12,
        activo: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Producto(
        id: '5',
        nombre: 'Brownie de Chocolate',
        descripcion: 'Brownie casero con nueces',
        precioUsd: 4.50,
        categoria: 'Postres',
        stock: 8,
        activo: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Producto(
        id: '6',
        nombre: 'Jugo Natural',
        descripcion: 'Jugo de naranja recién exprimido',
        precioUsd: 3.50,
        categoria: 'Bebidas',
        stock: 20,
        activo: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Producto(
        id: '7',
        nombre: 'Tacos al Pastor',
        descripcion: '3 tacos con carne al pastor, cebolla y cilantro',
        precioUsd: 6.00,
        categoria: 'Comida',
        stock: 0,
        activo: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      Producto(
        id: '8',
        nombre: 'Helado de Vainilla',
        descripcion: 'Helado artesanal de vainilla',
        precioUsd: 5.00,
        categoria: 'Postres',
        stock: 3,
        activo: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  }
}
