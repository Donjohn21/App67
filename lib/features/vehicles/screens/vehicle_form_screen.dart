import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';
import '../../../core/theme/app_theme.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle; // null = create, non-null = edit
  const VehicleFormScreen({super.key, this.vehicle});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _placaCtrl = TextEditingController();
  final _chasisCtrl = TextEditingController();
  final _marcaCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();
  final _anioCtrl = TextEditingController();
  int _ruedas = 4;
  XFile? _foto;
  bool _loading = false;

  bool get _isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _placaCtrl.text = widget.vehicle!.placa;
      _chasisCtrl.text = widget.vehicle!.chasis;
      _marcaCtrl.text = widget.vehicle!.marca;
      _modeloCtrl.text = widget.vehicle!.modelo;
      _anioCtrl.text = widget.vehicle!.anio.toString();
      _ruedas = widget.vehicle!.cantidadRuedas;
    }
  }

  @override
  void dispose() {
    _placaCtrl.dispose();
    _chasisCtrl.dispose();
    _marcaCtrl.dispose();
    _modeloCtrl.dispose();
    _anioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) setState(() => _foto = file);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_isEditing) {
        await VehicleService.edit(
          id: widget.vehicle!.id,
          marca: _marcaCtrl.text.trim(),
          modelo: _modeloCtrl.text.trim(),
          anio: int.parse(_anioCtrl.text),
          placa: _placaCtrl.text.trim(),
        );
        if (_foto != null) {
          await VehicleService.uploadPhoto(widget.vehicle!.id, _foto!);
        }
      } else {
        await VehicleService.create(
          placa: _placaCtrl.text.trim(),
          chasis: _chasisCtrl.text.trim(),
          marca: _marcaCtrl.text.trim(),
          modelo: _modeloCtrl.text.trim(),
          anio: int.parse(_anioCtrl.text),
          cantidadRuedas: _ruedas,
          foto: _foto,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_isEditing ? 'Vehículo actualizado' : 'Vehículo registrado'),
              backgroundColor: AppTheme.success),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_isEditing ? 'Editar Vehículo' : 'Registrar Vehículo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Photo picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.primary.withOpacity(0.3),
                        style: BorderStyle.solid),
                  ),
                  child: _foto != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(File(_foto!.path), fit: BoxFit.cover))
                      : widget.vehicle?.foto != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(widget.vehicle!.foto!,
                                  fit: BoxFit.cover))
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined,
                                    size: 40, color: AppTheme.primary),
                                SizedBox(height: 8),
                                Text('Agregar foto',
                                    style: TextStyle(color: AppTheme.primary)),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 20),
              _field(_placaCtrl, 'Placa', Icons.confirmation_number_outlined,
                enabled: !_isEditing),
              const SizedBox(height: 12),
              if (!_isEditing)
                _field(_chasisCtrl, 'Número de chasis', Icons.vpn_key_outlined),
              if (!_isEditing) const SizedBox(height: 12),
              _field(_marcaCtrl, 'Marca', Icons.branding_watermark_outlined),
              const SizedBox(height: 12),
              _field(_modeloCtrl, 'Modelo', Icons.directions_car_outlined),
              const SizedBox(height: 12),
              TextFormField(
                controller: _anioCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Año',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  final y = int.tryParse(v);
                  if (y == null || y < 1900 || y > 2030) return 'Año inválido';
                  return null;
                },
              ),
              if (!_isEditing) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _ruedas,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad de ruedas',
                    prefixIcon: Icon(Icons.tire_repair_outlined),
                  ),
                  items: [4, 6, 8, 18]
                      .map((n) => DropdownMenuItem(value: n, child: Text('$n ruedas')))
                      .toList(),
                  onChanged: (v) => setState(() => _ruedas = v ?? 4),
                ),
              ],
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Text(_isEditing ? 'Guardar Cambios' : 'Registrar',
                          style: const TextStyle(fontSize: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {bool enabled = true}) {
    return TextFormField(
      controller: ctrl,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
    );
  }
}
