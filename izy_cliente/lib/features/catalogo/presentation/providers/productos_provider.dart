import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/productos_repository.dart';
import '../../data/models/producto_model.dart';

final productosRepositoryProvider = Provider((ref) => ProductosRepository());

final productosProvider = StateNotifierProvider.family<ProductosNotifier, ProductosState, String>(
  (ref, slug) => ProductosNotifier(ref.read(productosRepositoryProvider), slug),
);

class ProductosState {
  final List<Producto> productos;
  final bool isLoading;
  final String? error;
  final int? categoriaSeleccionada;
  final String? searchQuery;
  final bool hasMore;

  ProductosState({
    this.productos = const [],
    this.isLoading = false,
    this.error,
    this.categoriaSeleccionada,
    this.searchQuery,
    this.hasMore = true,
  });

  ProductosState copyWith({
    List<Producto>? productos,
    bool? isLoading,
    String? error,
    int? categoriaSeleccionada,
    String? searchQuery,
    bool? hasMore,
  }) {
    return ProductosState(
      productos: productos ?? this.productos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      categoriaSeleccionada: categoriaSeleccionada ?? this.categoriaSeleccionada,
      searchQuery: searchQuery ?? this.searchQuery,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ProductosNotifier extends StateNotifier<ProductosState> {
  final ProductosRepository _repository;
  final String _slug;

  ProductosNotifier(this._repository, this._slug) : super(ProductosState()) {
    loadProductos();
  }

  Future<void> loadProductos({bool refresh = false}) async {
    if (refresh) {
      state = ProductosState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final productos = await _repository.getProductos(
        _slug,
        categoriaId: state.categoriaSeleccionada,
        search: state.searchQuery,
      );

      state = state.copyWith(
        productos: productos,
        isLoading: false,
        hasMore: productos.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void filterByCategoria(int? categoriaId) {
    state = state.copyWith(categoriaSeleccionada: categoriaId);
    loadProductos(refresh: true);
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query.isEmpty ? null : query);
    loadProductos(refresh: true);
  }

  void clearFilters() {
    state = ProductosState();
    loadProductos();
  }
}

final categoriasProvider = FutureProvider.family<List<Categoria>, String>((ref, slug) async {
  final repository = ref.read(productosRepositoryProvider);
  return repository.getCategorias(slug);
});
