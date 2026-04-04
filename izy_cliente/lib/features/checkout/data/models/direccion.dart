class Direccion {
  final int? id;
  final String calle;
  final String? ciudad;
  final String? estado;
  final String? referencia;
  final double lat;
  final double lng;
  final String? alias;

  Direccion({
    this.id,
    required this.calle,
    this.ciudad,
    this.estado,
    this.referencia,
    required this.lat,
    required this.lng,
    this.alias,
  });

  factory Direccion.fromJson(Map<String, dynamic> json) {
    return Direccion(
      id: json['id'],
      calle: json['calle'],
      ciudad: json['ciudad'],
      estado: json['estado'],
      referencia: json['referencia'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      alias: json['alias'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'calle': calle,
      'ciudad': ciudad,
      'estado': estado,
      'referencia': referencia,
      'lat': lat,
      'lng': lng,
      'alias': alias,
    };
  }

  String get direccionCompleta {
    final partes = [
      calle,
      if (ciudad != null) ciudad,
      if (estado != null) estado,
    ];
    return partes.join(', ');
  }
}
