import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const SainteFamilleApp());
}

class SainteFamilleApp extends StatelessWidget {
  const SainteFamilleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sainte Famille',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}