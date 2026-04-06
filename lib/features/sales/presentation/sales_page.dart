import 'package:flutter/material.dart';
import '../../auth/presentation/protected_page.dart';
import '../data/sales_service.dart';
import '../models/sale_model.dart';

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
    setState(() => loading = true);

    try {

      final data = await _service.getSales();

      setState(() {
        sales = data;
        loading = false;
      });

    } catch (e) {

      print("ERROR SALES: $e");

      setState(() => loading = false);
    }
  }

  Future<void> _generateInvoice(int saleId) async {
    try {

      await _service.generateInvoice(saleId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Factura generada correctamente')),
      );

      cargarVentas(); // 🔄 recargar

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

    }
  }

  @override
  Widget build(BuildContext context) {

    return ProtectedPage(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ventas'),
          elevation: 0,
        ),

        backgroundColor: Colors.grey[100],

        body: RefreshIndicator(
          onRefresh: cargarVentas,
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : sales.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: sales.length,
                      itemBuilder: (context, index) {

                        final sale = sales[index];

                        return _saleCard(sale);
                      },
                    ),
        ),
      ),
    );
  }

  // 🔥 CARD GLOBAL
  Widget _saleCard(Sale sale) {

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
            sale.id.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),

        title: Text(
          "Venta #${sale.id}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👤 Cliente ID: ${sale.clienteId ?? 'N/A'}"),
            Text("💰 Total: \$${sale.total}"),
            Text("📌 Estado: ${sale.estado}"),
          ],
        ),

        trailing: IconButton(
          icon: const Icon(Icons.receipt_long, color: Colors.green),
          onPressed: () => _generateInvoice(sale.id),
        ),

        onTap: () {
          // 👉 detalle venta
        },
      ),
    );
  }

  // 🔥 EMPTY STATE
  Widget _emptyState() {
    return ListView(
      children: const [
        SizedBox(height: 100),
        Icon(Icons.point_of_sale_outlined, size: 80, color: Colors.grey),
        SizedBox(height: 16),
        Center(
          child: Text(
            "No hay ventas",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}