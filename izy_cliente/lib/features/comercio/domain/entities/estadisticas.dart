class Estadisticas {
  final double ventasHoy;
  final int pedidosHoy;
  final int pedidosPendientes;
  final double promedioTicket;
  final double ventasSemana;
  final int totalProductos;

  Estadisticas({
    required this.ventasHoy,
    required this.pedidosHoy,
    required this.pedidosPendientes,
    required this.promedioTicket,
    required this.ventasSemana,
    required this.totalProductos,
  });

  factory Estadisticas.empty() {
    return Estadisticas(
      ventasHoy: 0,
      pedidosHoy: 0,
      pedidosPendientes: 0,
      promedioTicket: 0,
      ventasSemana: 0,
      totalProductos: 0,
    );
  }

  factory Estadisticas.fromJson(Map<String, dynamic> json) {
    return Estadisticas(
      ventasHoy: (json['ventas_hoy'] ?? 0).toDouble(),
      pedidosHoy: json['pedidos_hoy'] ?? 0,
      pedidosPendientes: json['pedidos_pendientes'] ?? 0,
      promedioTicket: (json['promedio_ticket'] ?? 0).toDouble(),
      ventasSemana: (json['ventas_semana'] ?? 0).toDouble(),
      totalProductos: json['total_productos'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ventas_hoy': ventasHoy,
      'pedidos_hoy': pedidosHoy,
      'pedidos_pendientes': pedidosPendientes,
      'promedio_ticket': promedioTicket,
      'ventas_semana': ventasSemana,
      'total_productos': totalProductos,
    };
  }
}
