import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/producto_model.dart';
import '../../../../core/constants/app_constants.dart';

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
          // TODO: Navegar a detalle
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          color: IzyColors.greyLight,
                          child: const Icon(Icons.fastfood, size: 48, color: IzyColors.greyMedium),
                        ),
                  
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
                              borderRadius: BorderRadius.circular(IzyRadius.md),
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
                              color: IzyColors.error,
                              borderRadius: BorderRadius.circular(IzyRadius.md),
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
            
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(IzySpacing.sm),
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
                              color: IzyColors.greyMedium,
                            ),
                          ),
                        if (producto.tieneOferta) const SizedBox(width: 4),
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
