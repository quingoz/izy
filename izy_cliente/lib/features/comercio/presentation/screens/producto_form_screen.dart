import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/producto.dart';
import '../providers/productos_provider.dart';
import '../../../../core/constants/app_constants.dart';

class ProductoFormScreen extends ConsumerStatefulWidget {
  final Producto? producto;

  const ProductoFormScreen({
    super.key,
    this.producto,
  });

  @override
  ConsumerState<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends ConsumerState<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _precioController;
  late TextEditingController _stockController;
  late TextEditingController _imagenUrlController;
  String _categoriaSeleccionada = 'Comida';
  bool _activo = true;

  final List<String> _categorias = [
    'Comida',
    'Bebidas',
    'Postres',
    'Especiales',
  ];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.producto?.nombre ?? '');
    _descripcionController = TextEditingController(text: widget.producto?.descripcion ?? '');
    _precioController = TextEditingController(
      text: widget.producto?.precioUsd.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.producto?.stock.toString() ?? '0',
    );
    _imagenUrlController = TextEditingController(text: widget.producto?.imagenUrl ?? '');
    _categoriaSeleccionada = widget.producto?.categoria ?? 'Comida';
    _activo = widget.producto?.activo ?? true;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _imagenUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.producto != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Producto' : 'Nuevo Producto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Producto',
                hintText: 'Ej: Hamburguesa Clásica',
                prefixIcon: Icon(Icons.fastfood),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Describe tu producto',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La descripción es requerida';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _precioController,
                    decoration: const InputDecoration(
                      labelText: 'Precio (USD)',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El precio es requerido';
                      }
                      final precio = double.tryParse(value);
                      if (precio == null || precio <= 0) {
                        return 'Precio inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stock',
                      hintText: '0',
                      prefixIcon: Icon(Icons.inventory),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El stock es requerido';
                      }
                      final stock = int.tryParse(value);
                      if (stock == null || stock < 0) {
                        return 'Stock inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _categoriaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                prefixIcon: Icon(Icons.category),
              ),
              items: _categorias.map((categoria) {
                return DropdownMenuItem(
                  value: categoria,
                  child: Text(categoria),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _categoriaSeleccionada = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imagenUrlController,
              decoration: const InputDecoration(
                labelText: 'URL de Imagen (Opcional)',
                hintText: 'https://ejemplo.com/imagen.jpg',
                prefixIcon: Icon(Icons.image),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Producto Activo'),
              subtitle: Text(
                _activo ? 'Visible para clientes' : 'Oculto para clientes',
                style: TextStyle(fontSize: 12),
              ),
              value: _activo,
              onChanged: (value) {
                setState(() {
                  _activo = value;
                });
              },
              secondary: Icon(
                _activo ? Icons.visibility : Icons.visibility_off,
                color: _activo ? IzyColors.success : IzyColors.greyDark,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _guardarProducto,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                isEditing ? 'Actualizar Producto' : 'Crear Producto',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (isEditing) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _eliminarProducto,
                style: OutlinedButton.styleFrom(
                  foregroundColor: IzyColors.error,
                  side: const BorderSide(color: IzyColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Eliminar Producto',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final producto = Producto(
      id: widget.producto?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      precioUsd: double.parse(_precioController.text),
      imagenUrl: _imagenUrlController.text.trim().isEmpty
          ? null
          : _imagenUrlController.text.trim(),
      categoria: _categoriaSeleccionada,
      stock: int.parse(_stockController.text),
      activo: _activo,
      createdAt: widget.producto?.createdAt ?? DateTime.now(),
      updatedAt: widget.producto != null ? DateTime.now() : null,
    );

    if (widget.producto != null) {
      await ref.read(productosProvider.notifier).actualizarProducto(producto);
    } else {
      await ref.read(productosProvider.notifier).crearProducto(producto);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.producto != null
                ? 'Producto actualizado'
                : 'Producto creado',
          ),
          backgroundColor: IzyColors.success,
        ),
      );
    }
  }

  Future<void> _eliminarProducto() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: const Text('¿Estás seguro de eliminar este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: IzyColors.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.producto != null) {
      await ref.read(productosProvider.notifier).eliminarProducto(widget.producto!.id);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto eliminado'),
            backgroundColor: IzyColors.error,
          ),
        );
      }
    }
  }
}
