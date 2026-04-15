import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

void main() {
  runApp(const App67App());
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
