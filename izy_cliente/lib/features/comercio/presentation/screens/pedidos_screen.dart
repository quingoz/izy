import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pedidos_provider.dart';
import '../widgets/pedido_card.dart';
import '../../domain/entities/pedido.dart';
import '../../../../core/constants/app_constants.dart';

class PedidosScreen extends ConsumerStatefulWidget {
  const PedidosScreen({super.key});

  @override
  ConsumerState<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends ConsumerState<PedidosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final pedidosState = ref.watch(pedidosProvider);

    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: IzyColors.primary,
            unselectedLabelColor: IzyColors.greyDark,
            indicatorColor: IzyColors.primary,
            tabs: [
              Tab(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Badge(
                      label: Text('${pedidosState.pendientes.length}'),
                      isLabelVisible: pedidosState.pendientes.isNotEmpty,
                      child: const Icon(Icons.fiber_new),
                    ),
                    const SizedBox(height: 4),
                    const Text('Nuevos', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Tab(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Badge(
                      label: Text('${pedidosState.preparando.length}'),
                      isLabelVisible: pedidosState.preparando.isNotEmpty,
                      child: const Icon(Icons.restaurant),
                    ),
                    const SizedBox(height: 4),
                    const Text('Preparando', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Tab(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Badge(
                      label: Text('${pedidosState.listos.length}'),
                      isLabelVisible: pedidosState.listos.isNotEmpty,
                      child: const Icon(Icons.done_all),
                    ),
                    const SizedBox(height: 4),
                    const Text('Listos', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Tab(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Badge(
                      label: Text('${pedidosState.enCamino.length}'),
                      isLabelVisible: pedidosState.enCamino.isNotEmpty,
                      child: const Icon(Icons.delivery_dining),
                    ),
                    const SizedBox(height: 4),
                    const Text('En Camino', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPedidosList(pedidosState.pendientes, 'pendiente'),
              _buildPedidosList(pedidosState.preparando, 'preparando'),
              _buildPedidosList(pedidosState.listos, 'listo'),
              _buildPedidosList(pedidosState.enCamino, 'en_camino'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPedidosList(List<Pedido> pedidos, String estado) {
    if (pedidos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: IzyColors.greyMedium),
            const SizedBox(height: 16),
            Text(
              'No hay pedidos',
              style: TextStyle(
                color: IzyColors.greyDark,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(pedidosProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pedidos.length,
        itemBuilder: (context, index) {
          return PedidoCard(
            pedido: pedidos[index],
            onEstadoChanged: (nuevoEstado) {
              _cambiarEstado(pedidos[index], nuevoEstado);
            },
          );
        },
      ),
    );
  }

  Future<void> _cambiarEstado(Pedido pedido, String nuevoEstado) async {
    String mensaje = '';
    switch (nuevoEstado) {
      case 'confirmado':
        mensaje = '¿Confirmar este pedido?';
        break;
      case 'preparando':
        mensaje = '¿Comenzar a preparar este pedido?';
        break;
      case 'listo':
        mensaje = '¿Marcar este pedido como listo?';
        break;
      case 'en_camino':
        mensaje = '¿Marcar este pedido en camino?';
        break;
      case 'cancelado':
        mensaje = '¿Cancelar este pedido?';
        break;
      default:
        mensaje = '¿Cambiar estado del pedido?';
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Estado'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: nuevoEstado == 'cancelado'
                  ? IzyColors.error
                  : IzyColors.primary,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(pedidosProvider.notifier).cambiarEstado(
            pedido.id,
            nuevoEstado,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pedido ${pedido.numeroPedido} actualizado'),
            backgroundColor: IzyColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
