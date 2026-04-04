import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class AccesosRapidos extends StatelessWidget {
  const AccesosRapidos({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accesos Rápidos',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _AccesoRapidoCard(
                icon: Icons.add_shopping_cart,
                label: 'Nuevo Pedido',
                color: IzyColors.primary,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AccesoRapidoCard(
                icon: Icons.inventory_2,
                label: 'Productos',
                color: IzyColors.secondary,
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _AccesoRapidoCard(
                icon: Icons.bar_chart,
                label: 'Reportes',
                color: IzyColors.accent,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AccesoRapidoCard(
                icon: Icons.settings,
                label: 'Configuración',
                color: IzyColors.greyDark,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AccesoRapidoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AccesoRapidoCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(IzyRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
