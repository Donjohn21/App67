import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const List<_TeamMember> _team = [
    _TeamMember(
      nombre: 'Adrian Alexander Reyes',
      matricula: '2023-1100',
      telefono: '809-000-0001',
      telegram: '@adrianreyes',
      email: 'areyes@itla.edu.do',
    ),
    _TeamMember(
      nombre: 'Angel Isaac Mejia Martinez',
      matricula: '2024-1176',
      telefono: '809-000-0002',
      telegram: '@angelmejia',
      email: 'amejia@itla.edu.do',
    ),
    _TeamMember(
      nombre: 'Jayslen Rojas Serrano',
      matricula: '2023-1887',
      telefono: '809-000-0003',
      telegram: '@jayslenrojas',
      email: 'jrojas@itla.edu.do',
    ),
    _TeamMember(
      nombre: 'Integrante 4',
      matricula: '0000-0000',
      telefono: '809-000-0004',
      telegram: '@integrante4',
      email: 'integrante4@itla.edu.do',
    ),
    _TeamMember(
      nombre: 'Integrante 5',
      matricula: '0000-0000',
      telefono: '809-000-0005',
      telegram: '@integrante5',
      email: 'integrante5@itla.edu.do',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // App info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.directions_car, size: 56, color: Colors.white),
                  SizedBox(height: 12),
                  Text('VehicleManager',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Versión 1.0.0',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 12),
                  Text(
                    'Aplicación móvil para la gestión integral de vehículos.\nProyecto Final — ITLA, Trimestre 1-2026.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Equipo de Desarrollo',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
            ),
            const SizedBox(height: 12),
            ..._team.map((m) => _MemberCard(member: m)),
          ],
        ),
      ),
    );
  }
}

class _TeamMember {
  final String nombre;
  final String matricula;
  final String telefono;
  final String telegram;
  final String email;
  final String? foto;

  const _TeamMember({
    required this.nombre,
    required this.matricula,
    required this.telefono,
    required this.telegram,
    required this.email,
    this.foto,
  });
}

class _MemberCard extends StatelessWidget {
  final _TeamMember member;
  const _MemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              backgroundImage:
                  member.foto != null ? NetworkImage(member.foto!) : null,
              child: member.foto == null
                  ? Text(
                      member.nombre[0].toUpperCase(),
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.nombre,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Mat: ${member.matricula}',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  _ContactRow(icon: Icons.phone, text: member.telefono),
                  _ContactRow(icon: Icons.send, text: member.telegram),
                  _ContactRow(icon: Icons.email_outlined, text: member.email),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style:
                    const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
