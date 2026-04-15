import '../../../core/api/api_client.dart';
import '../models/video_model.dart';

class VideoService {
  static Future<List<VideoItem>> getVideos() async {
    final res = await ApiClient.getAuth('/videos');
    final data = res.data;
    if (data['success'] == true) {
      return (data['data'] as List)
          .map((e) => VideoItem.fromJson(e))
          .toList();
    }
    throw Exception(data['message'] ?? 'Error al cargar videos');
  }
}
