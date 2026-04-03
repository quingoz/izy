# Issue #26: Gestión de Pedidos Disponibles

**Epic:** App Repartidor  
**Prioridad:** Alta  
**Estimación:** 2 días  
**Sprint:** Sprint 4

---

## Descripción

Vista de pedidos disponibles para repartidores freelance con información de distancia y ganancia estimada.

## Objetivos

- Listar pedidos cercanos disponibles
- Mostrar distancia y ganancia
- Aceptar/rechazar pedidos
- Notificaciones de nuevos pedidos
- Filtros por distancia

## Tareas Técnicas

### 1. Pedidos Disponibles Screen

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PedidosDisponiblesScreen extends ConsumerWidget {
  const PedidosDisponiblesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pedidos = ref.watch(pedidosDisponiblesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos Disponibles'),
      ),
      body: ListView.builder(
        itemCount: pedidos.length,
        itemBuilder: (context, index) {
          final pedido = pedidos[index];
          return Card(
            child: ListTile(
              title: Text('Pedido #${pedido.numero}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Distancia: ${pedido.distanciaKm} km'),
                  Text('Ganancia: \$${pedido.gananciaUsd}'),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  // Aceptar pedido
                },
                child: const Text('Aceptar'),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

## Definición de Hecho (DoD)

- [ ] Lista de pedidos disponibles
- [ ] Cálculo de distancia correcto
- [ ] Aceptar/rechazar funcional
- [ ] Notificaciones push
- [ ] Filtros operativos
- [ ] Tests pasando

## Dependencias

- Issue #25: GPS Tracking en Segundo Plano

## Siguiente Issue

Issue #27: Navegación y Entrega
