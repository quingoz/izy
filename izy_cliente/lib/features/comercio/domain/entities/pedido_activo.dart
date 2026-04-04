class PedidoActivo {
  final String id;
  final String numeroOrden;
  final String cliente;
  final String estado;
  final double total;
  final DateTime fechaCreacion;
  final int cantidadItems;
  final String? direccion;

  PedidoActivo({
    required this.id,
    required this.numeroOrden,
    required this.cliente,
    required this.estado,
    required this.total,
    required this.fechaCreacion,
    required this.cantidadItems,
    this.direccion,
  });

  factory PedidoActivo.fromJson(Map<String, dynamic> json) {
    return PedidoActivo(
      id: json['id'] ?? '',
      numeroOrden: json['numero_orden'] ?? '',
      cliente: json['cliente'] ?? 'Cliente',
      estado: json['estado'] ?? 'pendiente',
      total: (json['total'] ?? 0).toDouble(),
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'])
          : DateTime.now(),
      cantidadItems: json['cantidad_items'] ?? 0,
      direccion: json['direccion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero_orden': numeroOrden,
      'cliente': cliente,
      'estado': estado,
      'total': total,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'cantidad_items': cantidadItems,
      'direccion': direccion,
    };
  }

  String get estadoLabel {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'Pendiente';
      case 'preparando':
        return 'En Preparación';
      case 'listo':
        return 'Listo';
      case 'en_camino':
        return 'En Camino';
      case 'entregado':
        return 'Entregado';
      default:
        return estado;
    }
  }
}
