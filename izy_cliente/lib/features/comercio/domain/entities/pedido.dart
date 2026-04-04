import 'pedido_item.dart';

class Pedido {
  final String id;
  final String numeroPedido;
  final String clienteId;
  final String clienteNombre;
  final String estado;
  final List<PedidoItem> items;
  final double totalUsd;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notasCliente;
  final String? direccionEntrega;

  Pedido({
    required this.id,
    required this.numeroPedido,
    required this.clienteId,
    required this.clienteNombre,
    required this.estado,
    required this.items,
    required this.totalUsd,
    required this.createdAt,
    this.updatedAt,
    this.notasCliente,
    this.direccionEntrega,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'] ?? '',
      numeroPedido: json['numero_pedido'] ?? '',
      clienteId: json['cliente_id'] ?? '',
      clienteNombre: json['cliente_nombre'] ?? 'Cliente',
      estado: json['estado'] ?? 'pendiente',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => PedidoItem.fromJson(item))
              .toList() ??
          [],
      totalUsd: (json['total_usd'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      notasCliente: json['notas_cliente'],
      direccionEntrega: json['direccion_entrega'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero_pedido': numeroPedido,
      'cliente_id': clienteId,
      'cliente_nombre': clienteNombre,
      'estado': estado,
      'items': items.map((item) => item.toJson()).toList(),
      'total_usd': totalUsd,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'notas_cliente': notasCliente,
      'direccion_entrega': direccionEntrega,
    };
  }

  Pedido copyWith({
    String? id,
    String? numeroPedido,
    String? clienteId,
    String? clienteNombre,
    String? estado,
    List<PedidoItem>? items,
    double? totalUsd,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notasCliente,
    String? direccionEntrega,
  }) {
    return Pedido(
      id: id ?? this.id,
      numeroPedido: numeroPedido ?? this.numeroPedido,
      clienteId: clienteId ?? this.clienteId,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      estado: estado ?? this.estado,
      items: items ?? this.items,
      totalUsd: totalUsd ?? this.totalUsd,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notasCliente: notasCliente ?? this.notasCliente,
      direccionEntrega: direccionEntrega ?? this.direccionEntrega,
    );
  }

  String get estadoLabel {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'Pendiente';
      case 'confirmado':
        return 'Confirmado';
      case 'preparando':
        return 'En Preparación';
      case 'listo':
        return 'Listo';
      case 'en_camino':
        return 'En Camino';
      case 'entregado':
        return 'Entregado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return estado;
    }
  }
}
