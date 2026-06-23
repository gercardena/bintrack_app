import 'package:flutter/material.dart';

import '../../data/models/inventory_model.dart';
import '../../data/services/inventory_service.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() =>
      _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final InventoryService service =
      InventoryService();

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

      if (!mounted) return;

      setState(() {
        inventory = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error cargando inventario: $e",
          ),
        ),
      );
    }
  }

  Widget datoInventario(
    String etiqueta,
    int valor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 3,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta),
          Text(
            valor.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget construirTarjeta(Inventory item) {
    final bajoStock = item.disponible < 10;

    final colorDisponible = bajoStock
        ? Colors.red
        : Colors.green;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              item.binNombre,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            datoInventario(
              "Entradas",
              item.entradas,
            ),
            datoInventario(
              "Préstamos",
              item.prestamos,
            ),
            datoInventario(
              "Devoluciones",
              item.devoluciones,
            ),
            datoInventario(
              "Bajas",
              item.bajas,
            ),
            const Divider(height: 24),
            datoInventario(
              "En clientes",
              item.enClientes,
            ),
            datoInventario(
              "Envases llenos",
              item.llenos,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorDisponible.withValues(
                  alpha: 0.1,
                ),
                borderRadius:
                    BorderRadius.circular(8),
                border: Border.all(
                  color: colorDisponible,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    item.disponible.toString(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorDisponible,
                    ),
                  ),
                  const Text(
                    "Envases vacíos disponibles",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventario"),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : inventory.isEmpty
              ? const Center(
                  child: Text(
                    "No hay datos de inventario",
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadInventory,
                  child: ListView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    itemCount: inventory.length,
                    itemBuilder: (context, index) {
                      return construirTarjeta(
                        inventory[index],
                      );
                    },
                  ),
                ),
    );
  }
}