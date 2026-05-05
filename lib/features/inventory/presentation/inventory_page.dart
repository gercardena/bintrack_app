import 'package:flutter/material.dart';
import '../data/inventory_api.dart';
import 'ajustar_stock_page.dart';

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
    cargarInventario();
  }

  Future<void> cargarInventario() async {
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
        onRefresh: cargarInventario,
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

  // 🔥 CARD ESTILO GLOBAL
  Widget _inventoryCard(dynamic item) {

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
          backgroundColor: Colors.orange,
          child: Text(
            (item['product_nombre'] ?? "?")[0],
            style: const TextStyle(color: Colors.white),
          ),
        ),

        title: Text(
          item['product_nombre'] ?? "Sin producto",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📦 Bin: ${item['bin_nombre'] ?? '---'}"),
            Text("📊 Stock: ${item['cantidad'] ?? 0}"),
          ],
        ),

        trailing: const Icon(Icons.chevron_right),

        onTap: () async {

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AjustarStockPage(item: item),
            ),
          );

          if (result == true) {
            cargarInventario();
          }
        },
      ),
    );
  }

  // 🔥 EMPTY STATE
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