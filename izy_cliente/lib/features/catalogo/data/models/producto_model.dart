class Producto {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? imagenUrl;
  final double precioUsd;
  final double precioBs;
  final double? precioOfertaUsd;
  final double? precioOfertaBs;
  final int stock;
  final bool stockIlimitado;
  final bool tieneVariantes;
  final List<Variante>? variantes;
  final bool isActive;
  final bool isDestacado;
  final Categoria? categoria;

  Producto({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.imagenUrl,
    required this.precioUsd,
    required this.precioBs,
    this.precioOfertaUsd,
    this.precioOfertaBs,
    required this.stock,
    required this.stockIlimitado,
    required this.tieneVariantes,
    this.variantes,
    required this.isActive,
    required this.isDestacado,
    this.categoria,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      imagenUrl: json['imagen_url'],
      precioUsd: (json['precio_usd'] as num).toDouble(),
      precioBs: (json['precio_bs'] as num).toDouble(),
      precioOfertaUsd: json['precio_oferta_usd'] != null 
          ? (json['precio_oferta_usd'] as num).toDouble() 
          : null,
      precioOfertaBs: json['precio_oferta_bs'] != null 
          ? (json['precio_oferta_bs'] as num).toDouble() 
          : null,
      stock: json['stock'],
      stockIlimitado: json['stock_ilimitado'],
      tieneVariantes: json['tiene_variantes'],
      variantes: json['variantes'] != null
          ? (json['variantes'] as List).map((v) => Variante.fromJson(v)).toList()
          : null,
      isActive: json['is_active'],
      isDestacado: json['is_destacado'],
      categoria: json['categoria'] != null 
          ? Categoria.fromJson(json['categoria']) 
          : null,
    );
  }

  bool get tieneOferta => precioOfertaUsd != null;
  bool get hayStock => stockIlimitado || stock > 0;
  
  double getPrecioFinal(String moneda) {
    if (moneda == 'usd') {
      return precioOfertaUsd ?? precioUsd;
    }
    return precioOfertaBs ?? precioBs;
  }
}

class Variante {
  final String name;
  final List<String> options;
  final double? priceUsd;
  final double? priceBs;

  Variante({
    required this.name,
    required this.options,
    this.priceUsd,
    this.priceBs,
  });

  factory Variante.fromJson(Map<String, dynamic> json) {
    return Variante(
      name: json['name'],
      options: List<String>.from(json['options']),
      priceUsd: json['price_usd']?.toDouble(),
      priceBs: json['price_bs']?.toDouble(),
    );
  }
}

class Categoria {
  final int id;
  final String nombre;
  final String? icono;

  Categoria({
    required this.id,
    required this.nombre,
    this.icono,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'],
      nombre: json['nombre'],
      icono: json['icono'],
    );
  }
}
