import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/theme/app_theme.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  List<NewsItem>? _news;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _error = null; _news = null; });
    try {
      final items = await NewsService.getNews();
      if (mounted) setState(() => _news = items);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Noticias Automotrices')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) return AppError(message: _error!, onRetry: _load);
    if (_news == null) return const AppLoading();
    if (_news!.isEmpty) return const AppEmpty(message: 'No hay noticias disponibles', icon: Icons.newspaper_outlined);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _news!.length,
        itemBuilder: (_, i) => _NewsCard(item: _news![i]),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsItem item;
  const _NewsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/news/${item.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imagen != null)
              AppNetworkImage(
                url: item.imagen,
                height: 180,
                width: double.infinity,
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.fuente != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(item.fuente!,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                  const SizedBox(height: 8),
                  Text(item.titulo,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 6),
                  Text(item.resumen,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppDateUtils.format(item.fecha),
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
                      const Text('Leer más →',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
