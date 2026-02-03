import 'package:flutter/material.dart';
import '../../auth/presentation/protected_page.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProtectedPage(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sales'),
        ),
        body: const Center(
          child: Text(
            'SALES – Usuario autenticado',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
