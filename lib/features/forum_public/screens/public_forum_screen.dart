import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/forum_model.dart';
import '../services/forum_public_service.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/theme/app_theme.dart';

class PublicForumScreen extends StatefulWidget {
  const PublicForumScreen({super.key});

  @override
  State<PublicForumScreen> createState() => _PublicForumScreenState();
}

class _PublicForumScreenState extends State<PublicForumScreen> {
  List<ForumTopic>? _topics;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _error = null; _topics = null; });
    try {
      final topics = await ForumPublicService.getTopics();
      if (mounted) setState(() => _topics = topics);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foro Comunitario')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) return AppError(message: _error!, onRetry: _load);
    if (_topics == null) return const AppLoading();
    if (_topics!.isEmpty) return const AppEmpty(message: 'No hay temas en el foro', icon: Icons.forum_outlined);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _topics!.length,
        itemBuilder: (_, i) => _TopicCard(topic: _topics![i], isPublic: true),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final ForumTopic topic;
  final bool isPublic;

  const _TopicCard({required this.topic, this.isPublic = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push(
          isPublic ? '/public-forum/${topic.id}' : '/forum/${topic.id}',
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppNetworkImage(
                url: topic.vehiculoFoto,
                width: 60,
                height: 60,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(topic.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 4),
                    if (topic.vehiculo != null)
                      Text(topic.vehiculo!,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(topic.descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(topic.autor ?? 'Anónimo',
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary)),
                        const Spacer(),
                        const Icon(Icons.chat_bubble_outline,
                            size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text('${topic.totalRespuestas}',
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary)),
                        const SizedBox(width: 12),
                        Text(AppDateUtils.timeAgo(topic.fecha),
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
