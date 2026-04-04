import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(IzySpacing.md),
      children: [
        _buildPeriodSelector(),
        const SizedBox(height: IzySpacing.lg),
        _buildRevenueCard(),
        const SizedBox(height: IzySpacing.md),
        _buildMetricsRow(),
        const SizedBox(height: IzySpacing.lg),
        _buildTopProductsCard(),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        const Text('Período:', style: IzyTextStyles.h4),
        const SizedBox(width: IzySpacing.md),
        Expanded(
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'day', label: Text('Hoy')),
              ButtonSegment(value: 'week', label: Text('Semana')),
              ButtonSegment(value: 'month', label: Text('Mes')),
            ],
            selected: const {'day'},
            onSelectionChanged: (Set<String> newSelection) {},
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(IzySpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_money, color: IzyColors.success),
                const SizedBox(width: IzySpacing.sm),
                const Text('Ingresos de Hoy', style: IzyTextStyles.h4),
              ],
            ),
            const SizedBox(height: IzySpacing.md),
            Text(
              '\$1,234.56',
              style: IzyTextStyles.h1.copyWith(color: IzyColors.success),
            ),
            const SizedBox(height: IzySpacing.sm),
            Row(
              children: [
                const Icon(Icons.trending_up, color: IzyColors.success, size: 16),
                const SizedBox(width: IzySpacing.xs),
                Text(
                  '+12.5% vs ayer',
                  style: IzyTextStyles.caption.copyWith(color: IzyColors.success),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Pedidos',
            '24',
            Icons.receipt_long_outlined,
            IzyColors.primary,
          ),
        ),
        const SizedBox(width: IzySpacing.md),
        Expanded(
          child: _buildMetricCard(
            'Ticket Promedio',
            '\$51.44',
            Icons.shopping_cart_outlined,
            IzyColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(IzySpacing.md),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: IzySpacing.sm),
            Text(value, style: IzyTextStyles.h3.copyWith(color: color)),
            const SizedBox(height: IzySpacing.xs),
            Text(title, style: IzyTextStyles.caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(IzySpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Productos Más Vendidos', style: IzyTextStyles.h4),
            const SizedBox(height: IzySpacing.md),
            ...List.generate(
              5,
              (index) => _buildTopProductItem(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductItem(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: IzySpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: IzyColors.primary.withOpacity(0.1),
            child: Text(
              '${index + 1}',
              style: IzyTextStyles.body.copyWith(color: IzyColors.primary),
            ),
          ),
          const SizedBox(width: IzySpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Producto ${index + 1}', style: IzyTextStyles.body),
                Text('${15 - index} vendidos', style: IzyTextStyles.caption),
              ],
            ),
          ),
          Text(
            '\$${(150 - index * 10)}.00',
            style: IzyTextStyles.body.copyWith(
              color: IzyColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
