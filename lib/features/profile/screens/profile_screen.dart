import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/profile_service.dart';
import '../../auth/models/auth_model.dart';
import '../../auth/services/auth_service.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  String? _error;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _profile = null;
    });
    try {
      final profile = await ProfileService.getProfile();
      if (mounted) setState(() => _profile = profile);
    } catch (e) {
      if (mounted)
        setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null) return;
    setState(() => _uploading = true);
    try {
      await ProfileService.uploadPhoto(file);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      // Usamos el provider para cerrar sesión y notificar a la UI
      await context.read<AuthProvider>().logout();
      if (mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) return AppError(message: _error!, onRetry: _load);
    if (_profile == null) return const AppLoading();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 56,
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                backgroundImage: _profile!.foto != null
                    ? NetworkImage(_profile!.foto!)
                    : null,
                child: _profile!.foto == null
                    ? Text(
                        _profile!.nombre.isNotEmpty
                            ? _profile!.nombre[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: _uploading
                    ? const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : GestureDetector(
                        onTap: _pickPhoto,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _profile!.nombre,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            _profile!.email,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          // Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.badge_outlined,
                    label: 'Matrícula',
                    value: _profile!.matricula,
                  ),
                  if (_profile!.rol != null)
                    InfoRow(
                      icon: Icons.work_outline,
                      label: 'Rol',
                      value: _profile!.rol!,
                    ),
                  if (_profile!.grupo != null)
                    InfoRow(
                      icon: Icons.group_outlined,
                      label: 'Grupo',
                      value: _profile!.grupo!,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Actions
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.lock_outline,
                    color: AppTheme.primary,
                  ),
                  title: const Text('Cambiar Contraseña'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/change-password'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.directions_car,
                    color: AppTheme.primary,
                  ),
                  title: const Text('Mis Vehículos'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/vehicles'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
