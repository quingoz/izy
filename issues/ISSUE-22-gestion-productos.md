# Issue #22: Gestión de Productos

**Epic:** App Comercio  
**Prioridad:** Media  
**Estimación:** 2 días  
**Sprint:** Sprint 3

---

## Descripción

CRUD completo de productos desde la app de comercio con imágenes, variantes y stock.

## Objetivos

- Listar productos del comercio
- Crear/editar productos
- Gestión de stock
- Subir imágenes
- Activar/desactivar productos

## Tareas Técnicas

### 1. Productos Screen

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductosScreen extends ConsumerWidget {
  const ProductosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navegar a crear producto
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(),
            title: Text('Producto'),
            subtitle: Text('\$10.00'),
            trailing: Switch(value: true, onChanged: (v) {}),
          );
        },
      ),
    );
  }
}
```

## Definición de Hecho (DoD)

- [ ] CRUD completo de productos
- [ ] Subida de imágenes
- [ ] Gestión de stock
- [ ] Activar/desactivar productos
- [ ] Tests pasando

## Dependencias

- Issue #21: Kitchen Flow

## Siguiente Issue

Issue #23: Logística y Asignación de Repartidores
