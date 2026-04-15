import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/theme/app_theme.dart';

class NewsDetailScreen extends StatefulWidget {
  final int newsId;
  const NewsDetailScreen({super.key, required this.newsId});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  NewsItem? _item;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _error = null; _item = null; });
    try {
      final item = await NewsService.getDetail(widget.newsId);
      if (mounted) setState(() => _item = item);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Noticia')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) return AppError(message: _error!, onRetry: _load);
    if (_item == null) return const AppLoading();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_item!.imagen != null)
            AppNetworkImage(
              url: _item!.imagen,
              width: double.infinity,
              height: 220,
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_item!.fuente != null)
                  Chip(
                    label: Text(_item!.fuente!),
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    labelStyle: const TextStyle(color: AppTheme.primary, fontSize: 12),
                  ),
                const SizedBox(height: 8),
                Text(_item!.titulo,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Text(AppDateUtils.format(_item!.fecha),
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary)),
                const Divider(height: 24),
                if (_item!.contenido != null && _item!.contenido!.isNotEmpty)
                  Html(data: _item!.contenido!)
                else
                  Text(_item!.resumen,
                      style: const TextStyle(
                          fontSize: 15, color: AppTheme.textPrimary, height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
