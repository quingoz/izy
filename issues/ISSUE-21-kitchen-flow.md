# Issue #21: Kitchen Flow (Gestión de Estados)

**Epic:** App Comercio  
**Prioridad:** Alta  
**Estimación:** 3 días  
**Sprint:** Sprint 3

---

## Descripción

Implementar flujo de cocina para gestionar estados de pedidos: confirmar, preparar, marcar listo.

## Objetivos

- Vista de pedidos por estado
- Cambio de estados con validación
- Notificaciones al cambiar estado
- Temporizadores de preparación
- Sonido de alerta para nuevos pedidos

## Tareas Técnicas

### 1. Pedidos Screen

**Archivo:** `lib/features/comercio/presentation/screens/pedidos_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pedidos_provider.dart';
import '../widgets/pedido_card.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Nuevos',
              icon: Badge(
                label: Text('${pedidosState.pendientes.length}'),
                child: const Icon(Icons.fiber_new),
              ),
            ),
            const Tab(text: 'Preparando', icon: Icon(Icons.restaurant)),
            const Tab(text: 'Listos', icon: Icon(Icons.done_all)),
            const Tab(text: 'En Camino', icon: Icon(Icons.delivery_dining)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPedidosList(pedidosState.pendientes, 'pendiente'),
          _buildPedidosList(pedidosState.preparando, 'preparando'),
          _buildPedidosList(pedidosState.listos, 'listo'),
          _buildPedidosList(pedidosState.enCamino, 'en_camino'),
        ],
      ),
    );
  }

  Widget _buildPedidosList(List<Pedido> pedidos, String estado) {
    if (pedidos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay pedidos',
              style: TextStyle(color: Colors.grey[600]),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Estado'),
        content: Text('¿Cambiar pedido a $nuevoEstado?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
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
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
```

### 2. Pedido Card Widget

**Archivo:** `lib/features/comercio/presentation/widgets/pedido_card.dart`

```dart
import 'package:flutter/material.dart';
import '../../data/models/pedido.dart';

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
          'Pedido #${pedido.numeroPedido}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${pedido.clienteNombre}'),
            Text(
              'Total: \$${pedido.totalUsd.toStringAsFixed(2)}',
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
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...pedido.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text('${item.cantidad}x '),
                      Expanded(child: Text(item.nombreProducto)),
                      Text('\$${item.subtotalUsd.toStringAsFixed(2)}'),
                    ],
                  ),
                )),
                if (pedido.notasCliente != null) ...[
                  const Divider(height: 24),
                  Text(
                    'Notas:',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pedido.notasCliente!,
                    style: const TextStyle(fontStyle: FontStyle.italic),
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

    return Wrap(
      spacing: 8,
      children: acciones.map((accion) {
        return ElevatedButton.icon(
          onPressed: () => onEstadoChanged(accion.estado),
          icon: Icon(accion.icono),
          label: Text(accion.label),
          style: ElevatedButton.styleFrom(
            backgroundColor: accion.color,
          ),
        );
      }).toList(),
    );
  }

  List<AccionEstado> _getAccionesDisponibles() {
    switch (pedido.estado) {
      case 'pendiente':
        return [
          AccionEstado('confirmado', 'Confirmar', Icons.check, Colors.green),
          AccionEstado('cancelado', 'Cancelar', Icons.close, Colors.red),
        ];
      case 'confirmado':
        return [
          AccionEstado('preparando', 'Preparar', Icons.restaurant, Colors.orange),
        ];
      case 'preparando':
        return [
          AccionEstado('listo', 'Marcar Listo', Icons.done_all, Colors.blue),
        ];
      default:
        return [];
    }
  }

  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.orange;
      case 'confirmado':
      case 'preparando':
        return Colors.blue;
      case 'listo':
        return Colors.green;
      case 'en_camino':
        return Colors.purple;
      default:
        return Colors.grey;
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
    if (minutos > 45) return Colors.red;
    if (minutos > 30) return Colors.orange;
    return Colors.grey;
  }
}

class AccionEstado {
  final String estado;
  final String label;
  final IconData icono;
  final Color color;

  AccionEstado(this.estado, this.label, this.icono, this.color);
}
```

## Definición de Hecho (DoD)

- [ ] Vista de pedidos por estado
- [ ] Cambio de estados funcional
- [ ] Validaciones implementadas
- [ ] Notificaciones al cambiar estado
- [ ] Temporizadores visibles
- [ ] Sonido para nuevos pedidos
- [ ] Tests pasando

## Comandos de Verificación

```bash
flutter test
flutter run --flavor comercio
```

## Dependencias

- Issue #20: Dashboard de Comercio

## Siguiente Issue

Issue #22: Gestión de Productos
