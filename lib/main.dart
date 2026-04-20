import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'core/auth/auth_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider()..check(),
      child: const App67App(),
    ),
  );
}

class App67App extends StatelessWidget {
  const App67App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VehicleManager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
