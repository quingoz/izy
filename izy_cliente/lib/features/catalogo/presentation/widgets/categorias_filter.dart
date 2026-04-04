import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/productos_provider.dart';
import '../../../../core/constants/app_constants.dart';

class CategoriasFilter extends ConsumerWidget {
  final String comercioSlug;
  final Function(int?) onCategoriaSelected;

  const CategoriasFilter({
    super.key,
    required this.comercioSlug,
    required this.onCategoriaSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriasAsync = ref.watch(categoriasProvider(comercioSlug));
    final productosState = ref.watch(productosProvider(comercioSlug));

    return categoriasAsync.when(
      data: (categorias) {
        if (categorias.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: IzySpacing.md),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: IzySpacing.sm),
                child: FilterChip(
                  label: const Text('Todas'),
                  selected: productosState.categoriaSeleccionada == null,
                  onSelected: (selected) {
                    if (selected) onCategoriaSelected(null);
                  },
                ),
              ),
              ...categorias.map((categoria) {
                return Padding(
                  padding: const EdgeInsets.only(right: IzySpacing.sm),
                  child: FilterChip(
                    label: Text(categoria.nombre),
                    selected: productosState.categoriaSeleccionada == categoria.id,
                    onSelected: (selected) {
                      onCategoriaSelected(selected ? categoria.id : null);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 50,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
