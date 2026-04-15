import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_client.dart';
import '../models/maintenance_model.dart';

class MaintenanceService {
  static Future<List<MaintenanceRecord>> getList(int vehicleId, {String? tipo}) async {
    final query = <String, dynamic>{'vehiculo_id': vehicleId};
    if (tipo != null && tipo.isNotEmpty) query['tipo'] = tipo;
    final res = await ApiClient.getAuth('/mantenimientos', query: query);
    final data = res.data;
    if (data['success'] == true) {
      return (data['data'] as List).map((e) => MaintenanceRecord.fromJson(e)).toList();
    }
    throw Exception(data['message'] ?? 'Error al cargar mantenimientos');
  }

  static Future<MaintenanceRecord> getDetail(int id) async {
    final res = await ApiClient.getAuth('/mantenimientos/detalle', query: {'id': id});
    final data = res.data;
    if (data['success'] == true) return MaintenanceRecord.fromJson(data['data']);
    throw Exception(data['message'] ?? 'Error al cargar mantenimiento');
  }

  static Future<MaintenanceRecord> create({
    required int vehiculoId,
    required String tipo,
    required double costo,
    required String fecha,
    String? piezas,
    List<XFile> fotos = const [],
  }) async {
    final body = {
      'vehiculo_id': vehiculoId,
      'tipo': tipo,
      'costo': costo,
      'fecha': fecha,
      if (piezas != null && piezas.isNotEmpty) 'piezas': piezas,
    };

    final files = <MultipartFile>[];
    for (final f in fotos) {
      files.add(await MultipartFile.fromFile(f.path, filename: f.name));
    }

    final res = await ApiClient.postAuthMultipartFiles(
        '/mantenimientos', body, files, 'fotos[]');
    final data = res.data;
    if (data['success'] == true) return MaintenanceRecord.fromJson(data['data']);
    throw Exception(data['message'] ?? 'Error al registrar mantenimiento');
  }
}
