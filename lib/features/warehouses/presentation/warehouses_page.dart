import 'package:flutter/material.dart';

class WarehousesPage extends StatelessWidget {
  const WarehousesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bins / Warehouses'),
      ),
      body: const Center(
        child: Text(
          'Pantalla Bins funcionando',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}