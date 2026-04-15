import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../forum_public/models/forum_model.dart';
import '../../forum_public/screens/public_forum_screen.dart';
import '../services/forum_auth_service.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/theme/app_theme.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<ForumTopic>? _all;
  List<ForumTopic>? _mine;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _error = null; _all = null; _mine = null; });
    try {
      final all = await ForumAuthService.getTopics();
      final mine = await ForumAuthService.getMyTopics();
      if (mounted) setState(() { _all = all; _mine = mine; });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foro'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Todos los Temas'),
            Tab(text: 'Mis Temas'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await context.push<bool>('/forum/create');
          if (created == true) _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Tema'),
      ),
      body: _error != null
          ? AppError(message: _error!, onRetry: _load)
          : TabBarView(
              controller: _tab,
              children: [
                _TopicList(topics: _all, isPublic: false),
                _TopicList(topics: _mine, isPublic: false),
              ],
            ),
    );
  }
}

class _TopicList extends StatelessWidget {
  final List<ForumTopic>? topics;
  final bool isPublic;

  const _TopicList({required this.topics, required this.isPublic});

  @override
  Widget build(BuildContext context) {
    if (topics == null) return const AppLoading();
    if (topics!.isEmpty) return const AppEmpty(message: 'No hay temas', icon: Icons.forum_outlined);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: topics!.length,
      itemBuilder: (_, i) => _TopicCard(topic: topics![i], isPublic: isPublic),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final ForumTopic topic;
  final bool isPublic;

  const _TopicCard({required this.topic, required this.isPublic});

  @override
  Widget build(BuildContext context) {
    // Reuse the same card widget from public forum
    return _ForumTopicCard(topic: topic, isPublic: isPublic);
  }
}

class _ForumTopicCard extends StatelessWidget {
  final ForumTopic topic;
  final bool isPublic;

  const _ForumTopicCard({required this.topic, required this.isPublic});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/forum/${topic.id}'),
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline,
                            size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text('${topic.totalRespuestas}',
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary)),
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
