import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'features/dashboard/dashboard_page.dart';

import 'package:provider/provider.dart';
import 'features/auth/auth_service.dart';
import 'features/auth/login_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthService()..init())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EdenMind',
      theme: EdenMindTheme.theme,
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          if (!auth.isInitialized) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return auth.isAuthenticated
              ? const DashboardPage()
              : const LoginPage();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
