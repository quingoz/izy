import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/carrito_item.dart';
import '../providers/carrito_provider.dart';
import '../../../../core/constants/app_constants.dart';

class CarritoItemCard extends ConsumerWidget {
  final CarritoItem item;
  final int index;

  const CarritoItemCard({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: IzySpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(IzySpacing.md),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(IzyRadius.sm),
              child: item.imagenUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.imagenUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 80,
                        height: 80,
                        color: IzyColors.greyLight,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 80,
                        height: 80,
                        color: IzyColors.greyLight,
                        child: const Icon(Icons.fastfood),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: IzyColors.greyLight,
                      child: const Icon(Icons.fastfood, color: IzyColors.greyMedium),
                    ),
            ),
            const SizedBox(width: IzySpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nombre,
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.variantes != null && item.variantes!.isNotEmpty) ...[
                    const SizedBox(height: IzySpacing.xs),
                    Text(
                      item.variantes!.map((v) => '${v.name}: ${v.value}').join(', '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: IzyColors.greyMedium,
                      ),
                    ),
                  ],
                  if (item.notas != null) ...[
                    const SizedBox(height: IzySpacing.xs),
                    Text(
                      'Nota: ${item.notas}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: IzySpacing.sm),
                  Row(
                    children: [
                      Text(
                        '\$${item.precioUnitarioUsd.toStringAsFixed(2)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      _buildCantidadControl(context, ref),
                    ],
                  ),
                ],
              ),
            ),

            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: IzyColors.error,
              onPressed: () {
                ref.read(carritoProvider.notifier).removerItem(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCantidadControl(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: IzyColors.greyMedium),
        borderRadius: BorderRadius.circular(IzyRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: () {
              ref.read(carritoProvider.notifier)
                  .actualizarCantidad(index, item.cantidad - 1);
            },
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: IzySpacing.md),
            child: Text(
              '${item.cantidad}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: item.cantidad < item.stockDisponible
                ? () {
                    ref.read(carritoProvider.notifier)
                        .actualizarCantidad(index, item.cantidad + 1);
                  }
                : null,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
