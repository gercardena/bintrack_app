import 'package:flutter/material.dart';

import '../data/inventory_api.dart';

class AjustarStockPage extends StatefulWidget {

  final dynamic item;

  const AjustarStockPage({
    super.key,
    required this.item,
  });

  @override
  State<AjustarStockPage> createState() => _AjustarStockPageState();
}

class _AjustarStockPageState extends State<AjustarStockPage> {

  final cantidadCtrl = TextEditingController();

  bool loading = false;

  Future<void> guardar() async {

    final cantidad = int.tryParse(cantidadCtrl.text);

    if (cantidad == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cantidad inválida"),
        ),
      );

      return;
    }

    print("ITEM COMPLETO: ${widget.item}");

    // 🔥 SOPORTA INVENTARIO Y PRODUCTOS
    final int productId = widget.item['product'] ?? widget.item['id'];

    print("PRODUCT ID: $productId");

    setState(() {
      loading = true;
    });

    final ok = await InventoryApi.ajustarStock(
      productId: productId,
      binId: widget.item['bin'] ?? 5,
      cantidad: cantidad,
    );

    setState(() {
      loading = false;
    });

    if (ok) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Stock actualizado"),
        ),
      );

      Navigator.pop(context, true);

    } else {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al ajustar stock"),
        ),
      );
    }
  }

  @override
  void dispose() {

    cantidadCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final nombre =
        widget.item['product_nombre'] ??
        widget.item['nombre'] ??
        "Producto";

    final stock =
        widget.item['cantidad'] ?? 0;

    final bin =
        widget.item['bin_nombre'] ?? "SIN BIN";

    return Scaffold(

      appBar: AppBar(
        title: const Text("Ajustar Stock"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              nombre,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "📦 Bin: $bin",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 8),

            Text(
              "📊 Stock actual: $stock",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            TextField(

              controller: cantidadCtrl,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                labelText: "Cantidad (+ o -)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed: loading ? null : guardar,

                child: loading

                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )

                    : const Text("Guardar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}