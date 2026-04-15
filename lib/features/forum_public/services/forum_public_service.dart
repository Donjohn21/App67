import '../../../core/api/api_client.dart';
import '../models/forum_model.dart';

class ForumPublicService {
  static Future<List<ForumTopic>> getTopics({int page = 1}) async {
    final res = await ApiClient.get('/publico/foro', query: {'page': page});
    final data = res.data;
    if (data['success'] == true) {
      return (data['data'] as List)
          .map((e) => ForumTopic.fromJson(e))
          .toList();
    }
    throw Exception(data['message'] ?? 'Error al cargar foro');
  }

  static Future<ForumTopic> getDetail(int id) async {
    final res = await ApiClient.get('/publico/foro/detalle', query: {'id': id});
    final data = res.data;
    if (data['success'] == true) {
      return ForumTopic.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? 'Error al cargar tema');
  }
}
