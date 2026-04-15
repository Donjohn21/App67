import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_client.dart';
import '../../auth/models/auth_model.dart';

class ProfileService {
  static Future<UserProfile> getProfile() async {
    final res = await ApiClient.getAuth('/perfil');
    final data = res.data;
    if (data['success'] == true) {
      return UserProfile.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? 'Error al cargar perfil');
  }

  static Future<String> uploadPhoto(XFile file) async {
    final multipart = await MultipartFile.fromFile(file.path, filename: file.name);
    final res = await ApiClient.postAuthMultipart(
      '/perfil/foto',
      {},
      files: [MapEntry('foto', multipart)],
    );
    final data = res.data;
    if (data['success'] == true) {
      return data['data']['foto'] ?? '';
    }
    throw Exception(data['message'] ?? 'Error al subir foto');
  }
}
