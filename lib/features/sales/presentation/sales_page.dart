import 'package:flutter/material.dart';

import '../../auth/presentation/protected_page.dart';
import '../data/sales_service.dart';
import '../models/sale_model.dart';
import 'create_sale_page.dart'; // 🔥 IMPORTANTE

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {

  final SalesService _service = SalesService();

  List<Sale> sales = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarVentas();
  }

  Future<void> cargarVentas() async {

    if (!mounted) return;

    setState(() {
      loading = true;
    });

    try {

      final data = await _service.getSales();

      if (!mounted) return;

      setState(() {
        sales = data;
        loading = false;
      });

    } catch (e) {

      print("ERROR SALES: $e");

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  // =========================================
  // 🔥 CONFIRMAR
  // =========================================

  Future<void> _confirm(int id) async {

    try {

      await _service.confirmSale(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Venta confirmada"),
        ),
      );

      await cargarVentas();

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  // =========================================
  // 🔥 PAGAR
  // =========================================

  Future<void> _pay(int id) async {

    try {

      await _service.paySale(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Venta pagada"),
        ),
      );

      await cargarVentas();

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  // =========================================
  // 🔥 FACTURAR
  // =========================================

  Future<void> _invoice(int id) async {

    try {

      await _service.generateInvoice(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Factura generada"),
        ),
      );

      await cargarVentas();

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  // =========================================
  // 🔥 UI
  // =========================================

  @override
  Widget build(BuildContext context) {

    return ProtectedPage(

      child: Scaffold(

        appBar: AppBar(
          title: const Text("Ventas"),
        ),

        // 🔥 FAB AGREGADO AQUÍ
        floatingActionButton: FloatingActionButton(
          onPressed: () async {

            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateSalePage(),
              ),
            );

            // 🔥 RECARGA AUTOMÁTICA
            if (result == true) {
              cargarVentas();
            }
          },
          child: const Icon(Icons.add),
        ),

        body: loading

            ? const Center(
                child: CircularProgressIndicator(),
              )

            : sales.isEmpty

                ? const Center(
                    child: Text("No hay ventas"),
                  )

                : RefreshIndicator(

                    onRefresh: cargarVentas,

                    child: ListView.builder(
                      itemCount: sales.length,

                      itemBuilder: (context, index) {
                        return _saleCard(sales[index]);
                      },
                    ),
                  ),
      ),
    );
  }

  // =========================================
  // 🔥 CARD VENTA
  // =========================================

  Widget _saleCard(Sale sale) {

    return Card(

      margin: const EdgeInsets.all(10),

      child: Padding(

        padding: const EdgeInsets.all(12),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              "Venta #${sale.numero}", // 🔥 mejor usar numero
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            Text("Cliente: ${sale.clienteNombre ?? ''}"),

            Text("Estado: ${sale.estado}"),

            Text("Total: \$${sale.total}"),

            const SizedBox(height: 10),

            Row(

              children: [

                // 🔥 CONFIRMAR
                if (sale.estado == "draft")
                  ElevatedButton(
                    onPressed: () => _confirm(sale.id),
                    child: const Text("Confirmar"),
                  ),

                const SizedBox(width: 8),

                // 🔥 PAGAR
                if (sale.estado == "confirmed")
                  ElevatedButton(
                    onPressed: () => _pay(sale.id),
                    child: const Text("Pagar"),
                  ),

                const SizedBox(width: 8),

                // 🔥 FACTURAR
                if (sale.estado == "paid")
                  ElevatedButton(
                    onPressed: () => _invoice(sale.id),
                    child: const Text("Facturar"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}