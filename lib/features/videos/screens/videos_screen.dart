import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/theme/app_theme.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  List<VideoItem>? _videos;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _error = null; _videos = null; });
    try {
      final items = await VideoService.getVideos();
      if (mounted) setState(() => _videos = items);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Videos Educativos')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) return AppError(message: _error!, onRetry: _load);
    if (_videos == null) return const AppLoading();
    if (_videos!.isEmpty) return const AppEmpty(message: 'No hay videos disponibles', icon: Icons.play_circle_outline);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _videos!.length,
        itemBuilder: (_, i) => _VideoCard(item: _videos![i]),
      ),
    );
  }
}

class _VideoCard extends StatefulWidget {
  final VideoItem item;
  const _VideoCard({required this.item});

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  bool _playing = false;
  YoutubePlayerController? _controller;

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  void _startPlaying() {
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );
    _controller!.loadVideoById(videoId: widget.item.youtubeId);
    setState(() => _playing = true);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_playing && _controller != null)
            YoutubePlayer(controller: _controller!)
          else
            Stack(
              alignment: Alignment.center,
              children: [
                AppNetworkImage(
                  url: widget.item.thumbnail ??
                      'https://img.youtube.com/vi/${widget.item.youtubeId}/hqdefault.jpg',
                  height: 200,
                  width: double.infinity,
                ),
                GestureDetector(
                  onTap: _startPlaying,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow,
                        color: Colors.white, size: 36),
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.item.categoria != null)
                  Chip(
                    label: Text(widget.item.categoria!),
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    labelStyle: const TextStyle(
                        color: AppTheme.primary, fontSize: 11),
                    padding: EdgeInsets.zero,
                  ),
                const SizedBox(height: 6),
                Text(widget.item.titulo,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text(widget.item.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
