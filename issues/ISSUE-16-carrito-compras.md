# Issue #16: Carrito de Compras

**Epic:** PWA Cliente  
**Prioridad:** Alta  
**Estimación:** 2 días  
**Sprint:** Sprint 2

---

## Descripción

Implementar carrito de compras con gestión de items, variantes, cantidades y persistencia local.

## Objetivos

- Agregar/quitar productos
- Gestión de cantidades
- Manejo de variantes
- Cálculo de totales
- Persistencia con Hive
- Validación de stock

## Tareas Técnicas

### 1. Carrito Item Model

**Archivo:** `lib/features/carrito/data/models/carrito_item.dart`

```dart
import 'package:hive/hive.dart';

part 'carrito_item.g.dart';

@HiveType(typeId: 0)
class CarritoItem {
  @HiveField(0)
  final int productoId;

  @HiveField(1)
  final String nombre;

  @HiveField(2)
  final String? imagenUrl;

  @HiveField(3)
  final double precioUnitarioUsd;

  @HiveField(4)
  final double precioUnitarioBs;

  @HiveField(5)
  final int cantidad;

  @HiveField(6)
  final List<VarianteSeleccionada>? variantes;

  @HiveField(7)
  final String? notas;

  @HiveField(8)
  final int stockDisponible;

  CarritoItem({
    required this.productoId,
    required this.nombre,
    this.imagenUrl,
    required this.precioUnitarioUsd,
    required this.precioUnitarioBs,
    required this.cantidad,
    this.variantes,
    this.notas,
    required this.stockDisponible,
  });

  double get subtotalUsd => precioUnitarioUsd * cantidad;
  double get subtotalBs => precioUnitarioBs * cantidad;

  CarritoItem copyWith({
    int? cantidad,
    List<VarianteSeleccionada>? variantes,
    String? notas,
  }) {
    return CarritoItem(
      productoId: productoId,
      nombre: nombre,
      imagenUrl: imagenUrl,
      precioUnitarioUsd: precioUnitarioUsd,
      precioUnitarioBs: precioUnitarioBs,
      cantidad: cantidad ?? this.cantidad,
      variantes: variantes ?? this.variantes,
      notas: notas ?? this.notas,
      stockDisponible: stockDisponible,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'producto_id': productoId,
      'cantidad': cantidad,
      'variantes': variantes?.map((v) => v.toJson()).toList(),
      'notas': notas,
    };
  }
}

@HiveType(typeId: 1)
class VarianteSeleccionada {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String value;

  @HiveField(2)
  final double? priceUsd;

  @HiveField(3)
  final double? priceBs;

  VarianteSeleccionada({
    required this.name,
    required this.value,
    this.priceUsd,
    this.priceBs,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'price_usd': priceUsd,
      'price_bs': priceBs,
    };
  }
}
```

### 2. Carrito Provider

**Archivo:** `lib/features/carrito/presentation/providers/carrito_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/models/carrito_item.dart';
import '../../../catalogo/data/models/producto_model.dart';

final carritoProvider = StateNotifierProvider<CarritoNotifier, CarritoState>((ref) {
  return CarritoNotifier();
});

class CarritoState {
  final List<CarritoItem> items;
  final String? comercioSlug;
  final int? comercioId;

  CarritoState({
    this.items = const [],
    this.comercioSlug,
    this.comercioId,
  });

  CarritoState copyWith({
    List<CarritoItem>? items,
    String? comercioSlug,
    int? comercioId,
  }) {
    return CarritoState(
      items: items ?? this.items,
      comercioSlug: comercioSlug ?? this.comercioSlug,
      comercioId: comercioId ?? this.comercioId,
    );
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.cantidad);

  double get subtotalUsd => items.fold(0, (sum, item) => sum + item.subtotalUsd);
  double get subtotalBs => items.fold(0, (sum, item) => sum + item.subtotalBs);

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}

class CarritoNotifier extends StateNotifier<CarritoState> {
  CarritoNotifier() : super(CarritoState()) {
    _loadCarrito();
  }

  Future<void> _loadCarrito() async {
    final box = await Hive.openBox<CarritoItem>('carrito');
    final items = box.values.toList();
    
    final metaBox = await Hive.openBox('carrito_meta');
    final comercioSlug = metaBox.get('comercio_slug');
    final comercioId = metaBox.get('comercio_id');

    state = state.copyWith(
      items: items,
      comercioSlug: comercioSlug,
      comercioId: comercioId,
    );
  }

  Future<void> _saveCarrito() async {
    final box = await Hive.openBox<CarritoItem>('carrito');
    await box.clear();
    await box.addAll(state.items);

    final metaBox = await Hive.openBox('carrito_meta');
    await metaBox.put('comercio_slug', state.comercioSlug);
    await metaBox.put('comercio_id', state.comercioId);
  }

  Future<bool> agregarProducto(
    Producto producto, {
    int cantidad = 1,
    List<VarianteSeleccionada>? variantes,
    String? notas,
    String? comercioSlug,
    int? comercioId,
  }) async {
    // Validar que sea del mismo comercio
    if (state.isNotEmpty && state.comercioId != comercioId) {
      return false; // Debe limpiar carrito primero
    }

    // Validar stock
    if (!producto.stockIlimitado && producto.stock < cantidad) {
      return false;
    }

    final precioUsd = producto.getPrecioFinal('usd') + 
        (variantes?.fold(0.0, (sum, v) => sum + (v.priceUsd ?? 0)) ?? 0);
    final precioBs = producto.getPrecioFinal('bs') + 
        (variantes?.fold(0.0, (sum, v) => sum + (v.priceBs ?? 0)) ?? 0);

    final nuevoItem = CarritoItem(
      productoId: producto.id,
      nombre: producto.nombre,
      imagenUrl: producto.imagenUrl,
      precioUnitarioUsd: precioUsd,
      precioUnitarioBs: precioBs,
      cantidad: cantidad,
      variantes: variantes,
      notas: notas,
      stockDisponible: producto.stock,
    );

    // Buscar si ya existe
    final index = state.items.indexWhere((item) => 
        item.productoId == producto.id &&
        _variantesIguales(item.variantes, variantes));

    List<CarritoItem> nuevosItems;
    if (index >= 0) {
      // Actualizar cantidad
      final itemExistente = state.items[index];
      final nuevaCantidad = itemExistente.cantidad + cantidad;
      
      if (!producto.stockIlimitado && nuevaCantidad > producto.stock) {
        return false;
      }

      nuevosItems = List.from(state.items);
      nuevosItems[index] = itemExistente.copyWith(cantidad: nuevaCantidad);
    } else {
      // Agregar nuevo
      nuevosItems = [...state.items, nuevoItem];
    }

    state = state.copyWith(
      items: nuevosItems,
      comercioSlug: comercioSlug ?? state.comercioSlug,
      comercioId: comercioId ?? state.comercioId,
    );

    await _saveCarrito();
    return true;
  }

  Future<void> actualizarCantidad(int index, int nuevaCantidad) async {
    if (index < 0 || index >= state.items.length) return;

    final item = state.items[index];
    
    if (nuevaCantidad <= 0) {
      await removerItem(index);
      return;
    }

    if (nuevaCantidad > item.stockDisponible) {
      return; // No permitir más del stock
    }

    final nuevosItems = List<CarritoItem>.from(state.items);
    nuevosItems[index] = item.copyWith(cantidad: nuevaCantidad);

    state = state.copyWith(items: nuevosItems);
    await _saveCarrito();
  }

  Future<void> removerItem(int index) async {
    final nuevosItems = List<CarritoItem>.from(state.items);
    nuevosItems.removeAt(index);

    state = state.copyWith(items: nuevosItems);
    await _saveCarrito();
  }

  Future<void> limpiarCarrito() async {
    state = CarritoState();
    final box = await Hive.openBox<CarritoItem>('carrito');
    await box.clear();
    final metaBox = await Hive.openBox('carrito_meta');
    await metaBox.clear();
  }

  bool _variantesIguales(
    List<VarianteSeleccionada>? v1,
    List<VarianteSeleccionada>? v2,
  ) {
    if (v1 == null && v2 == null) return true;
    if (v1 == null || v2 == null) return false;
    if (v1.length != v2.length) return false;

    for (var i = 0; i < v1.length; i++) {
      if (v1[i].name != v2[i].name || v1[i].value != v2[i].value) {
        return false;
      }
    }

    return true;
  }
}
```

### 3. Carrito Screen

**Archivo:** `lib/features/carrito/presentation/screens/carrito_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/carrito_provider.dart';
import '../widgets/carrito_item_card.dart';

class CarritoScreen extends ConsumerWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carritoState = ref.watch(carritoProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        actions: [
          if (carritoState.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                _mostrarConfirmacionLimpiar(context, ref);
              },
            ),
        ],
      ),
      body: carritoState.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tu carrito está vacío',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega productos para comenzar',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: carritoState.items.length,
                    itemBuilder: (context, index) {
                      return CarritoItemCard(
                        item: carritoState.items[index],
                        index: index,
                      );
                    },
                  ),
                ),
                _buildResumen(context, carritoState, theme),
              ],
            ),
    );
  }

  Widget _buildResumen(BuildContext context, CarritoState state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal (${state.totalItems} items)',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  '\$${state.subtotalUsd.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navegar a checkout
                },
                child: const Text('Continuar al Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarConfirmacionLimpiar(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Carrito'),
        content: const Text('¿Estás seguro de que quieres vaciar el carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(carritoProvider.notifier).limpiarCarrito();
              Navigator.pop(context);
            },
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }
}
```

### 4. Carrito Item Card

**Archivo:** `lib/features/carrito/presentation/widgets/carrito_item_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/carrito_item.dart';
import '../providers/carrito_provider.dart';

class CarritoItemCard extends ConsumerWidget {
  final CarritoItem item;
  final int index;

  const CarritoItemCard({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.imagenUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.imagenUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.fastfood),
                    ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nombre,
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.variantes != null && item.variantes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.variantes!.map((v) => '${v.name}: ${v.value}').join(', '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  if (item.notas != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Nota: ${item.notas}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${item.precioUnitarioUsd.toStringAsFixed(2)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      _buildCantidadControl(context, ref),
                    ],
                  ),
                ],
              ),
            ),

            // Eliminar
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                ref.read(carritoProvider.notifier).removerItem(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCantidadControl(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: () {
              ref.read(carritoProvider.notifier)
                  .actualizarCantidad(index, item.cantidad - 1);
            },
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${item.cantidad}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: item.cantidad < item.stockDisponible
                ? () {
                    ref.read(carritoProvider.notifier)
                        .actualizarCantidad(index, item.cantidad + 1);
                  }
                : null,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
```

## Definición de Hecho (DoD)

- [ ] Agregar productos al carrito
- [ ] Actualizar cantidades
- [ ] Remover items
- [ ] Limpiar carrito completo
- [ ] Manejo de variantes
- [ ] Validación de stock
- [ ] Persistencia con Hive
- [ ] Cálculo de totales correcto
- [ ] Tests pasando

## Comandos de Verificación

```bash
flutter test
flutter run -d chrome
```

## Dependencias

- Issue #15: Catálogo de Productos

## Siguiente Issue

Issue #17: Checkout y Métodos de Pago
