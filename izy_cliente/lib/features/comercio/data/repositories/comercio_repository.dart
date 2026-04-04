import '../../domain/entities/estadisticas.dart';
import '../../domain/entities/pedido_activo.dart';

class ComercioRepository {
  Future<Estadisticas> getEstadisticas() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return Estadisticas(
      ventasHoy: 1250.50,
      pedidosHoy: 15,
      pedidosPendientes: 3,
      promedioTicket: 83.37,
      ventasSemana: 8750.00,
      totalProductos: 45,
    );
  }

  Future<List<PedidoActivo>> getPedidosActivos() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      PedidoActivo(
        id: '1',
        numeroOrden: '#ORD-001',
        cliente: 'Juan Pérez',
        estado: 'pendiente',
        total: 45.50,
        fechaCreacion: DateTime.now().subtract(const Duration(minutes: 5)),
        cantidadItems: 3,
        direccion: 'Av. Principal #123',
      ),
      PedidoActivo(
        id: '2',
        numeroOrden: '#ORD-002',
        cliente: 'María González',
        estado: 'preparando',
        total: 78.00,
        fechaCreacion: DateTime.now().subtract(const Duration(minutes: 15)),
        cantidadItems: 5,
        direccion: 'Calle Secundaria #456',
      ),
      PedidoActivo(
        id: '3',
        numeroOrden: '#ORD-003',
        cliente: 'Carlos Rodríguez',
        estado: 'listo',
        total: 120.75,
        fechaCreacion: DateTime.now().subtract(const Duration(minutes: 25)),
        cantidadItems: 8,
        direccion: 'Urbanización Los Pinos #789',
      ),
    ];
  }
}
