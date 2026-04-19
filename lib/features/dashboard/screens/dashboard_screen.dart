import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/auth/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentSlide = 0;

  final List<_SlideItem> _slides = [
    _SlideItem(
      title: 'Gestiona tus Vehículos',
      subtitle:
          'Registra y da seguimiento a todos tus vehículos en un solo lugar.',
      icon: Icons.directions_car,
      gradient: [const Color(0xFF1565C0), const Color(0xFF1976D2)],
    ),
    _SlideItem(
      title: 'Control de Mantenimiento',
      subtitle:
          'Nunca pierdas el historial de mantenimientos de tus vehículos.',
      icon: Icons.build_outlined,
      gradient: [const Color(0xFF00695C), const Color(0xFF00897B)],
    ),
    _SlideItem(
      title: 'Monitorea tus Gastos',
      subtitle:
          'Lleva un registro detallado de gastos, ingresos y combustible.',
      icon: Icons.account_balance_wallet_outlined,
      gradient: [const Color(0xFF6A1B9A), const Color(0xFF8E24AA)],
    ),
    _SlideItem(
      title: 'Comunidad Automotriz',
      subtitle: 'Únete al foro y comparte experiencias con otros conductores.',
      icon: Icons.forum_outlined,
      gradient: [const Color(0xFFE65100), const Color(0xFFF57C00)],
    ),
  ];

  final List<String> _motivationalMessages = [
    'Tu vehículo es tu libertad. Cuídalo bien.',
    'Un mantenimiento a tiempo ahorra miles de pesos.',
    'El conocimiento es el mejor combustible.',
    'Cada kilómetro bien mantenido es una inversión.',
    'Conduce con confianza, gestiona con inteligencia.',
  ];

  @override
  void initState() {
    super.initState();
    // AuthProvider realiza la comprobación inicial del estado de sesión.
    // No necesitamos hacer una comprobación local aquí.
  }

  String get _currentMessage {
    final day = DateTime.now().day;
    return _motivationalMessages[day % _motivationalMessages.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VehicleManager'),
        actions: [
          if (context.watch<AuthProvider>().isLoggedIn)
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => context.push('/profile'),
            )
          else
            TextButton(
              onPressed: () => context.push('/login'),
              child: const Text(
                'Iniciar Sesión',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSlider(),
            const SizedBox(height: 12),
            _buildMotivationalBanner(),
            const SizedBox(height: 16),
            _buildPublicModules(),
            if (context.watch<AuthProvider>().isLoggedIn) ...[
              const SizedBox(height: 8),
              _buildPrivateModules(),
            ] else ...[
              const SizedBox(height: 8),
              _buildLoginPrompt(),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 200,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            viewportFraction: 1.0,
            onPageChanged: (i, _) => setState(() => _currentSlide = i),
          ),
          items: _slides.map((s) => _buildSlide(s)).toList(),
        ),
        const SizedBox(height: 12),
        AnimatedSmoothIndicator(
          activeIndex: _currentSlide,
          count: _slides.length,
          effect: const ExpandingDotsEffect(
            activeDotColor: AppTheme.primary,
            dotHeight: 8,
            dotWidth: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildSlide(_SlideItem slide) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: slide.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(slide.icon, size: 48, color: Colors.white.withOpacity(0.9)),
          const SizedBox(height: 12),
          Text(
            slide.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            slide.subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.format_quote, color: AppTheme.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _currentMessage,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicModules() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            'Explorar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
          children: [
            _ModuleCard(
              icon: Icons.newspaper_outlined,
              label: 'Noticias',
              color: const Color(0xFF1565C0),
              onTap: () => context.push('/news'),
            ),
            _ModuleCard(
              icon: Icons.play_circle_outline,
              label: 'Videos',
              color: const Color(0xFFD32F2F),
              onTap: () => context.push('/videos'),
            ),
            _ModuleCard(
              icon: Icons.car_rental,
              label: 'Catálogo',
              color: const Color(0xFF2E7D32),
              onTap: () => context.push('/catalog'),
            ),
            _ModuleCard(
              icon: Icons.forum_outlined,
              label: 'Foro',
              color: const Color(0xFF6A1B9A),
              onTap: () => context.push('/public-forum'),
            ),
            _ModuleCard(
              icon: Icons.info_outline,
              label: 'Acerca de',
              color: const Color(0xFFE65100),
              onTap: () => context.push('/about'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrivateModules() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            'Mi Área',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
          children: [
            _ModuleCard(
              icon: Icons.directions_car,
              label: 'Vehículos',
              color: const Color(0xFF1565C0),
              onTap: () => context.push('/vehicles'),
            ),
            _ModuleCard(
              icon: Icons.build_outlined,
              label: 'Mantenimiento',
              color: const Color(0xFF00695C),
              onTap: () => context.push('/vehicles'),
            ),
            _ModuleCard(
              icon: Icons.local_gas_station_outlined,
              label: 'Combustible',
              color: const Color(0xFF4527A0),
              onTap: () => context.push('/vehicles'),
            ),
            _ModuleCard(
              icon: Icons.tire_repair_outlined,
              label: 'Gomas',
              color: const Color(0xFF37474F),
              onTap: () => context.push('/vehicles'),
            ),
            _ModuleCard(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Gastos',
              color: const Color(0xFF6A1B9A),
              onTap: () => context.push('/vehicles'),
            ),
            _ModuleCard(
              icon: Icons.chat_bubble_outline,
              label: 'Mi Foro',
              color: const Color(0xFFBF360C),
              onTap: () => context.push('/forum'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginPrompt() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_open_outlined, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Accede a todas las funciones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Registra tus vehículos, controla gastos y participa en el foro.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/register'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  child: const Text('Registrarse'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                  ),
                  child: const Text('Iniciar Sesión'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SlideItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;

  _SlideItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
