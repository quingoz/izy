# Issue #15: Catálogo de Productos

**Epic:** PWA Cliente  
**Prioridad:** Alta  
**Estimación:** 2 días  
**Sprint:** Sprint 2

---

## Descripción

Implementar catálogo de productos con listado, filtros, búsqueda y vista de detalle.

## Objetivos

- Listado de productos con paginación
- Filtros por categoría
- Búsqueda en tiempo real
- Vista de detalle de producto
- Manejo de variantes
- Indicador de stock

## Tareas Técnicas

### 1. Producto Model

**Archivo:** `lib/features/catalogo/data/models/producto_model.dart`

```dart
class Producto {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? imagenUrl;
  final double precioUsd;
  final double precioBs;
  final double? precioOfertaUsd;
  final double? precioOfertaBs;
  final int stock;
  final bool stockIlimitado;
  final bool tieneVariantes;
  final List<Variante>? variantes;
  final bool isActive;
  final bool isDestacado;
  final Categoria? categoria;

  Producto({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.imagenUrl,
    required this.precioUsd,
    required this.precioBs,
    this.precioOfertaUsd,
    this.precioOfertaBs,
    required this.stock,
    required this.stockIlimitado,
    required this.tieneVariantes,
    this.variantes,
    required this.isActive,
    required this.isDestacado,
    this.categoria,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      imagenUrl: json['imagen_url'],
      precioUsd: (json['precio_usd'] as num).toDouble(),
      precioBs: (json['precio_bs'] as num).toDouble(),
      precioOfertaUsd: json['precio_oferta_usd'] != null 
          ? (json['precio_oferta_usd'] as num).toDouble() 
          : null,
      precioOfertaBs: json['precio_oferta_bs'] != null 
          ? (json['precio_oferta_bs'] as num).toDouble() 
          : null,
      stock: json['stock'],
      stockIlimitado: json['stock_ilimitado'],
      tieneVariantes: json['tiene_variantes'],
      variantes: json['variantes'] != null
          ? (json['variantes'] as List).map((v) => Variante.fromJson(v)).toList()
          : null,
      isActive: json['is_active'],
      isDestacado: json['is_destacado'],
      categoria: json['categoria'] != null 
          ? Categoria.fromJson(json['categoria']) 
          : null,
    );
  }

  bool get tieneOferta => precioOfertaUsd != null;
  bool get hayStock => stockIlimitado || stock > 0;
  
  double getPrecioFinal(String moneda) {
    if (moneda == 'usd') {
      return precioOfertaUsd ?? precioUsd;
    }
    return precioOfertaBs ?? precioBs;
  }
}

class Variante {
  final String name;
  final List<String> options;
  final double? priceUsd;
  final double? priceBs;

  Variante({
    required this.name,
    required this.options,
    this.priceUsd,
    this.priceBs,
  });

  factory Variante.fromJson(Map<String, dynamic> json) {
    return Variante(
      name: json['name'],
      options: List<String>.from(json['options']),
      priceUsd: json['price_usd']?.toDouble(),
      priceBs: json['price_bs']?.toDouble(),
    );
  }
}

class Categoria {
  final int id;
  final String nombre;
  final String? icono;

  Categoria({
    required this.id,
    required this.nombre,
    this.icono,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'],
      nombre: json['nombre'],
      icono: json['icono'],
    );
  }
}
```

### 2. Productos Provider

**Archivo:** `lib/features/catalogo/presentation/providers/productos_provider.dart`

```dart
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
```

### 3. Productos Repository

**Archivo:** `lib/features/catalogo/data/repositories/productos_repository.dart`

```dart
import '../../../../core/network/api_service.dart';
import '../models/producto_model.dart';

class ProductosRepository {
  final ApiService _api = ApiService();

  Future<List<Producto>> getProductos(
    String slug, {
    int? categoriaId,
    String? search,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (search != null) 'search': search,
    };

    final response = await _api.get(
      '/comercios/$slug/productos',
      queryParameters: queryParams,
    );

    return (response['data'] as List)
        .map((json) => Producto.fromJson(json))
        .toList();
  }

  Future<Producto> getProducto(int id) async {
    final response = await _api.get('/productos/$id');
    return Producto.fromJson(response['data']);
  }

  Future<List<Categoria>> getCategorias(String slug) async {
    final response = await _api.get('/comercios/$slug/categorias');
    return (response['data'] as List)
        .map((json) => Categoria.fromJson(json))
        .toList();
  }
}
```

### 4. Productos Screen

**Archivo:** `lib/features/catalogo/presentation/screens/productos_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/productos_provider.dart';
import '../widgets/producto_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/categorias_filter.dart';

class ProductosScreen extends ConsumerStatefulWidget {
  final String comercioSlug;

  const ProductosScreen({
    super.key,
    required this.comercioSlug,
  });

  @override
  ConsumerState<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends ConsumerState<ProductosScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.9) {
      // Cargar más productos
    }
  }

  @override
  Widget build(BuildContext context) {
    final productosState = ref.watch(productosProvider(widget.comercioSlug));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              ProductosSearchBar(
                onSearch: (query) {
                  ref.read(productosProvider(widget.comercioSlug).notifier)
                      .search(query);
                },
              ),
              CategoriasFilter(
                comercioSlug: widget.comercioSlug,
                onCategoriaSelected: (categoriaId) {
                  ref.read(productosProvider(widget.comercioSlug).notifier)
                      .filterByCategoria(categoriaId);
                },
              ),
            ],
          ),
        ),
      ),
      body: productosState.isLoading && productosState.productos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : productosState.error != null
              ? Center(child: Text('Error: ${productosState.error}'))
              : RefreshIndicator(
                  onRefresh: () => ref
                      .read(productosProvider(widget.comercioSlug).notifier)
                      .loadProductos(refresh: true),
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: productosState.productos.length,
                    itemBuilder: (context, index) {
                      return ProductoCard(
                        producto: productosState.productos[index],
                      );
                    },
                  ),
                ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

### 5. Producto Card Widget

**Archivo:** `lib/features/catalogo/presentation/widgets/producto_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/producto_model.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;

  const ProductoCard({
    super.key,
    required this.producto,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Navegar a detalle
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  producto.imagenUrl != null
                      ? CachedNetworkImage(
                          imageUrl: producto.imagenUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => 
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => 
                              const Icon(Icons.image_not_supported),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.fastfood, size: 48),
                        ),
                  
                  // Badges
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Column(
                      children: [
                        if (producto.isDestacado)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Destacado',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (producto.tieneOferta)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Oferta',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: theme.textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (producto.tieneOferta)
                          Text(
                            '\$${producto.precioUsd.toStringAsFixed(2)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(width: 4),
                        Text(
                          '\$${producto.getPrecioFinal('usd').toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (!producto.hayStock)
                      Text(
                        'Sin stock',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Definición de Hecho (DoD)

- [ ] Listado de productos funcional
- [ ] Filtros por categoría operativos
- [ ] Búsqueda en tiempo real
- [ ] Paginación implementada
- [ ] Vista de detalle navegable
- [ ] Indicadores de stock y ofertas
- [ ] Responsive design
- [ ] Tests pasando

## Comandos de Verificación

```bash
flutter test
flutter run -d chrome
```

## Dependencias

- Issue #14: Sistema de Branding Dinámico

## Siguiente Issue

Issue #16: Carrito de Compras
