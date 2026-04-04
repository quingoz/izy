import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/productos_provider.dart';
import '../widgets/producto_card.dart';
import '../widgets/productos_search_bar.dart';
import '../widgets/categorias_filter.dart';
import '../../../../core/constants/app_constants.dart';

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
      // TODO: Cargar más productos (paginación)
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
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: IzyColors.error,
                      ),
                      const SizedBox(height: IzySpacing.md),
                      Text(
                        'Error al cargar productos',
                        style: IzyTextStyles.h4,
                      ),
                      const SizedBox(height: IzySpacing.sm),
                      Text(
                        productosState.error!,
                        style: IzyTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: IzySpacing.lg),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(productosProvider(widget.comercioSlug).notifier)
                              .loadProductos(refresh: true);
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : productosState.productos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: IzyColors.greyMedium,
                          ),
                          const SizedBox(height: IzySpacing.md),
                          Text(
                            'No hay productos disponibles',
                            style: IzyTextStyles.h4,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref
                          .read(productosProvider(widget.comercioSlug).notifier)
                          .loadProductos(refresh: true),
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(IzySpacing.md),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: IzySpacing.md,
                          mainAxisSpacing: IzySpacing.md,
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
