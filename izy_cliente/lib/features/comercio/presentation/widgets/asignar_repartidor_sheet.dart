import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pedido.dart';
import '../../domain/entities/repartidor.dart';
import '../providers/repartidores_provider.dart';
import '../../../../core/constants/app_constants.dart';

class AsignarRepartidorSheet extends ConsumerWidget {
  final Pedido pedido;
  final Function(Repartidor) onAsignar;

  const AsignarRepartidorSheet({
    super.key,
    required this.pedido,
    required this.onAsignar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repartidoresState = ref.watch(repartidoresProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: IzyColors.greyMedium,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Asignar Repartidor',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pedido ${pedido.numeroPedido}',
            style: TextStyle(
              color: IzyColors.greyDark,
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: IzyColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_search,
                color: IzyColors.primary,
              ),
            ),
            title: const Text('Asignar Manualmente'),
            subtitle: Text(
              '${repartidoresState.disponibles.length} repartidores disponibles',
              style: TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              _mostrarListaRepartidores(context, ref);
            },
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: IzyColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.group_add,
                color: IzyColors.secondary,
              ),
            ),
            title: const Text('Solicitar Freelancers'),
            subtitle: const Text(
              'Enviar solicitud a repartidores externos',
              style: TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _solicitarFreelancers(context, ref),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _mostrarListaRepartidores(BuildContext context, WidgetRef ref) {
    final repartidoresState = ref.read(repartidoresProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: IzyColors.greyMedium,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Seleccionar Repartidor',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: repartidoresState.disponibles.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_off,
                                size: 64,
                                color: IzyColors.greyMedium,
                              ),
                              const SizedBox(height: 16),
                              const Text('No hay repartidores disponibles'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: repartidoresState.disponibles.length,
                          itemBuilder: (context, index) {
                            final repartidor = repartidoresState.disponibles[index];
                            return _RepartidorTile(
                              repartidor: repartidor,
                              onTap: () {
                                Navigator.pop(context);
                                onAsignar(repartidor);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _solicitarFreelancers(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    await ref.read(repartidoresProvider.notifier).solicitarFreelancers();

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud enviada a repartidores freelance'),
          backgroundColor: IzyColors.success,
        ),
      );
    }
  }
}

class _RepartidorTile extends StatelessWidget {
  final Repartidor repartidor;
  final VoidCallback onTap;

  const _RepartidorTile({
    required this.repartidor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: IzyColors.primary,
          child: repartidor.fotoUrl != null
              ? ClipOval(
                  child: Image.network(
                    repartidor.fotoUrl!,
                    fit: BoxFit.cover,
                  ),
                )
              : Text(
                  repartidor.nombre[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                repartidor.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (repartidor.esExclusivo)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: IzyColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Exclusivo',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: IzyColors.accent,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${repartidor.calificacion.toStringAsFixed(1)} (${repartidor.pedidosCompletados} pedidos)',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            if (repartidor.vehiculo != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    repartidor.vehiculo == 'Moto'
                        ? Icons.motorcycle
                        : Icons.pedal_bike,
                    size: 14,
                    color: IzyColors.greyDark,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    repartidor.vehiculo!,
                    style: TextStyle(
                      fontSize: 12,
                      color: IzyColors.greyDark,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
          child: const Text('Asignar'),
        ),
      ),
    );
  }
}
