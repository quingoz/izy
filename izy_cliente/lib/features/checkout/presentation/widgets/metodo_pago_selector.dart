import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/checkout_provider.dart';
import '../../../../core/constants/app_constants.dart';

class MetodoPagoSelector extends ConsumerStatefulWidget {
  const MetodoPagoSelector({super.key});

  @override
  ConsumerState<MetodoPagoSelector> createState() => _MetodoPagoSelectorState();
}

class _MetodoPagoSelectorState extends ConsumerState<MetodoPagoSelector> {
  final _bancoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _referenciaController = TextEditingController();

  @override
  void dispose() {
    _bancoController.dispose();
    _telefonoController.dispose();
    _referenciaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutProvider);

    return Column(
      children: [
        _buildMetodoOption(
          'efectivo',
          'Efectivo',
          Icons.money,
          checkoutState.metodoPago == 'efectivo',
        ),
        const SizedBox(height: IzySpacing.sm),
        _buildMetodoOption(
          'pago_movil',
          'Pago Móvil',
          Icons.phone_android,
          checkoutState.metodoPago == 'pago_movil',
        ),
        const SizedBox(height: IzySpacing.sm),
        _buildMetodoOption(
          'transferencia',
          'Transferencia',
          Icons.account_balance,
          checkoutState.metodoPago == 'transferencia',
        ),
        
        if (checkoutState.metodoPago == 'efectivo') ...[
          const SizedBox(height: IzySpacing.md),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Vuelto de (Bs)',
              prefixIcon: Icon(Icons.attach_money),
              hintText: 'Ej: 100',
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
          const SizedBox(height: IzySpacing.md),
          _buildPagoMovilForm(),
        ],
      ],
    );
  }

  Widget _buildMetodoOption(
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
      borderRadius: BorderRadius.circular(IzyRadius.md),
      child: Container(
        padding: const EdgeInsets.all(IzySpacing.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : IzyColors.greyMedium,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(IzyRadius.md),
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? theme.colorScheme.primary : IzyColors.greyDark,
            ),
            const SizedBox(width: IzySpacing.md),
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

  Widget _buildPagoMovilForm() {
    return Column(
      children: [
        TextFormField(
          controller: _bancoController,
          decoration: const InputDecoration(
            labelText: 'Banco',
            prefixIcon: Icon(Icons.account_balance),
            hintText: 'Ej: Banesco',
          ),
          onChanged: _updatePagoMovilData,
        ),
        const SizedBox(height: IzySpacing.md),
        TextFormField(
          controller: _telefonoController,
          decoration: const InputDecoration(
            labelText: 'Teléfono',
            prefixIcon: Icon(Icons.phone),
            hintText: 'Ej: 04241234567',
          ),
          keyboardType: TextInputType.phone,
          onChanged: _updatePagoMovilData,
        ),
        const SizedBox(height: IzySpacing.md),
        TextFormField(
          controller: _referenciaController,
          decoration: const InputDecoration(
            labelText: 'Referencia',
            prefixIcon: Icon(Icons.confirmation_number),
            hintText: 'Número de referencia',
          ),
          onChanged: _updatePagoMovilData,
        ),
      ],
    );
  }

  void _updatePagoMovilData(String _) {
    ref.read(checkoutProvider.notifier).setPagoMovilData({
      'banco': _bancoController.text,
      'telefono': _telefonoController.text,
      'referencia': _referenciaController.text,
    });
  }
}
