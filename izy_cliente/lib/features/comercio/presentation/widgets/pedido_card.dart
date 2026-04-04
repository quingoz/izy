import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/pedido.dart';
import 'asignar_repartidor_sheet.dart';
import '../../../../core/constants/app_constants.dart';

class PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final Function(String) onEstadoChanged;

  const PedidoCard({
    super.key,
    required this.pedido,
    required this.onEstadoChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getColorEstado(pedido.estado),
          child: Text(
            '#${pedido.numeroPedido.split('-').last}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          'Pedido ${pedido.numeroPedido}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Cliente: ${pedido.clienteNombre}'),
            Text(
              'Total: ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(pedido.totalUsd)}',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _getTiempoTranscurrido(),
              style: TextStyle(
                fontSize: 12,
                color: _getTiempoColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Items:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...pedido.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: IzyColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${item.cantidad}x',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(item.nombreProducto)),
                          Text(
                            NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                                .format(item.subtotalUsd),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )),
                if (pedido.notasCliente != null) ...[
                  const Divider(height: 24),
                  Text(
                    'Notas del Cliente:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: IzyColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: IzyColors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 20,
                          color: IzyColors.warning,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pedido.notasCliente!,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (pedido.direccionEntrega != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: IzyColors.greyDark,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          pedido.direccionEntrega!,
                          style: TextStyle(
                            fontSize: 12,
                            color: IzyColors.greyDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const Divider(height: 24),
                _buildAcciones(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcciones(BuildContext context) {
    final acciones = _getAccionesDisponibles();

    if (acciones.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: acciones.map((accion) {
        return ElevatedButton.icon(
          onPressed: () {
            if (accion.estado == 'asignar_repartidor') {
              _mostrarAsignarRepartidor(context);
            } else {
              onEstadoChanged(accion.estado);
            }
          },
          icon: Icon(accion.icono, size: 18),
          label: Text(accion.label),
          style: ElevatedButton.styleFrom(
            backgroundColor: accion.color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _mostrarAsignarRepartidor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AsignarRepartidorSheet(
        pedido: pedido,
        onAsignar: (repartidor) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Repartidor ${repartidor.nombre} asignado'),
              backgroundColor: IzyColors.success,
            ),
          );
          onEstadoChanged('en_camino');
        },
      ),
    );
  }

  List<AccionEstado> _getAccionesDisponibles() {
    switch (pedido.estado) {
      case 'pendiente':
        return [
          AccionEstado('confirmado', 'Confirmar', Icons.check, IzyColors.success),
          AccionEstado('cancelado', 'Cancelar', Icons.close, IzyColors.error),
        ];
      case 'confirmado':
        return [
          AccionEstado('preparando', 'Preparar', Icons.restaurant, IzyColors.warning),
        ];
      case 'preparando':
        return [
          AccionEstado('listo', 'Marcar Listo', Icons.done_all, IzyColors.primary),
        ];
      case 'listo':
        return [
          AccionEstado('en_camino', 'En Camino', Icons.delivery_dining, IzyColors.secondary),
        ];
      default:
        return [];
    }
  }

  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return IzyColors.warning;
      case 'confirmado':
      case 'preparando':
        return IzyColors.primary;
      case 'listo':
        return IzyColors.success;
      case 'en_camino':
        return IzyColors.secondary;
      case 'entregado':
        return IzyColors.info;
      case 'cancelado':
        return IzyColors.error;
      default:
        return IzyColors.greyMedium;
    }
  }

  String _getTiempoTranscurrido() {
    final diff = DateTime.now().difference(pedido.createdAt);
    if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes} min';
    }
    return 'Hace ${diff.inHours}h ${diff.inMinutes % 60}min';
  }

  Color _getTiempoColor() {
    final minutos = DateTime.now().difference(pedido.createdAt).inMinutes;
    if (minutos > 45) return IzyColors.error;
    if (minutos > 30) return IzyColors.warning;
    return IzyColors.greyDark;
  }
}

class AccionEstado {
  final String estado;
  final String label;
  final IconData icono;
  final Color color;

  AccionEstado(this.estado, this.label, this.icono, this.color);
}
