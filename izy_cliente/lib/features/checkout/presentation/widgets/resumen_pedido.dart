import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../carrito/presentation/providers/carrito_provider.dart';
import '../providers/checkout_provider.dart';
import '../../../../core/constants/app_constants.dart';

class ResumenPedido extends ConsumerWidget {
  const ResumenPedido({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carritoState = ref.watch(carritoProvider);
    final checkoutState = ref.watch(checkoutProvider);
    final theme = Theme.of(context);

    final subtotal = carritoState.subtotalUsd;
    final deliveryFee = checkoutState.deliveryFeeUsd;
    final total = subtotal + deliveryFee;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(IzySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del Pedido',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: IzySpacing.md),
            
            _buildLinea('Subtotal', subtotal),
            const SizedBox(height: IzySpacing.sm),
            _buildLinea('Delivery', deliveryFee),
            
            const Divider(height: IzySpacing.lg),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: IzySpacing.sm),
            
            Text(
              '${carritoState.totalItems} items en el carrito',
              style: theme.textTheme.bodySmall?.copyWith(
                color: IzyColors.greyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinea(String label, double monto) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: IzyTextStyles.body),
        Text(
          '\$${monto.toStringAsFixed(2)}',
          style: IzyTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
