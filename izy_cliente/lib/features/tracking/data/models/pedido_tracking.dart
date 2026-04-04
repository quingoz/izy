class PedidoTracking {
  final int id;
  final String numeroPedido;
  final String estado;
  final ComercioInfo comercio;
  final ClienteInfo cliente;
  final RepartidorInfo? repartidor;
  final List<EstadoHistorial> historialEstados;
  final double totalUsd;
  final DateTime createdAt;

  PedidoTracking({
    required this.id,
    required this.numeroPedido,
    required this.estado,
    required this.comercio,
    required this.cliente,
    this.repartidor,
    required this.historialEstados,
    required this.totalUsd,
    required this.createdAt,
  });

  factory PedidoTracking.fromJson(Map<String, dynamic> json) {
    return PedidoTracking(
      id: json['id'],
      numeroPedido: json['numero_pedido'],
      estado: json['estado'],
      comercio: ComercioInfo.fromJson(json['comercio']),
      cliente: ClienteInfo.fromJson(json['cliente']),
      repartidor: json['repartidor'] != null 
          ? RepartidorInfo.fromJson(json['repartidor']) 
          : null,
      historialEstados: (json['historial_estados'] as List)
          .map((e) => EstadoHistorial.fromJson(e))
          .toList(),
      totalUsd: (json['total_usd'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  PedidoTracking copyWith({
    String? estado,
    RepartidorInfo? repartidor,
    List<EstadoHistorial>? historialEstados,
  }) {
    return PedidoTracking(
      id: id,
      numeroPedido: numeroPedido,
      estado: estado ?? this.estado,
      comercio: comercio,
      cliente: cliente,
      repartidor: repartidor ?? this.repartidor,
      historialEstados: historialEstados ?? this.historialEstados,
      totalUsd: totalUsd,
      createdAt: createdAt,
    );
  }
}

class ComercioInfo {
  final int id;
  final String nombre;
  final double lat;
  final double lng;

  ComercioInfo({
    required this.id,
    required this.nombre,
    required this.lat,
    required this.lng,
  });

  factory ComercioInfo.fromJson(Map<String, dynamic> json) {
    return ComercioInfo(
      id: json['id'],
      nombre: json['nombre'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}

class ClienteInfo {
  final int id;
  final String nombre;
  final double lat;
  final double lng;

  ClienteInfo({
    required this.id,
    required this.nombre,
    required this.lat,
    required this.lng,
  });

  factory ClienteInfo.fromJson(Map<String, dynamic> json) {
    return ClienteInfo(
      id: json['id'],
      nombre: json['nombre'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}

class RepartidorInfo {
  final int id;
  final String nombre;
  final String? telefono;

  RepartidorInfo({
    required this.id,
    required this.nombre,
    this.telefono,
  });

  factory RepartidorInfo.fromJson(Map<String, dynamic> json) {
    return RepartidorInfo(
      id: json['id'],
      nombre: json['nombre'],
      telefono: json['telefono'],
    );
  }
}

class EstadoHistorial {
  final String estado;
  final DateTime fecha;

  EstadoHistorial({
    required this.estado,
    required this.fecha,
  });

  factory EstadoHistorial.fromJson(Map<String, dynamic> json) {
    return EstadoHistorial(
      estado: json['estado'],
      fecha: DateTime.parse(json['fecha']),
    );
  }
}

class UbicacionRepartidor {
  final double lat;
  final double lng;
  final DateTime timestamp;

  UbicacionRepartidor({
    required this.lat,
    required this.lng,
    required this.timestamp,
  });
}
