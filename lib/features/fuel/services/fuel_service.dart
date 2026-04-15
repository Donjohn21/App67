import '../../../core/api/api_client.dart';
import '../models/fuel_model.dart';

class FuelService {
  static Future<List<FuelRecord>> getList(int vehicleId, {String? tipo}) async {
    final query = <String, dynamic>{'vehiculo_id': vehicleId};
    if (tipo != null && tipo.isNotEmpty) query['tipo'] = tipo;
    final res = await ApiClient.getAuth('/combustibles', query: query);
    final data = res.data;
    if (data['success'] == true) {
      return (data['data'] as List).map((e) => FuelRecord.fromJson(e)).toList();
    }
    throw Exception(data['message'] ?? 'Error al cargar registros');
  }

  static Future<FuelRecord> create({
    required int vehiculoId,
    required String tipo,
    required double cantidad,
    required String unidad,
    required double monto,
  }) async {
    final res = await ApiClient.postAuth('/combustibles', {
      'vehiculo_id': vehiculoId,
      'tipo': tipo,
      'cantidad': cantidad,
      'unidad': unidad,
      'monto': monto,
    });
    final data = res.data;
    if (data['success'] == true) return FuelRecord.fromJson(data['data']);
    throw Exception(data['message'] ?? 'Error al registrar');
  }
}
