class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final double precioUsd;
  final String? imagenUrl;
  final String categoria;
  final int stock;
  final bool activo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precioUsd,
    this.imagenUrl,
    required this.categoria,
    required this.stock,
    this.activo = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precioUsd: (json['precio_usd'] ?? 0).toDouble(),
      imagenUrl: json['imagen_url'],
      categoria: json['categoria'] ?? 'general',
      stock: json['stock'] ?? 0,
      activo: json['activo'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio_usd': precioUsd,
      'imagen_url': imagenUrl,
      'categoria': categoria,
      'stock': stock,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Producto copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    double? precioUsd,
    String? imagenUrl,
    String? categoria,
    int? stock,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precioUsd: precioUsd ?? this.precioUsd,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      categoria: categoria ?? this.categoria,
      stock: stock ?? this.stock,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get disponible => activo && stock > 0;

  String get estadoStock {
    if (stock == 0) return 'Agotado';
    if (stock < 5) return 'Bajo Stock';
    return 'Disponible';
  }
}
