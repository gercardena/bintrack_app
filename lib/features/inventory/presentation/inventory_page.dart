import 'package:flutter/material.dart';
import '../../auth/presentation/protected_page.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProtectedPage(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventory'),
        ),
        body: const Center(
          child: Text(
            'INVENTORY – Usuario autenticado',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
