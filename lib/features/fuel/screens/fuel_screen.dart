import 'package:flutter/material.dart';
import '../models/fuel_model.dart';
import '../services/fuel_service.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/theme/app_theme.dart';

class FuelScreen extends StatefulWidget {
  final int vehicleId;
  const FuelScreen({super.key, required this.vehicleId});

  @override
  State<FuelScreen> createState() => _FuelScreenState();
}

class _FuelScreenState extends State<FuelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<FuelRecord>? _combustible;
  List<FuelRecord>? _aceite;
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
    setState(() { _error = null; _combustible = null; _aceite = null; });
    try {
      final c = await FuelService.getList(widget.vehicleId, tipo: 'combustible');
      final a = await FuelService.getList(widget.vehicleId, tipo: 'aceite');
      if (mounted) setState(() { _combustible = c; _aceite = a; });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _showAddDialog(String tipo) async {
    final formKey = GlobalKey<FormState>();
    final cantCtrl = TextEditingController();
    final montoCtrl = TextEditingController();
    String unidad = tipo == 'combustible' ? 'galones' : 'litros';

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Registrar ${tipo == 'combustible' ? 'Combustible' : 'Aceite'}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: cantCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: unidad,
                decoration: const InputDecoration(labelText: 'Unidad'),
                items: ['galones', 'litros']
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => unidad = v ?? unidad,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: montoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monto (RD\$)'),
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
                await FuelService.create(
                  vehiculoId: widget.vehicleId,
                  tipo: tipo,
                  cantidad: double.parse(cantCtrl.text.replaceAll(',', '.')),
                  unidad: unidad,
                  monto: double.parse(montoCtrl.text.replaceAll(',', '.')),
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
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Combustible & Aceite'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(icon: Icon(Icons.local_gas_station_outlined), text: 'Combustible'),
            Tab(icon: Icon(Icons.opacity_outlined), text: 'Aceite'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(_tab.index == 0 ? 'combustible' : 'aceite'),
        child: const Icon(Icons.add),
      ),
      body: _error != null
          ? AppError(message: _error!, onRetry: _load)
          : TabBarView(
              controller: _tab,
              children: [
                _FuelList(records: _combustible, tipo: 'combustible'),
                _FuelList(records: _aceite, tipo: 'aceite'),
              ],
            ),
    );
  }
}

class _FuelList extends StatelessWidget {
  final List<FuelRecord>? records;
  final String tipo;

  const _FuelList({required this.records, required this.tipo});

  @override
  Widget build(BuildContext context) {
    if (records == null) return const AppLoading();
    if (records!.isEmpty) return AppEmpty(
      message: 'No hay registros de $tipo',
      icon: tipo == 'combustible' ? Icons.local_gas_station_outlined : Icons.opacity_outlined,
    );
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records!.length,
      itemBuilder: (_, i) {
        final r = records![i];
        final icon = tipo == 'combustible'
            ? Icons.local_gas_station_outlined
            : Icons.opacity_outlined;
        final color = tipo == 'combustible'
            ? const Color(0xFF6A1B9A)
            : const Color(0xFF1565C0);
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            title: Text('${r.cantidad} ${r.unidad}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(AppDateUtils.format(r.fecha)),
            trailing: Text(
              AppDateUtils.formatCurrency(r.monto),
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
        );
      },
    );
  }
}
