import '../../../../core/network/api_service.dart';
import '../models/pedido_tracking.dart';

class TrackingRepository {
  final ApiService _api = ApiService();

  Future<PedidoTracking> getTracking(int pedidoId) async {
    final response = await _api.get('/pedidos/$pedidoId/tracking');
    return PedidoTracking.fromJson(response['data']);
  }

  Future<PedidoTracking> getTrackingByToken(String token) async {
    final response = await _api.get('/tracking/$token');
    return PedidoTracking.fromJson(response['data']);
  }
}
