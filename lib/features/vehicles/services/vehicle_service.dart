import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_client.dart';
import '../models/vehicle_model.dart';

class VehicleService {
  static Future<List<Vehicle>> getVehicles({String? marca, String? modelo}) async {
    final query = <String, dynamic>{};
    if (marca != null && marca.isNotEmpty) query['marca'] = marca;
    if (modelo != null && modelo.isNotEmpty) query['modelo'] = modelo;
    final res = await ApiClient.getAuth('/vehiculos', query: query);
    final data = res.data;
    if (data['success'] == true) {
      return (data['data'] as List).map((e) => Vehicle.fromJson(e)).toList();
    }
    throw Exception(data['message'] ?? 'Error al cargar vehículos');
  }

  static Future<Vehicle> getDetail(int id) async {
    final res = await ApiClient.getAuth('/vehiculos/detalle', query: {'id': id});
    final data = res.data;
    if (data['success'] == true) {
      return Vehicle.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? 'Error al cargar vehículo');
  }

  static Future<Vehicle> create({
    required String placa,
    required String chasis,
    required String marca,
    required String modelo,
    required int anio,
    required int cantidadRuedas,
    XFile? foto,
  }) async {
    final body = {
      'placa': placa,
      'chasis': chasis,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'cantidadRuedas': cantidadRuedas,
    };
    MultipartFile? mf;
    if (foto != null) {
      mf = await MultipartFile.fromFile(foto.path, filename: foto.name);
    }
    final res = await ApiClient.postAuthMultipart(
      '/vehiculos',
      body,
      files: mf != null ? [MapEntry('foto', mf)] : null,
    );
    final data = res.data;
    if (data['success'] == true) return Vehicle.fromJson(data['data']);
    throw Exception(data['message'] ?? 'Error al registrar vehículo');
  }

  static Future<Vehicle> edit({
    required int id,
    String? marca,
    String? modelo,
    int? anio,
    String? placa,
  }) async {
    final body = <String, dynamic>{'id': id};
    if (marca != null) body['marca'] = marca;
    if (modelo != null) body['modelo'] = modelo;
    if (anio != null) body['anio'] = anio;
    if (placa != null) body['placa'] = placa;
    final res = await ApiClient.postAuth('/vehiculos/editar', body);
    final data = res.data;
    if (data['success'] == true) return Vehicle.fromJson(data['data']);
    throw Exception(data['message'] ?? 'Error al editar vehículo');
  }

  static Future<String> uploadPhoto(int vehicleId, XFile foto) async {
    final mf = await MultipartFile.fromFile(foto.path, filename: foto.name);
    final res = await ApiClient.postAuthMultipart(
      '/vehiculos/foto',
      {'id': vehicleId},
      files: [MapEntry('foto', mf)],
    );
    final data = res.data;
    if (data['success'] == true) return data['data']['foto'] ?? '';
    throw Exception(data['message'] ?? 'Error al subir foto');
  }
}
