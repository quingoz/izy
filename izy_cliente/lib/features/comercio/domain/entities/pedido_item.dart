class PedidoItem {
  final String id;
  final String productoId;
  final String nombreProducto;
  final int cantidad;
  final double precioUnitarioUsd;
  final double subtotalUsd;
  final String? notas;

  PedidoItem({
    required this.id,
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitarioUsd,
    required this.subtotalUsd,
    this.notas,
  });

  factory PedidoItem.fromJson(Map<String, dynamic> json) {
    return PedidoItem(
      id: json['id'] ?? '',
      productoId: json['producto_id'] ?? '',
      nombreProducto: json['nombre_producto'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      precioUnitarioUsd: (json['precio_unitario_usd'] ?? 0).toDouble(),
      subtotalUsd: (json['subtotal_usd'] ?? 0).toDouble(),
      notas: json['notas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producto_id': productoId,
      'nombre_producto': nombreProducto,
      'cantidad': cantidad,
      'precio_unitario_usd': precioUnitarioUsd,
      'subtotal_usd': subtotalUsd,
      'notas': notas,
    };
  }
}
