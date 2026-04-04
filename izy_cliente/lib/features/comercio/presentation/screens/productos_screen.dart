import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/productos_provider.dart';
import '../widgets/producto_card.dart';
import 'producto_form_screen.dart';
import '../../../../core/constants/app_constants.dart';

class ProductosScreen extends ConsumerWidget {
  const ProductosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productosState = ref.watch(productosProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar productos...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(IzyRadius.md),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  ref.read(productosProvider.notifier).buscar(value);
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productosState.categorias.length,
                  itemBuilder: (context, index) {
                    final categoria = productosState.categorias[index];
                    final isSelected = categoria == productosState.categoriaSeleccionada;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(categoria),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(productosProvider.notifier).filtrarPorCategoria(categoria);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: productosState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : productosState.productosFiltrados.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: IzyColors.greyMedium,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay productos',
                            style: TextStyle(
                              fontSize: 16,
                              color: IzyColors.greyDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => _navegarAFormulario(context, ref, null),
                            icon: const Icon(Icons.add),
                            label: const Text('Crear Producto'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.read(productosProvider.notifier).refresh(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: productosState.productosFiltrados.length,
                        itemBuilder: (context, index) {
                          final producto = productosState.productosFiltrados[index];
                          return ProductoCard(
                            producto: producto,
                            onEdit: () => _navegarAFormulario(context, ref, producto),
                            onToggleActivo: () {
                              ref.read(productosProvider.notifier).toggleActivo(producto.id);
                            },
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  void _navegarAFormulario(BuildContext context, WidgetRef ref, producto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductoFormScreen(producto: producto),
      ),
    );
  }
}
