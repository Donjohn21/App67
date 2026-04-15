import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../vehicles/models/vehicle_model.dart';
import '../../vehicles/services/vehicle_service.dart';
import '../services/forum_auth_service.dart';
import '../../../core/theme/app_theme.dart';

class ForumCreateScreen extends StatefulWidget {
  const ForumCreateScreen({super.key});

  @override
  State<ForumCreateScreen> createState() => _ForumCreateScreenState();
}

class _ForumCreateScreenState extends State<ForumCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  List<Vehicle>? _vehicles;
  int? _selectedVehicleId;
  bool _loading = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    setState(() => _loading = true);
    try {
      final v = await VehicleService.getVehicles();
      if (mounted) {
        setState(() {
          _vehicles = v;
          if (v.isNotEmpty) _selectedVehicleId = v.first.id;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _vehicles = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un vehículo')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ForumAuthService.createTopic(
        vehiculoId: _selectedVehicleId!,
        titulo: _titleCtrl.text.trim(),
        descripcion: _descCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tema creado'), backgroundColor: AppTheme.success),
        );
        context.pop(true);
      }
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
      appBar: AppBar(title: const Text('Crear Tema')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_vehicles != null && _vehicles!.isNotEmpty)
                      DropdownButtonFormField<int>(
                        value: _selectedVehicleId,
                        decoration: const InputDecoration(
                          labelText: 'Vehículo',
                          prefixIcon: Icon(Icons.directions_car),
                        ),
                        items: _vehicles!
                            .map((v) => DropdownMenuItem(
                                value: v.id, child: Text(v.fullName)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedVehicleId = v),
                      )
                    else
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'Necesitas tener al menos un vehículo con foto para crear un tema.',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        prefixIcon: Icon(Icons.description_outlined),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 24),
                    _submitting
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _submit,
                            child: const Text('Publicar Tema', style: TextStyle(fontSize: 16)),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
