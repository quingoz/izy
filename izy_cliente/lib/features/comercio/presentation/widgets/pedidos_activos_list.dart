import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/pedido_activo.dart';
import '../../../../core/constants/app_constants.dart';

class PedidosActivosList extends StatelessWidget {
  final List<PedidoActivo> pedidos;

  const PedidosActivosList({
    super.key,
    required this.pedidos,
  });

  @override
  Widget build(BuildContext context) {
    if (pedidos.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: IzyColors.greyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'No hay pedidos activos',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: IzyColors.greyDark,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pedidos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final pedido = pedidos[index];
        return _PedidoCard(pedido: pedido);
      },
    );
  }
}

class _PedidoCard extends StatelessWidget {
  final PedidoActivo pedido;

  const _PedidoCard({required this.pedido});

  Color _getEstadoColor() {
    switch (pedido.estado.toLowerCase()) {
      case 'pendiente':
        return IzyColors.warning;
      case 'preparando':
        return IzyColors.primary;
      case 'listo':
        return IzyColors.success;
      case 'en_camino':
        return IzyColors.secondary;
      default:
        return IzyColors.greyMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final timeFormat = DateFormat('HH:mm');

    return Card(
      elevation: 1,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(IzyRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pedido.numeroOrden,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pedido.cliente,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: IzyColors.greyDark,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getEstadoColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(IzyRadius.sm),
                    ),
                    child: Text(
                      pedido.estadoLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getEstadoColor(),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: IzyColors.greyDark,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeFormat.format(pedido.fechaCreacion),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: IzyColors.greyDark,
                        ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 16,
                    color: IzyColors.greyDark,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${pedido.cantidadItems} items',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: IzyColors.greyDark,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    currencyFormat.format(pedido.total),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: IzyColors.primary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
