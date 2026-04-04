import '../../../../core/network/api_service.dart';
import '../models/producto_model.dart';

class ProductosRepository {
  final ApiService _api = ApiService();

  Future<List<Producto>> getProductos(
    String slug, {
    int? categoriaId,
    String? search,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (search != null) 'search': search,
    };

    final response = await _api.get(
      '/comercios/$slug/productos',
      queryParameters: queryParams,
    );

    return (response['data'] as List)
        .map((json) => Producto.fromJson(json))
        .toList();
  }

  Future<Producto> getProducto(int id) async {
    final response = await _api.get('/productos/$id');
    return Producto.fromJson(response['data']);
  }

  Future<List<Categoria>> getCategorias(String slug) async {
    final response = await _api.get('/comercios/$slug/categorias');
    return (response['data'] as List)
        .map((json) => Categoria.fromJson(json))
        .toList();
  }
}
