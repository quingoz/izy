import 'package:flutter/material.dart';
import '../../data/models/pedido_tracking.dart';
import '../../../../core/constants/app_constants.dart';

class InfoPedidoCard extends StatelessWidget {
  final PedidoTracking pedido;

  const InfoPedidoCard({
    super.key,
    required this.pedido,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(IzySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido #${pedido.numeroPedido}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildEstadoBadge(pedido.estado, theme),
              ],
            ),
            const SizedBox(height: IzySpacing.md),
            
            _buildInfoRow(
              Icons.store,
              'Comercio',
              pedido.comercio.nombre,
            ),
            const SizedBox(height: IzySpacing.sm),
            
            if (pedido.repartidor != null) ...[
              _buildInfoRow(
                Icons.delivery_dining,
                'Repartidor',
                pedido.repartidor!.nombre,
              ),
              if (pedido.repartidor!.telefono != null) ...[
                const SizedBox(height: IzySpacing.xs),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Text(
                    pedido.repartidor!.telefono!,
                    style: IzyTextStyles.caption.copyWith(
                      color: IzyColors.greyMedium,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: IzySpacing.sm),
            ],
            
            _buildInfoRow(
              Icons.attach_money,
              'Total',
              '\$${pedido.totalUsd.toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: IzyColors.greyDark),
        const SizedBox(width: IzySpacing.md),
        Text(
          '$label: ',
          style: IzyTextStyles.body.copyWith(
            color: IzyColors.greyDark,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: IzyTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEstadoBadge(String estado, ThemeData theme) {
    Color color;
    String label;

    switch (estado) {
      case 'pendiente':
        color = IzyColors.warning;
        label = 'Pendiente';
        break;
      case 'confirmado':
        color = IzyColors.info;
        label = 'Confirmado';
        break;
      case 'preparando':
        color = IzyColors.warning;
        label = 'Preparando';
        break;
      case 'listo':
        color = IzyColors.info;
        label = 'Listo';
        break;
      case 'en_camino':
        color = IzyColors.primary;
        label = 'En Camino';
        break;
      case 'entregado':
        color = IzyColors.success;
        label = 'Entregado';
        break;
      default:
        color = IzyColors.greyMedium;
        label = estado;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: IzySpacing.md,
        vertical: IzySpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(IzyRadius.md),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
