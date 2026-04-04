import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/checkout_provider.dart';
import '../widgets/direccion_selector.dart';
import '../widgets/metodo_pago_selector.dart';
import '../widgets/resumen_pedido.dart';
import '../../../../core/constants/app_constants.dart';

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
              padding: const EdgeInsets.all(IzySpacing.md),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dirección de Entrega',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: IzySpacing.md),
                    const DireccionSelector(),
                    
                    const SizedBox(height: IzySpacing.xl),
                    
                    Text(
                      'Método de Pago',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: IzySpacing.md),
                    const MetodoPagoSelector(),
                    
                    const SizedBox(height: IzySpacing.xl),
                    
                    Text(
                      'Notas para el comercio',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: IzySpacing.sm),
                    TextFormField(
                      controller: _notasController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Ej: Sin cebolla, extra picante...',
                      ),
                    ),
                    
                    const SizedBox(height: IzySpacing.xl),
                    
                    const ResumenPedido(),
                    
                    const SizedBox(height: IzySpacing.xl),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: checkoutState.canConfirm
                            ? () => _confirmarPedido()
                            : null,
                        child: const Padding(
                          padding: EdgeInsets.all(IzySpacing.md),
                          child: Text('Confirmar Pedido'),
                        ),
                      ),
                    ),
                    
                    if (checkoutState.error != null) ...[
                      const SizedBox(height: IzySpacing.md),
                      Container(
                        padding: const EdgeInsets.all(IzySpacing.md),
                        decoration: BoxDecoration(
                          color: IzyColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(IzyRadius.md),
                          border: Border.all(color: IzyColors.error),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: IzyColors.error),
                            const SizedBox(width: IzySpacing.sm),
                            Expanded(
                              child: Text(
                                checkoutState.error!,
                                style: const TextStyle(color: IzyColors.error),
                              ),
                            ),
                          ],
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Pedido creado exitosamente!'),
          backgroundColor: IzyColors.success,
        ),
      );
      
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _notasController.dispose();
    super.dispose();
  }
}
