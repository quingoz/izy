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
