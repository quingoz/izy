import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/carrito_provider.dart';
import '../widgets/carrito_item_card.dart';
import '../../../../core/constants/app_constants.dart';

class CarritoScreen extends ConsumerWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carritoState = ref.watch(carritoProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        actions: [
          if (carritoState.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                _mostrarConfirmacionLimpiar(context, ref);
              },
            ),
        ],
      ),
      body: carritoState.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: IzyColors.greyMedium,
                  ),
                  const SizedBox(height: IzySpacing.md),
                  Text(
                    'Tu carrito está vacío',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: IzyColors.greyDark,
                    ),
                  ),
                  const SizedBox(height: IzySpacing.sm),
                  Text(
                    'Agrega productos para comenzar',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: IzyColors.greyMedium,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(IzySpacing.md),
                    itemCount: carritoState.items.length,
                    itemBuilder: (context, index) {
                      return CarritoItemCard(
                        item: carritoState.items[index],
                        index: index,
                      );
                    },
                  ),
                ),
                _buildResumen(context, carritoState, theme),
              ],
            ),
    );
  }

  Widget _buildResumen(BuildContext context, CarritoState state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(IzySpacing.md),
      decoration: BoxDecoration(
        color: IzyColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal (${state.totalItems} items)',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  '\$${state.subtotalUsd.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: IzySpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navegar a checkout
                },
                child: const Text('Continuar al Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarConfirmacionLimpiar(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Carrito'),
        content: const Text('¿Estás seguro de que quieres vaciar el carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(carritoProvider.notifier).limpiarCarrito();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: IzyColors.error,
            ),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }
}
