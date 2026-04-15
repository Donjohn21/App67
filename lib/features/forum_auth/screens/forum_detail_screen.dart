import 'package:flutter/material.dart';
import '../../forum_public/models/forum_model.dart';
import '../../forum_public/screens/public_forum_detail_screen.dart';
import '../services/forum_auth_service.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/theme/app_theme.dart';

class ForumDetailScreen extends StatefulWidget {
  final int topicId;
  const ForumDetailScreen({super.key, required this.topicId});

  @override
  State<ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<ForumDetailScreen> {
  ForumTopic? _topic;
  String? _error;
  final _replyCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _error = null; _topic = null; });
    try {
      final topic = await ForumAuthService.getDetail(widget.topicId);
      if (mounted) setState(() => _topic = topic);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _sendReply() async {
    if (_replyCtrl.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    try {
      await ForumAuthService.reply(
        temaId: widget.topicId,
        contenido: _replyCtrl.text.trim(),
      );
      _replyCtrl.clear();
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tema del Foro')),
      body: _error != null
          ? AppError(message: _error!, onRetry: _load)
          : _topic == null
              ? const AppLoading()
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Header
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
                                                    fontSize: 16)),
                                            if (_topic!.vehiculo != null)
                                              Text(_topic!.vehiculo!,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppTheme.primary)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20),
                                  Text(_topic!.descripcion,
                                      style: const TextStyle(
                                          fontSize: 15, height: 1.5)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline,
                                          size: 14, color: AppTheme.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(_topic!.autor ?? 'Anónimo',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textSecondary)),
                                      const Spacer(),
                                      Text(AppDateUtils.format(_topic!.fecha),
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.textSecondary)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('${_topic!.respuestas.length} Respuestas',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 8),
                          if (_topic!.respuestas.isEmpty)
                            const AppEmpty(message: 'Sin respuestas aún', icon: Icons.chat_bubble_outline)
                          else
                            ..._topic!.respuestas.map((r) => _ReplyCard(reply: r)),
                        ],
                      ),
                    ),
                    // Reply box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _replyCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Escribe tu respuesta...',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              maxLines: 2,
                              minLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _submitting
                              ? const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 2))
                              : IconButton(
                                  icon: const Icon(Icons.send, color: AppTheme.primary),
                                  onPressed: _sendReply,
                                ),
                        ],
                      ),
                    ),
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  child: Text(
                    (reply.autor ?? 'A')[0].toUpperCase(),
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Text(reply.autor ?? 'Anónimo',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const Spacer(),
                Text(AppDateUtils.timeAgo(reply.fecha),
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),
            Text(reply.contenido,
                style: const TextStyle(fontSize: 13, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
