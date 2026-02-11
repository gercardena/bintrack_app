import 'dart:async';
import 'package:flutter/material.dart';

import '../../auth/presentation/protected_page.dart';
import '../../auth/presentation/logout.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/user_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  StreamSubscription? _logoutSub;

  @override
  void initState() {
    super.initState();

    // 👂 Escuchar logout global
    _logoutSub = AuthController().onLogout.listen((_) {

      // 🔥 limpiar usuario global
      UserController().clear();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    });
  }

  @override
  void dispose() {
    _logoutSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final user = UserController().user;

    return ProtectedPage(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('BinTrack'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => Logout.execute(context),
            ),
          ],
        ),
        body: Center(
          child: Text(
            'HOME – Usuario autenticado: ${user?['username'] ?? ''}',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
