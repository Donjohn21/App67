import 'package:flutter/material.dart';
import '../models/forum_model.dart';
import '../services/forum_public_service.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/theme/app_theme.dart';

class PublicForumDetailScreen extends StatefulWidget {
  final int topicId;
  const PublicForumDetailScreen({super.key, required this.topicId});

  @override
  State<PublicForumDetailScreen> createState() => _PublicForumDetailScreenState();
}

class _PublicForumDetailScreenState extends State<PublicForumDetailScreen> {
  ForumTopic? _topic;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _error = null; _topic = null; });
    try {
      final topic = await ForumPublicService.getDetail(widget.topicId);
      if (mounted) setState(() => _topic = topic);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Tema')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) return AppError(message: _error!, onRetry: _load);
    if (_topic == null) return const AppLoading();
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Original post
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppNetworkImage(
                        url: _topic!.vehiculoFoto,
                        width: 56,
                        height: 56,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_topic!.titulo,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppTheme.textPrimary)),
                            if (_topic!.vehiculo != null)
                              Text(_topic!.vehiculo!,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.primary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text(_topic!.descripcion,
                      style: const TextStyle(
                          fontSize: 15, color: AppTheme.textPrimary, height: 1.5)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(_topic!.autor ?? 'Anónimo',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      const Spacer(),
                      Text(AppDateUtils.format(_topic!.fecha),
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('${_topic!.respuestas.length} Respuestas',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          if (_topic!.respuestas.isEmpty)
            const AppEmpty(
                message: 'No hay respuestas aún', icon: Icons.chat_bubble_outline)
          else
            ..._topic!.respuestas.map((r) => _ReplyCard(reply: r)),
        ],
      ),
    );
  }
}

class _ReplyCard extends StatelessWidget {
  final ForumReply reply;
  const _ReplyCard({required this.reply});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  child: Text(
                    (reply.autor ?? 'A')[0].toUpperCase(),
                    style: const TextStyle(
                        color: AppTheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(reply.autor ?? 'Anónimo',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const Spacer(),
                Text(AppDateUtils.timeAgo(reply.fecha),
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),
            Text(reply.contenido,
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.textPrimary, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
