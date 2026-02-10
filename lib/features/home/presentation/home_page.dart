import 'dart:async';
import 'package:flutter/material.dart';

import '../../auth/presentation/protected_page.dart';
import '../../auth/presentation/logout.dart';
import '../../../core/auth/auth_controller.dart';
import '../../user/data/user_api.dart'; // 👈 IMPORT NUEVO

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
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    });

    // 🚀 Primera request protegida
    _loadProfile();
  }

  /// 🔥 Request protegida real
  Future<void> _loadProfile() async {
    try {
      final profile = await UserApi.getProfile();

      print('PROFILE OK: $profile');

    } catch (e) {
      print('ERROR PROFILE: $e');
    }
  }

  @override
  void dispose() {
    _logoutSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        body: const Center(
          child: Text(
            'HOME – Usuario autenticado',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
