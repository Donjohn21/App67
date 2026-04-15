import '../../../core/api/api_client.dart';
import '../models/news_model.dart';

class NewsService {
  static Future<List<NewsItem>> getNews() async {
    final res = await ApiClient.getAuth('/noticias');
    final data = res.data;
    if (data['success'] == true) {
      return (data['data'] as List)
          .map((e) => NewsItem.fromJson(e))
          .toList();
    }
    throw Exception(data['message'] ?? 'Error al cargar noticias');
  }

  static Future<NewsItem> getDetail(int id) async {
    final res = await ApiClient.getAuth('/noticias/detalle', query: {'id': id});
    final data = res.data;
    if (data['success'] == true) {
      return NewsItem.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? 'Error al cargar noticia');
  }
}
