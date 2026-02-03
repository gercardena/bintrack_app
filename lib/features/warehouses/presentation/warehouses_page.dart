import 'package:flutter/material.dart';
import '../../auth/presentation/protected_page.dart';

class WarehousesPage extends StatelessWidget {
  const WarehousesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProtectedPage(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Warehouses'),
        ),
        body: const Center(
          child: Text(
            'WAREHOUSES – Usuario autenticado',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
