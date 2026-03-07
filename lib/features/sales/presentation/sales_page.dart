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
  late Future<List<Sale>> _salesFuture;

  @override
  void initState() {
    super.initState();
    _salesFuture = _service.getSales();
  }

  void _generateInvoice(int saleId) async {
    try {
      await _service.generateInvoice(saleId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Factura generada correctamente')),
      );

      setState(() {
        _salesFuture = _service.getSales();
      });

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
          title: const Text('Sales'),
        ),
        body: FutureBuilder<List<Sale>>(
          future: _salesFuture,
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final sales = snapshot.data!;

            if (sales.isEmpty) {
              return const Center(child: Text('No hay ventas'));
            }

            return ListView.builder(
              itemCount: sales.length,
              itemBuilder: (context, index) {

                final sale = sales[index];

                return Card(
                  child: ListTile(
                    title: Text('Venta #${sale.id}'),
                    subtitle: Text(
                        'Cliente: ${sale.cliente ?? 'N/A'}\n'
                        'Total: \$${sale.total}\n'
                        'Estado: ${sale.estado}'
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.receipt_long),
                      onPressed: () => _generateInvoice(sale.id),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
