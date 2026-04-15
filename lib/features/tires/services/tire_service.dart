import '../../../core/api/api_client.dart';
import '../models/tire_model.dart';

class TireService {
  static Future<TireInfo> getTires(int vehicleId) async {
    final res = await ApiClient.getAuth('/gomas', query: {'vehiculo_id': vehicleId});
    final data = res.data;
    if (data['success'] == true) return TireInfo.fromJson(data['data']);
    throw Exception(data['message'] ?? 'Error al cargar gomas');
  }

  static Future<Tire> updateStatus(int gomaId, String estado) async {
    final res = await ApiClient.postAuth('/gomas/actualizar', {'goma_id': gomaId, 'estado': estado});
    final data = res.data;
    if (data['success'] == true) return Tire.fromJson(data['data']);
    throw Exception(data['message'] ?? 'Error al actualizar goma');
  }

  static Future<void> logPuncture(int gomaId, String descripcion, String fecha) async {
    final res = await ApiClient.postAuth('/gomas/pinchazos', {
      'goma_id': gomaId,
      'descripcion': descripcion,
      'fecha': fecha,
    });
    final data = res.data;
    if (data['success'] != true) throw Exception(data['message'] ?? 'Error al registrar pinchazo');
  }
}
