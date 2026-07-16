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
  final InventoryService service = InventoryService();

  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);

  List<Inventory> inventory = [];

  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadInventory();
  }

  Future<void> loadInventory() async {
    if (mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }

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
        errorMessage = e.toString();
      });
    }
  }

  int get totalEntradas {
    return inventory.fold(
      0,
      (sum, item) => sum + item.entradas,
    );
  }

  int get totalPrestamos {
    return inventory.fold(
      0,
      (sum, item) => sum + item.prestamos,
    );
  }

  int get totalEnClientes {
    return inventory.fold(
      0,
      (sum, item) => sum + item.enClientes,
    );
  }

  int get totalLlenos {
    return inventory.fold(
      0,
      (sum, item) => sum + item.llenos,
    );
  }

  int get totalDisponible {
    return inventory.fold(
      0,
      (sum, item) => sum + item.disponible,
    );
  }

  Color disponibleColor(int disponible) {
    if (disponible < 0) {
      return Colors.redAccent;
    }

    if (disponible < 10) {
      return Colors.orangeAccent;
    }

    return Colors.greenAccent;
  }

  String disponibleEstado(int disponible) {
    if (disponible < 0) {
      return "Revisar";
    }

    if (disponible < 10) {
      return "Bajo";
    }

    return "Disponible";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text("Inventario"),
        centerTitle: true,
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? _errorState()
              : RefreshIndicator(
                  onRefresh: loadInventory,
                  child: inventory.isEmpty
                      ? _emptyState()
                      : ListView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding:
                              const EdgeInsets.all(16),
                          children: [
                            _introCard(),
                            const SizedBox(height: 14),
                            _summaryCard(),
                            const SizedBox(height: 14),
                            ...inventory.map(
                              _inventoryCard,
                            ),
                          ],
                        ),
                ),
    );
  }

  Widget _introCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orangeAccent.withValues(alpha: 0.30),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.storage,
            color: Colors.orangeAccent,
            size: 30,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "El inventario muestra envases vacíos disponibles,"
              "envases llenos listos para vender y envases que "
              "están en clientes.",
              style: TextStyle(
                color: Colors.white,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    final color = disponibleColor(totalDisponible);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEA580C),
            Color(0xFF2563EB),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.20),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Resumen general",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Vacíos sirven para cargar stock. Llenos son productos listos para vender.",
            style: TextStyle(
              color: Colors.white70,
              height: 1.3,
              fontSize: 12.5,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _summaryBox(
                label: "Vacíos disponibles",
                value: "$totalDisponible",
                icon: Icons.inventory,
                color: color,
              ),
              const SizedBox(width: 10),
              _summaryBox(
                label: "Envases llenos",
                value: "$totalLlenos",
                icon: Icons.inventory_2,
                color: Colors.cyanAccent,
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _summaryBox(
                label: "En clientes",
                value: "$totalEnClientes",
                icon: Icons.people,
                color: Colors.orangeAccent,
              ),
              const SizedBox(width: 10),
              _summaryBox(
                label: "Entradas",
                value: "$totalEntradas",
                icon: Icons.call_received,
                color: Colors.greenAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11.5,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inventoryCard(
    Inventory item,
  ) {
    final color = disponibleColor(item.disponible);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.24),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    color.withValues(alpha: 0.16),
                child: Icon(
                  item.disponible < 0
                      ? Icons.warning_amber
                      : Icons.inventory_2,
                  color: color,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.binNombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Estado operativo del envase",
                      style: TextStyle(
                        color: Colors.white60,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              _statusPill(
                text: disponibleEstado(
                  item.disponible,
                ),
                color: color,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _metricBox(
                label: "Entradas",
                value: "${item.entradas}",
                color: Colors.greenAccent,
              ),
              const SizedBox(width: 10),
              _metricBox(
                label: "Préstamos",
                value: "${item.prestamos}",
                color: Colors.orangeAccent,
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _metricBox(
                label: "Devoluciones",
                value: "${item.devoluciones}",
                color: Colors.cyanAccent,
              ),
              const SizedBox(width: 10),
              _metricBox(
                label: "Bajas",
                value: "${item.bajas}",
                color: Colors.redAccent,
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _metricBox(
                label: "En clientes",
                value: "${item.enClientes}",
                color: Colors.deepPurpleAccent,
              ),
              const SizedBox(width: 10),
              _metricBox(
                label: "Llenos",
                value: "${item.llenos}",
                color: Colors.blueAccent,
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.30),
              ),
            ),
            child: Column(
              children: [
                Text(
                  item.disponible.toString(),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Envases vacíos disponibles",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.22),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusPill({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.30),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 90),
        Icon(
          Icons.storage,
          size: 82,
          color: Colors.white.withValues(alpha: 0.35),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            "No hay datos de inventario",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Registra entradas de envases y stock lleno para comenzar "
          "a ver el inventario disponible.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white60,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _errorState() {
    return RefreshIndicator(
      onRefresh: loadInventory,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 90),
          const Icon(
            Icons.error_outline,
            size: 72,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "No pudimos cargar el inventario",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? "",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white60,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: loadInventory,
            icon: const Icon(Icons.refresh),
            label: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }
}