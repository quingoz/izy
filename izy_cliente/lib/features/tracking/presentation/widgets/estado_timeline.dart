import 'package:flutter/material.dart';
import '../../data/models/pedido_tracking.dart';
import '../../../../core/constants/app_constants.dart';

class EstadoTimeline extends StatelessWidget {
  final String estadoActual;
  final List<EstadoHistorial> historial;

  const EstadoTimeline({
    super.key,
    required this.estadoActual,
    required this.historial,
  });

  @override
  Widget build(BuildContext context) {
    final estados = [
      EstadoInfo('pendiente', 'Pendiente', Icons.schedule),
      EstadoInfo('confirmado', 'Confirmado', Icons.check_circle_outline),
      EstadoInfo('preparando', 'Preparando', Icons.restaurant),
      EstadoInfo('listo', 'Listo', Icons.done_all),
      EstadoInfo('en_camino', 'En Camino', Icons.delivery_dining),
      EstadoInfo('entregado', 'Entregado', Icons.check_circle),
    ];

    final indexActual = estados.indexWhere((e) => e.codigo == estadoActual);

    return Column(
      children: List.generate(estados.length, (index) {
        final estado = estados[index];
        final isCompleted = index <= indexActual;
        final isCurrent = index == indexActual;

        return _buildEstadoItem(
          context,
          estado,
          isCompleted,
          isCurrent,
          isLast: index == estados.length - 1,
        );
      }),
    );
  }

  Widget _buildEstadoItem(
    BuildContext context,
    EstadoInfo estado,
    bool isCompleted,
    bool isCurrent, {
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    final color = isCompleted 
        ? theme.colorScheme.primary 
        : IzyColors.greyMedium;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? color : IzyColors.white,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(
                estado.icono,
                color: isCompleted ? IzyColors.white : color,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? color : IzyColors.greyLight,
              ),
          ],
        ),
        const SizedBox(width: IzySpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: IzySpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  estado.nombre,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted ? IzyColors.black : IzyColors.greyMedium,
                  ),
                ),
                if (isCurrent)
                  Text(
                    'Estado actual',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class EstadoInfo {
  final String codigo;
  final String nombre;
  final IconData icono;

  EstadoInfo(this.codigo, this.nombre, this.icono);
}
