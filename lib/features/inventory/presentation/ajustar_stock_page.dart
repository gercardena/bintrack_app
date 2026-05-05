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
        const SnackBar(content: Text("Cantidad inválida")),
      );
      return;
    }

    print("ITEM COMPLETO: ${widget.item}");
    print("PRODUCT ID: ${widget.item['product']}");

    setState(() => loading = true);

    final ok = await InventoryApi.ajustarStock(
      productId: widget.item['product'], // ✅ CORRECTO
      cantidad: cantidad,
    );

    setState(() => loading = false);

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al ajustar stock")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

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
              widget.item['product_nombre'] ?? "",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            if (widget.item['cantidad'] != null)
              Text("Stock actual: ${widget.item['cantidad']}"),

            const SizedBox(height: 20),

            TextField(
              controller: cantidadCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Cantidad (+ o -)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : guardar,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Guardar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}