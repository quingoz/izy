import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/estadisticas.dart';
import '../../../../core/constants/app_constants.dart';

class EstadisticasCard extends StatelessWidget {
  final Estadisticas? stats;

  const EstadisticasCard({
    super.key,
    this.estadisticas,
  }) : stats = estadisticas;

  final Estadisticas? estadisticas;

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de Hoy',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.attach_money,
                    label: 'Ventas',
                    value: currencyFormat.format(stats!.ventasHoy),
                    color: IzyColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatItem(
                    icon: Icons.receipt_long,
                    label: 'Pedidos',
                    value: stats!.pedidosHoy.toString(),
                    color: IzyColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.pending_actions,
                    label: 'Pendientes',
                    value: stats!.pedidosPendientes.toString(),
                    color: IzyColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatItem(
                    icon: Icons.trending_up,
                    label: 'Ticket Prom.',
                    value: currencyFormat.format(stats!.promedioTicket),
                    color: IzyColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(IzyRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: IzyColors.greyDark,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
