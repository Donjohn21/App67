import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/maintenance_model.dart';
import '../services/maintenance_service.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/theme/app_theme.dart';

class MaintenanceListScreen extends StatefulWidget {
  final int vehicleId;
  const MaintenanceListScreen({super.key, required this.vehicleId});

  @override
  State<MaintenanceListScreen> createState() => _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends State<MaintenanceListScreen> {
  List<MaintenanceRecord>? _records;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _error = null; _records = null; });
    try {
      final r = await MaintenanceService.getList(widget.vehicleId);
      if (mounted) setState(() => _records = r);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mantenimientos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await context.push<bool>(
              '/vehicles/${widget.vehicleId}/maintenance/create');
          if (created == true) _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Registrar'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) return AppError(message: _error!, onRetry: _load);
    if (_records == null) return const AppLoading();
    if (_records!.isEmpty) return const AppEmpty(message: 'No hay mantenimientos registrados', icon: Icons.build_outlined);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _records!.length,
        itemBuilder: (_, i) => _MaintenanceCard(record: _records![i]),
      ),
    );
  }
}

class _MaintenanceCard extends StatelessWidget {
  final MaintenanceRecord record;
  const _MaintenanceCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/maintenance/${record.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.build_outlined, color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.tipo,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary)),
                    if (record.piezas != null && record.piezas!.isNotEmpty)
                      Text(record.piezas!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(height: 4),
                    Text(AppDateUtils.format(record.fecha),
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(AppDateUtils.formatCurrency(record.costo),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                          fontSize: 14)),
                  if (record.fotos.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.photo_library_outlined, size: 12, color: AppTheme.textSecondary),
                        const SizedBox(width: 3),
                        Text('${record.fotos.length}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
