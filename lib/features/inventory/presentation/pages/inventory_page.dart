import 'package:flutter/material.dart';
import '../../data/services/inventory_service.dart';
import '../../data/models/inventory_model.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {

  final InventoryService service = InventoryService();

  List<Inventory> inventory = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadInventory();
  }

  Future<void> loadInventory() async {

    try {

      final data = await service.getInventory();

      setState(() {
        inventory = data;
        loading = false;
      });

    } catch (e) {

      setState(() {
        loading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Inventario"),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : inventory.isEmpty
              ? const Center(
                  child: Text("No hay datos de inventario"),
                )
              : RefreshIndicator(
                  onRefresh: loadInventory,
                  child: ListView.builder(
                    itemCount: inventory.length,
                    itemBuilder: (context, index) {

                      final item = inventory[index];

                      final bajoStock = item.disponible < 10;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(

                          title: Text(
                            item.binNombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Entradas: ${item.entradas}"),
                              Text("Préstamos: ${item.prestamos}"),
                              Text("Devoluciones: ${item.devoluciones}"),
                              Text("Bajas: ${item.bajas}"),
                            ],
                          ),

                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${item.disponible}",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: bajoStock ? Colors.red : Colors.green,
                                ),
                              ),
                              const Text(
                                "disponible",
                                style: TextStyle(fontSize: 10),
                              ),
                            ],
                          ),

                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}