# Issue #23: Logística y Asignación de Repartidores

**Epic:** App Comercio  
**Prioridad:** Alta  
**Estimación:** 2 días  
**Sprint:** Sprint 3

---

## Descripción

Sistema para asignar repartidores a pedidos (manual o automático) y gestionar repartidores exclusivos.

## Objetivos

- Listar repartidores disponibles
- Asignación manual de repartidor
- Solicitar repartidores freelance
- Ver ubicación de repartidores
- Gestionar repartidores exclusivos

## Tareas Técnicas

### 1. Asignar Repartidor Dialog

```dart
Future<void> _mostrarAsignarRepartidor(BuildContext context, Pedido pedido) async {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Asignar Repartidor', style: Theme.of(context).textTheme.titleLarge),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Asignar Manualmente'),
            onTap: () {
              // Mostrar lista de repartidores
            },
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Solicitar Freelancers'),
            onTap: () {
              // Solicitar freelancers
            },
          ),
        ],
      ),
    ),
  );
}
```

## Definición de Hecho (DoD)

- [ ] Asignación manual funcional
- [ ] Solicitud de freelancers operativa
- [ ] Lista de repartidores disponibles
- [ ] Ver ubicación en mapa
- [ ] Tests pasando

## Dependencias

- Issue #21: Kitchen Flow

## Siguiente Issue

Issue #24: Setup App Android Repartidor
