import 'package:flutter/material.dart';
import '../data/inventory_api.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {

  List<dynamic> inventory = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarInventory();
  }

  Future<void> cargarInventory() async {
    setState(() => loading = true);

    try {

      final data = await InventoryApi.getInventory();

      setState(() {
        inventory = data;
        loading = false;
      });

    } catch (e) {

      print("ERROR INVENTORY: $e");

      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        elevation: 0,
      ),

      backgroundColor: Colors.grey[100],

      body: RefreshIndicator(
        onRefresh: cargarInventory,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : inventory.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: inventory.length,
                    itemBuilder: (context, index) {

                      final item = inventory[index];

                      return _inventoryCard(item);
                    },
                  ),
      ),
    );
  }

  // 🔥 CARD ESTILO CLIENTES (REUTILIZABLE)
  Widget _inventoryCard(dynamic item) {

    final product = item['product_nombre'] ?? 'Sin producto';
    final bin = item['bin_nombre'] ?? 'Sin bin';
    final cantidad = item['cantidad'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),

        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            product.isNotEmpty ? product[0] : "?",
            style: const TextStyle(color: Colors.white),
          ),
        ),

        title: Text(
          product,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📦 Bin: $bin"),
            Text("📊 Stock: $cantidad"),
          ],
        ),

        trailing: const Icon(Icons.chevron_right),

        onTap: () {
          // 👉 futura pantalla detalle inventario
        },
      ),
    );
  }

  // 🔥 ESTADO VACÍO CONSISTENTE
  Widget _emptyState() {
    return ListView(
      children: const [
        SizedBox(height: 100),
        Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
        SizedBox(height: 16),
        Center(
          child: Text(
            "Sin inventario",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}