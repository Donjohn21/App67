import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/activate_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/news/screens/news_list_screen.dart';
import '../features/news/screens/news_detail_screen.dart';
import '../features/videos/screens/videos_screen.dart';
import '../features/catalog/screens/catalog_list_screen.dart';
import '../features/catalog/screens/catalog_detail_screen.dart';
import '../features/forum_public/screens/public_forum_screen.dart';
import '../features/forum_public/screens/public_forum_detail_screen.dart';
import '../features/about/screens/about_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/change_password_screen.dart';
import '../features/vehicles/models/vehicle_model.dart';
import '../features/vehicles/screens/vehicles_list_screen.dart';
import '../features/vehicles/screens/vehicle_form_screen.dart';
import '../features/vehicles/screens/vehicle_detail_screen.dart';
import '../features/maintenance/screens/maintenance_list_screen.dart';
import '../features/maintenance/screens/maintenance_form_screen.dart';
import '../features/fuel/screens/fuel_screen.dart';
import '../features/tires/screens/tires_screen.dart';
import '../features/expenses/screens/expenses_screen.dart';
import '../features/forum_auth/screens/forum_screen.dart';
import '../features/forum_auth/screens/forum_detail_screen.dart';
import '../features/forum_auth/screens/forum_create_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ── Public ─────────────────────────────────────────────────────────────
    GoRoute(
      path: '/',
      builder: (_, __) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (_, __) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/activate',
      builder: (ctx, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ActivateScreen(
          token: extra['token'] as String,
          matricula: extra['matricula'] as String,
        );
      },
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (_, __) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/news',
      builder: (_, __) => const NewsListScreen(),
    ),
    GoRoute(
      path: '/news/:id',
      builder: (_, state) =>
          NewsDetailScreen(newsId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/videos',
      builder: (_, __) => const VideosScreen(),
    ),
    GoRoute(
      path: '/catalog',
      builder: (_, __) => const CatalogListScreen(),
    ),
    GoRoute(
      path: '/catalog/:id',
      builder: (_, state) =>
          CatalogDetailScreen(catalogId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/public-forum',
      builder: (_, __) => const PublicForumScreen(),
    ),
    GoRoute(
      path: '/public-forum/:id',
      builder: (_, state) =>
          PublicForumDetailScreen(topicId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/about',
      builder: (_, __) => const AboutScreen(),
    ),

    // ── Authenticated ───────────────────────────────────────────────────────
    GoRoute(
      path: '/home',
      redirect: (_, __) => '/',
    ),
    GoRoute(
      path: '/profile',
      builder: (_, __) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/change-password',
      builder: (_, __) => const ChangePasswordScreen(),
    ),

    // Vehicles
    GoRoute(
      path: '/vehicles',
      builder: (_, __) => const VehiclesListScreen(),
    ),
    GoRoute(
      path: '/vehicles/create',
      builder: (_, __) => const VehicleFormScreen(),
    ),
    GoRoute(
      path: '/vehicles/:id',
      builder: (_, state) =>
          VehicleDetailScreen(vehicleId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/vehicles/:id/edit',
      builder: (_, state) => VehicleFormScreen(
          vehicle: state.extra as Vehicle?),
    ),
    GoRoute(
      path: '/vehicles/:id/maintenance',
      builder: (_, state) =>
          MaintenanceListScreen(vehicleId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/vehicles/:id/maintenance/create',
      builder: (_, state) =>
          MaintenanceFormScreen(vehicleId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/vehicles/:id/fuel',
      builder: (_, state) =>
          FuelScreen(vehicleId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/vehicles/:id/tires',
      builder: (_, state) =>
          TiresScreen(vehicleId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/vehicles/:id/expenses',
      builder: (_, state) =>
          ExpensesScreen(vehicleId: int.parse(state.pathParameters['id']!)),
    ),

    // Forum (auth)
    GoRoute(
      path: '/forum',
      builder: (_, __) => const ForumScreen(),
    ),
    GoRoute(
      path: '/forum/create',
      builder: (_, __) => const ForumCreateScreen(),
    ),
    GoRoute(
      path: '/forum/:id',
      builder: (_, state) =>
          ForumDetailScreen(topicId: int.parse(state.pathParameters['id']!)),
    ),
  ],
);
