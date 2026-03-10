import 'package:flutter/material.dart';

import '../data/invoices_service.dart';
import '../models/invoice_model.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {

  late Future<List<Invoice>> _futureInvoices;

  @override
  void initState() {
    super.initState();
    _futureInvoices = InvoicesService().getInvoices();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Facturas"),
      ),

      body: FutureBuilder<List<Invoice>>(
        future: _futureInvoices,

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Error cargando facturas"),
            );
          }

          final invoices = snapshot.data!;

          if (invoices.isEmpty) {
            return const Center(
              child: Text("No hay facturas"),
            );
          }

          return ListView.builder(
            itemCount: invoices.length,

            itemBuilder: (context, index) {

              final invoice = invoices[index];

              return ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text("Factura #${invoice.id}"),
                subtitle: Text(invoice.cliente),
                trailing: Text("\$${invoice.total}"),
              );
            },
          );
        },
      ),
    );
  }
}