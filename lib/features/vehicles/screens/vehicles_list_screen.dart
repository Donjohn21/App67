import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/theme/app_theme.dart';

class VehiclesListScreen extends StatefulWidget {
  const VehiclesListScreen({super.key});

  @override
  State<VehiclesListScreen> createState() => _VehiclesListScreenState();
}

class _VehiclesListScreenState extends State<VehiclesListScreen> {
  List<Vehicle>? _vehicles;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _error = null; _vehicles = null; });
    try {
      final v = await VehicleService.getVehicles();
      if (mounted) setState(() => _vehicles = v);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Vehículos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await context.push<bool>('/vehicles/create');
          if (created == true) _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) return AppError(message: _error!, onRetry: _load);
    if (_vehicles == null) return const AppLoading();
    if (_vehicles!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.directions_car_outlined, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            const Text('No tienes vehículos registrados',
                style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final created = await context.push<bool>('/vehicles/create');
                if (created == true) _load();
              },
              icon: const Icon(Icons.add),
              label: const Text('Registrar Vehículo'),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _vehicles!.length,
        itemBuilder: (_, i) => _VehicleCard(
          vehicle: _vehicles![i],
          onTap: () => context.push('/vehicles/${_vehicles![i].id}'),
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const _VehicleCard({required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            AppNetworkImage(
              url: vehicle.foto,
              width: 100,
              height: 90,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vehicle.fullName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Text('Placa: ${vehicle.placa}',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary)),
                    Text('${vehicle.cantidadRuedas} ruedas',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
