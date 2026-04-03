# Issue #17: Checkout y Métodos de Pago

**Epic:** PWA Cliente  
**Prioridad:** Alta  
**Estimación:** 3 días  
**Sprint:** Sprint 2

---

## Descripción

Implementar proceso de checkout completo con selección de dirección, métodos de pago y creación de pedido.

## Objetivos

- Formulario de dirección de entrega
- Selección de método de pago
- Validación de pedido mínimo
- Cálculo de delivery fee
- Creación de pedido
- Manejo de errores

## Tareas Técnicas

### 1. Checkout Screen

**Archivo:** `lib/features/checkout/presentation/screens/checkout_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/checkout_provider.dart';
import '../widgets/direccion_selector.dart';
import '../widgets/metodo_pago_selector.dart';
import '../widgets/resumen_pedido.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notasController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: checkoutState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dirección de entrega
                    Text(
                      'Dirección de Entrega',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    const DireccionSelector(),
                    
                    const SizedBox(height: 24),
                    
                    // Método de pago
                    Text(
                      'Método de Pago',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    const MetodoPagoSelector(),
                    
                    const SizedBox(height: 24),
                    
                    // Notas
                    Text(
                      'Notas para el comercio',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notasController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Ej: Sin cebolla, extra picante...',
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Resumen
                    const ResumenPedido(),
                    
                    const SizedBox(height: 24),
                    
                    // Botón confirmar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: checkoutState.canConfirm
                            ? () => _confirmarPedido()
                            : null,
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Confirmar Pedido'),
                        ),
                      ),
                    ),
                    
                    if (checkoutState.error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          checkoutState.error!,
                          style: TextStyle(color: Colors.red[900]),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _confirmarPedido() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(checkoutProvider.notifier).crearPedido(
      notasCliente: _notasController.text.trim(),
    );

    if (success && mounted) {
      // Navegar a tracking
      Navigator.pushReplacementNamed(context, '/tracking');
    }
  }

  @override
  void dispose() {
    _notasController.dispose();
    super.dispose();
  }
}
```

### 2. Checkout Provider

**Archivo:** `lib/features/checkout/presentation/providers/checkout_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../carrito/presentation/providers/carrito_provider.dart';
import '../../data/repositories/pedido_repository.dart';
import '../../data/models/direccion.dart';

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(ref);
});

class CheckoutState {
  final Direccion? direccion;
  final String? metodoPago;
  final Map<String, dynamic>? pagoMovilData;
  final double? vueltoDe;
  final double deliveryFeeUsd;
  final double deliveryFeeBs;
  final bool isLoading;
  final String? error;

  CheckoutState({
    this.direccion,
    this.metodoPago,
    this.pagoMovilData,
    this.vueltoDe,
    this.deliveryFeeUsd = 2.0,
    this.deliveryFeeBs = 70.0,
    this.isLoading = false,
    this.error,
  });

  CheckoutState copyWith({
    Direccion? direccion,
    String? metodoPago,
    Map<String, dynamic>? pagoMovilData,
    double? vueltoDe,
    double? deliveryFeeUsd,
    double? deliveryFeeBs,
    bool? isLoading,
    String? error,
  }) {
    return CheckoutState(
      direccion: direccion ?? this.direccion,
      metodoPago: metodoPago ?? this.metodoPago,
      pagoMovilData: pagoMovilData ?? this.pagoMovilData,
      vueltoDe: vueltoDe ?? this.vueltoDe,
      deliveryFeeUsd: deliveryFeeUsd ?? this.deliveryFeeUsd,
      deliveryFeeBs: deliveryFeeBs ?? this.deliveryFeeBs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get canConfirm => 
      direccion != null && 
      metodoPago != null &&
      !isLoading;
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final Ref _ref;
  final PedidoRepository _repository = PedidoRepository();

  CheckoutNotifier(this._ref) : super(CheckoutState());

  void setDireccion(Direccion direccion) {
    state = state.copyWith(direccion: direccion);
  }

  void setMetodoPago(String metodo) {
    state = state.copyWith(metodoPago: metodo);
  }

  void setPagoMovilData(Map<String, dynamic> data) {
    state = state.copyWith(pagoMovilData: data);
  }

  void setVueltoDe(double monto) {
    state = state.copyWith(vueltoDe: monto);
  }

  Future<bool> crearPedido({String? notasCliente}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final carritoState = _ref.read(carritoProvider);
      
      if (carritoState.isEmpty) {
        throw Exception('El carrito está vacío');
      }

      if (state.direccion == null) {
        throw Exception('Selecciona una dirección de entrega');
      }

      if (state.metodoPago == null) {
        throw Exception('Selecciona un método de pago');
      }

      final pedidoData = {
        'comercio_id': carritoState.comercioId,
        'items': carritoState.items.map((item) => item.toJson()).toList(),
        'tipo_pago': state.metodoPago,
        'direccion': state.direccion!.toJson(),
        'notas_cliente': notasCliente,
        if (state.metodoPago == 'efectivo' && state.vueltoDe != null)
          'vuelto_de': state.vueltoDe,
        if (state.metodoPago == 'pago_movil' && state.pagoMovilData != null)
          'pago_movil': state.pagoMovilData,
      };

      await _repository.crearPedido(pedidoData);

      // Limpiar carrito
      await _ref.read(carritoProvider.notifier).limpiarCarrito();

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
}
```

### 3. Direccion Model

**Archivo:** `lib/features/checkout/data/models/direccion.dart`

```dart
class Direccion {
  final int? id;
  final String calle;
  final String? ciudad;
  final String? estado;
  final String? referencia;
  final double lat;
  final double lng;
  final String? alias;

  Direccion({
    this.id,
    required this.calle,
    this.ciudad,
    this.estado,
    this.referencia,
    required this.lat,
    required this.lng,
    this.alias,
  });

  factory Direccion.fromJson(Map<String, dynamic> json) {
    return Direccion(
      id: json['id'],
      calle: json['calle'],
      ciudad: json['ciudad'],
      estado: json['estado'],
      referencia: json['referencia'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      alias: json['alias'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'calle': calle,
      'ciudad': ciudad,
      'estado': estado,
      'referencia': referencia,
      'lat': lat,
      'lng': lng,
      'alias': alias,
    };
  }
}
```

### 4. Metodo Pago Selector

**Archivo:** `lib/features/checkout/presentation/widgets/metodo_pago_selector.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/checkout_provider.dart';

class MetodoPagoSelector extends ConsumerWidget {
  const MetodoPagoSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkoutState = ref.watch(checkoutProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildMetodoOption(
          context,
          ref,
          'efectivo',
          'Efectivo',
          Icons.money,
          checkoutState.metodoPago == 'efectivo',
        ),
        const SizedBox(height: 8),
        _buildMetodoOption(
          context,
          ref,
          'pago_movil',
          'Pago Móvil',
          Icons.phone_android,
          checkoutState.metodoPago == 'pago_movil',
        ),
        const SizedBox(height: 8),
        _buildMetodoOption(
          context,
          ref,
          'transferencia',
          'Transferencia',
          Icons.account_balance,
          checkoutState.metodoPago == 'transferencia',
        ),
        
        if (checkoutState.metodoPago == 'efectivo') ...[
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Vuelto de (Bs)',
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final monto = double.tryParse(value);
              if (monto != null) {
                ref.read(checkoutProvider.notifier).setVueltoDe(monto);
              }
            },
          ),
        ],
        
        if (checkoutState.metodoPago == 'pago_movil') ...[
          const SizedBox(height: 16),
          _buildPagoMovilForm(context, ref),
        ],
      ],
    );
  }

  Widget _buildMetodoOption(
    BuildContext context,
    WidgetRef ref,
    String value,
    String label,
    IconData icon,
    bool isSelected,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        ref.read(checkoutProvider.notifier).setMetodoPago(value);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? theme.colorScheme.primary : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? theme.colorScheme.primary : null,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagoMovilForm(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Banco',
            prefixIcon: Icon(Icons.account_balance),
          ),
          onChanged: (value) {
            // Actualizar datos
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Teléfono',
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Referencia',
            prefixIcon: Icon(Icons.confirmation_number),
          ),
        ),
      ],
    );
  }
}
```

## Definición de Hecho (DoD)

- [ ] Selección de dirección funcional
- [ ] Métodos de pago implementados
- [ ] Validaciones completas
- [ ] Cálculo de totales correcto
- [ ] Creación de pedido exitosa
- [ ] Limpieza de carrito post-pedido
- [ ] Navegación a tracking
- [ ] Tests pasando

## Comandos de Verificación

```bash
flutter test
flutter run -d chrome
```

## Dependencias

- Issue #16: Carrito de Compras

## Siguiente Issue

Issue #18: Tracking en Tiempo Real
