import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/producto.dart';
import '../../../../core/constants/app_constants.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onEdit;
  final VoidCallback onToggleActivo;
  final VoidCallback? onDelete;

  const ProductoCard({
    super.key,
    required this.producto,
    required this.onEdit,
    required this.onToggleActivo,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(IzyRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: IzyColors.greyLight,
                  borderRadius: BorderRadius.circular(IzyRadius.md),
                  image: producto.imagenUrl != null
                      ? DecorationImage(
                          image: NetworkImage(producto.imagenUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: producto.imagenUrl == null
                    ? Icon(
                        Icons.fastfood,
                        size: 32,
                        color: IzyColors.greyMedium,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      producto.descripcion,
                      style: TextStyle(
                        fontSize: 13,
                        color: IzyColors.greyDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          currencyFormat.format(producto.precioUsd),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: IzyColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStockColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Stock: ${producto.stock}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _getStockColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 4),
                  Switch(
                    value: producto.activo,
                    onChanged: (_) => onToggleActivo(),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStockColor() {
    if (producto.stock == 0) return IzyColors.error;
    if (producto.stock < 5) return IzyColors.warning;
    return IzyColors.success;
  }
}
