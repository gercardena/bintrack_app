import 'package:flutter/material.dart';
import '../../auth/presentation/protected_page.dart';
import '../../auth/presentation/logout.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
