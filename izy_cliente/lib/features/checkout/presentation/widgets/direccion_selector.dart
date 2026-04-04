import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/checkout_provider.dart';
import '../../data/models/direccion.dart';
import '../../../../core/constants/app_constants.dart';

class DireccionSelector extends ConsumerStatefulWidget {
  const DireccionSelector({super.key});

  @override
  ConsumerState<DireccionSelector> createState() => _DireccionSelectorState();
}

class _DireccionSelectorState extends ConsumerState<DireccionSelector> {
  final _calleController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _referenciaController = TextEditingController();

  @override
  void dispose() {
    _calleController.dispose();
    _ciudadController.dispose();
    _referenciaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(IzySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (checkoutState.direccion != null) ...[
              _buildDireccionActual(checkoutState.direccion!),
              const SizedBox(height: IzySpacing.md),
              TextButton.icon(
                onPressed: _mostrarFormularioDireccion,
                icon: const Icon(Icons.edit),
                label: const Text('Cambiar dirección'),
              ),
            ] else ...[
              _buildFormularioDireccion(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDireccionActual(Direccion direccion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, color: IzyColors.primary),
            const SizedBox(width: IzySpacing.sm),
            Expanded(
              child: Text(
                direccion.alias ?? 'Mi dirección',
                style: IzyTextStyles.h4,
              ),
            ),
          ],
        ),
        const SizedBox(height: IzySpacing.sm),
        Text(
          direccion.direccionCompleta,
          style: IzyTextStyles.body,
        ),
        if (direccion.referencia != null) ...[
          const SizedBox(height: IzySpacing.xs),
          Text(
            'Ref: ${direccion.referencia}',
            style: IzyTextStyles.caption.copyWith(
              color: IzyColors.greyMedium,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFormularioDireccion() {
    return Column(
      children: [
        TextFormField(
          controller: _calleController,
          decoration: const InputDecoration(
            labelText: 'Calle / Dirección *',
            prefixIcon: Icon(Icons.home),
            hintText: 'Ej: Av. Principal, Edif. Torre, Piso 5',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La dirección es requerida';
            }
            return null;
          },
        ),
        const SizedBox(height: IzySpacing.md),
        TextFormField(
          controller: _ciudadController,
          decoration: const InputDecoration(
            labelText: 'Ciudad',
            prefixIcon: Icon(Icons.location_city),
            hintText: 'Ej: Caracas',
          ),
        ),
        const SizedBox(height: IzySpacing.md),
        TextFormField(
          controller: _referenciaController,
          decoration: const InputDecoration(
            labelText: 'Referencia',
            prefixIcon: Icon(Icons.info_outline),
            hintText: 'Ej: Casa azul, al lado del supermercado',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: IzySpacing.md),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _guardarDireccion,
            icon: const Icon(Icons.check),
            label: const Text('Usar esta dirección'),
          ),
        ),
      ],
    );
  }

  void _mostrarFormularioDireccion() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: IzySpacing.md,
          right: IzySpacing.md,
          top: IzySpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nueva Dirección', style: IzyTextStyles.h3),
            const SizedBox(height: IzySpacing.md),
            _buildFormularioDireccion(),
            const SizedBox(height: IzySpacing.md),
          ],
        ),
      ),
    );
  }

  void _guardarDireccion() {
    if (_calleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La dirección es requerida')),
      );
      return;
    }

    final direccion = Direccion(
      calle: _calleController.text,
      ciudad: _ciudadController.text.isEmpty ? null : _ciudadController.text,
      referencia: _referenciaController.text.isEmpty ? null : _referenciaController.text,
      lat: 10.4806,
      lng: -66.9036,
      alias: 'Mi dirección',
    );

    ref.read(checkoutProvider.notifier).setDireccion(direccion);

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
