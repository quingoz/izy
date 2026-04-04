class Repartidor {
  final String id;
  final String nombre;
  final String telefono;
  final String? fotoUrl;
  final bool disponible;
  final bool esExclusivo;
  final double? latitud;
  final double? longitud;
  final int pedidosCompletados;
  final double calificacion;
  final String? vehiculo;
  final DateTime createdAt;

  Repartidor({
    required this.id,
    required this.nombre,
    required this.telefono,
    this.fotoUrl,
    this.disponible = true,
    this.esExclusivo = false,
    this.latitud,
    this.longitud,
    this.pedidosCompletados = 0,
    this.calificacion = 5.0,
    this.vehiculo,
    required this.createdAt,
  });

  factory Repartidor.fromJson(Map<String, dynamic> json) {
    return Repartidor(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      telefono: json['telefono'] ?? '',
      fotoUrl: json['foto_url'],
      disponible: json['disponible'] ?? true,
      esExclusivo: json['es_exclusivo'] ?? false,
      latitud: json['latitud']?.toDouble(),
      longitud: json['longitud']?.toDouble(),
      pedidosCompletados: json['pedidos_completados'] ?? 0,
      calificacion: (json['calificacion'] ?? 5.0).toDouble(),
      vehiculo: json['vehiculo'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'foto_url': fotoUrl,
      'disponible': disponible,
      'es_exclusivo': esExclusivo,
      'latitud': latitud,
      'longitud': longitud,
      'pedidos_completados': pedidosCompletados,
      'calificacion': calificacion,
      'vehiculo': vehiculo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Repartidor copyWith({
    String? id,
    String? nombre,
    String? telefono,
    String? fotoUrl,
    bool? disponible,
    bool? esExclusivo,
    double? latitud,
    double? longitud,
    int? pedidosCompletados,
    double? calificacion,
    String? vehiculo,
    DateTime? createdAt,
  }) {
    return Repartidor(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      disponible: disponible ?? this.disponible,
      esExclusivo: esExclusivo ?? this.esExclusivo,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      pedidosCompletados: pedidosCompletados ?? this.pedidosCompletados,
      calificacion: calificacion ?? this.calificacion,
      vehiculo: vehiculo ?? this.vehiculo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get estadoLabel => disponible ? 'Disponible' : 'Ocupado';

  String get tipoLabel => esExclusivo ? 'Exclusivo' : 'Freelance';
}
