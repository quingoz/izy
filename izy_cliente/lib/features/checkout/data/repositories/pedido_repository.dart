import '../../../../core/network/api_service.dart';

class PedidoRepository {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> crearPedido(Map<String, dynamic> pedidoData) async {
    final response = await _api.post('/pedidos', data: pedidoData);
    return response['data'];
  }

  Future<Map<String, dynamic>> getPedido(int id) async {
    final response = await _api.get('/pedidos/$id');
    return response['data'];
  }

  Future<List<Map<String, dynamic>>> getMisPedidos() async {
    final response = await _api.get('/pedidos/mis-pedidos');
    return List<Map<String, dynamic>>.from(response['data']);
  }
}
