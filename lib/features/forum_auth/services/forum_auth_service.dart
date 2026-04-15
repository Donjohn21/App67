import '../../../core/api/api_client.dart';
import '../../forum_public/models/forum_model.dart';

class ForumAuthService {
  static Future<List<ForumTopic>> getTopics({int page = 1}) async {
    final res = await ApiClient.getAuth('/foro/temas', query: {'page': page});
    final data = res.data;
    if (data['success'] == true) {
      return (data['data'] as List).map((e) => ForumTopic.fromJson(e)).toList();
    }
    throw Exception(data['message'] ?? 'Error al cargar foro');
  }

  static Future<ForumTopic> getDetail(int id) async {
    final res = await ApiClient.getAuth('/foro/detalle', query: {'id': id});
    final data = res.data;
    if (data['success'] == true) return ForumTopic.fromJson(data['data']);
    throw Exception(data['message'] ?? 'Error al cargar tema');
  }

  static Future<List<ForumTopic>> getMyTopics({int page = 1}) async {
    final res = await ApiClient.getAuth('/foro/mis-temas', query: {'page': page});
    final data = res.data;
    if (data['success'] == true) {
      return (data['data'] as List).map((e) => ForumTopic.fromJson(e)).toList();
    }
    throw Exception(data['message'] ?? 'Error al cargar mis temas');
  }

  static Future<ForumTopic> createTopic({
    required int vehiculoId,
    required String titulo,
    required String descripcion,
  }) async {
    final res = await ApiClient.postAuth('/foro/crear', {
      'vehiculo_id': vehiculoId,
      'titulo': titulo,
      'descripcion': descripcion,
    });
    final data = res.data;
    if (data['success'] == true) return ForumTopic.fromJson(data['data']);
    throw Exception(data['message'] ?? 'Error al crear tema');
  }

  static Future<ForumReply> reply({
    required int temaId,
    required String contenido,
  }) async {
    final res = await ApiClient.postAuth('/foro/responder', {
      'tema_id': temaId,
      'contenido': contenido,
    });
    final data = res.data;
    if (data['success'] == true) return ForumReply.fromJson(data['data']);
    throw Exception(data['message'] ?? 'Error al responder');
  }
}
