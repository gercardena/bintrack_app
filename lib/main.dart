import 'package:flutter/material.dart';

import 'core/theme/theme.dart';
import 'core/theme/theme_controller.dart';

import 'features/auth/presentation/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.instance.load();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    ThemeController.instance.addListener(_themeChanged);
  }

  @override
  void dispose() {
    ThemeController.instance.removeListener(_themeChanged);
    super.dispose();
  }

  void _themeChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeController.instance.themeMode,
      home: const AuthGate(),
    );
  }
}
