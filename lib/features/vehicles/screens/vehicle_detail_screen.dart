import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/theme/app_theme.dart';

class VehicleDetailScreen extends StatefulWidget {
  final int vehicleId;
  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  Vehicle? _vehicle;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _error = null; _vehicle = null; });
    try {
      final v = await VehicleService.getDetail(widget.vehicleId);
      if (mounted) setState(() => _vehicle = v);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_vehicle?.fullName ?? 'Detalle de Vehículo'),
        actions: [
          if (_vehicle != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final updated = await context.push<bool>(
                    '/vehicles/${widget.vehicleId}/edit',
                    extra: _vehicle);
                if (updated == true) _load();
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) return AppError(message: _error!, onRetry: _load);
    if (_vehicle == null) return const AppLoading();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Photo
          AppNetworkImage(
            url: _vehicle!.foto,
            height: 220,
            width: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_vehicle!.fullName,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 16),
                // Info card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        InfoRow(icon: Icons.confirmation_number_outlined, label: 'Placa', value: _vehicle!.placa),
                        InfoRow(icon: Icons.vpn_key_outlined, label: 'Chasis', value: _vehicle!.chasis),
                        InfoRow(icon: Icons.tire_repair_outlined, label: 'Ruedas', value: '${_vehicle!.cantidadRuedas}'),
                        if (_vehicle!.fecha != null)
                          InfoRow(icon: Icons.calendar_today, label: 'Registrado', value: AppDateUtils.format(_vehicle!.fecha)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Financial summary
                if (_vehicle!.inversion != null) ...[
                  const Text('Resumen Financiero',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: [
                      _FinCard('Mantenimiento', _vehicle!.totalMantenimientos, const Color(0xFF1565C0)),
                      _FinCard('Combustible', _vehicle!.totalCombustible, const Color(0xFF6A1B9A)),
                      _FinCard('Gastos', _vehicle!.totalGastos, const Color(0xFFD32F2F)),
                      _FinCard('Ingresos', _vehicle!.totalIngresos, const Color(0xFF2E7D32)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: (_vehicle!.balance ?? 0) >= 0
                        ? AppTheme.success.withOpacity(0.1)
                        : AppTheme.error.withOpacity(0.1),
                    child: ListTile(
                      leading: Icon(
                          (_vehicle!.balance ?? 0) >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: (_vehicle!.balance ?? 0) >= 0
                              ? AppTheme.success
                              : AppTheme.error),
                      title: const Text('Balance'),
                      trailing: Text(
                        AppDateUtils.formatCurrency(_vehicle!.balance),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (_vehicle!.balance ?? 0) >= 0
                                ? AppTheme.success
                                : AppTheme.error),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Navigation buttons
                const Text('Gestionar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _NavButton(Icons.build_outlined, 'Mantenimientos', AppTheme.primary,
                    () => context.push('/vehicles/${_vehicle!.id}/maintenance')),
                _NavButton(Icons.local_gas_station_outlined, 'Combustible & Aceite',
                    const Color(0xFF6A1B9A),
                    () => context.push('/vehicles/${_vehicle!.id}/fuel')),
                _NavButton(Icons.tire_repair_outlined, 'Estado de Gomas',
                    const Color(0xFF37474F),
                    () => context.push('/vehicles/${_vehicle!.id}/tires')),
                _NavButton(Icons.account_balance_wallet_outlined, 'Gastos & Ingresos',
                    const Color(0xFF2E7D32),
                    () => context.push('/vehicles/${_vehicle!.id}/expenses')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FinCard extends StatelessWidget {
  final String label;
  final double? amount;
  final Color color;

  const _FinCard(this.label, this.amount, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
          Text(AppDateUtils.formatCurrency(amount),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _NavButton(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
