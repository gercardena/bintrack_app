import 'package:flutter/material.dart';
import '../data/inventory_api.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {

  late Future<List<dynamic>> inventoryFuture;

  @override
  void initState() {
    super.initState();

    print("LLAMANDO API INVENTORY");

    inventoryFuture = InventoryApi.getInventory();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: inventoryFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          final inventory = snapshot.data!;

          if (inventory.isEmpty) {
            return const Center(child: Text("Sin inventario"));
          }

          return ListView.builder(
            itemCount: inventory.length,
            itemBuilder: (context, index) {

              final item = inventory[index];

              return ListTile(
                title: Text(item['nombre'] ?? 'Sin nombre'),
                subtitle: Text("Stock: ${item['cantidad'] ?? 0}"),
              );
            },
          );
        },
      ),
    );
  }
}
