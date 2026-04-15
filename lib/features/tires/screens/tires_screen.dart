import 'package:flutter/material.dart';
import '../models/tire_model.dart';
import '../services/tire_service.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/theme/app_theme.dart';

class TiresScreen extends StatefulWidget {
  final int vehicleId;
  const TiresScreen({super.key, required this.vehicleId});

  @override
  State<TiresScreen> createState() => _TiresScreenState();
}

class _TiresScreenState extends State<TiresScreen> {
  TireInfo? _info;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _error = null; _info = null; });
    try {
      final info = await TireService.getTires(widget.vehicleId);
      if (mounted) setState(() => _info = info);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  Color _stateColor(String estado) {
    switch (estado) {
      case 'buena': return AppTheme.success;
      case 'regular': return Colors.orange;
      case 'mala': return AppTheme.error;
      case 'reemplazada': return AppTheme.textSecondary;
      default: return AppTheme.textSecondary;
    }
  }

  IconData _stateIcon(String estado) {
    switch (estado) {
      case 'buena': return Icons.check_circle_outline;
      case 'regular': return Icons.warning_amber_outlined;
      case 'mala': return Icons.error_outline;
      case 'reemplazada': return Icons.autorenew;
      default: return Icons.help_outline;
    }
  }

  Future<void> _showUpdateDialog(Tire tire) async {
    String selected = tire.estado;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Goma ${tire.posicion} (${tire.eje})'),
        content: StatefulBuilder(
          builder: (ctx, setS) => Column(
            mainAxisSize: MainAxisSize.min,
            children: ['buena', 'regular', 'mala', 'reemplazada'].map((e) => RadioListTile<String>(
              title: Text(e[0].toUpperCase() + e.substring(1)),
              value: e,
              groupValue: selected,
              activeColor: _stateColor(e),
              onChanged: (v) => setS(() => selected = v ?? e),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await TireService.updateStatus(tire.id, selected);
                _load();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppTheme.error),
                  );
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPunctureDialog(Tire tire) async {
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    DateTime fecha = DateTime.now();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Pinchazo - ${tire.posicion}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context);
              try {
                await TireService.logPuncture(
                  tire.id,
                  descCtrl.text.trim(),
                  fecha.toIso8601String().substring(0, 10),
                );
                _load();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppTheme.error),
                  );
                }
              }
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estado de Gomas')),
      body: _error != null
          ? AppError(message: _error!, onRetry: _load)
          : _info == null
              ? const AppLoading()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.tire_repair_outlined,
                                  size: 32, color: AppTheme.primary),
                              const SizedBox(width: 12),
                              Text('${_info!.cantidadRuedas} ruedas registradas',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._info!.gomas.map((tire) => Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: Icon(
                                _stateIcon(tire.estado),
                                color: _stateColor(tire.estado),
                                size: 32,
                              ),
                              title: Text(
                                'Goma ${tire.posicion}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Eje: ${tire.eje}'),
                                  Text('Pinchazos: ${tire.totalPinchazos}'),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _stateColor(tire.estado).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: _stateColor(tire.estado).withOpacity(0.5)),
                                    ),
                                    child: Text(
                                      tire.estado[0].toUpperCase() + tire.estado.substring(1),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: _stateColor(tire.estado),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => _showUpdateDialog(tire),
                              onLongPress: () => _showPunctureDialog(tire),
                            ),
                          )),
                      const SizedBox(height: 8),
                      const Text(
                        'Toca una goma para actualizar su estado.\nMantén presionado para registrar un pinchazo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
    );
  }
}
