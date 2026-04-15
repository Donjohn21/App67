import '../../../core/api/api_client.dart';
import '../models/catalog_model.dart';

class CatalogService {
  static Future<List<CatalogItem>> getCatalog({
    String? marca,
    String? modelo,
    int? anio,
    double? precioMin,
    double? precioMax,
    int page = 1,
  }) async {
    final query = <String, dynamic>{'page': page};
    if (marca != null && marca.isNotEmpty) query['marca'] = marca;
    if (modelo != null && modelo.isNotEmpty) query['modelo'] = modelo;
    if (anio != null) query['anio'] = anio;
    if (precioMin != null) query['precioMin'] = precioMin;
    if (precioMax != null) query['precioMax'] = precioMax;

    final res = await ApiClient.getAuth('/catalogo', query: query);
    final data = res.data;
    if (data['success'] == true) {
      return (data['data'] as List)
          .map((e) => CatalogItem.fromJson(e))
          .toList();
    }
    throw Exception(data['message'] ?? 'Error al cargar catálogo');
  }

  static Future<CatalogItem> getDetail(int id) async {
    final res = await ApiClient.getAuth('/catalogo/detalle', query: {'id': id});
    final data = res.data;
    if (data['success'] == true) {
      return CatalogItem.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? 'Error al cargar vehículo');
  }
}
