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

      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Facturas"),
        elevation: 0,
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
            padding: const EdgeInsets.all(12),
            itemCount: invoices.length,

            itemBuilder: (context, index) {

              final invoice = invoices[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Row(
                    children: [

                      // 🟣 ICONO
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          color: Colors.deepPurple,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 📄 INFO
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              "Factura #${invoice.id}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              invoice.cliente,
                              style: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "Fecha: ${invoice.fecha.isNotEmpty ? invoice.fecha : '---'}",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),

                          ],
                        ),
                      ),

                      // 💰 TOTAL
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [

                          Text(
                            "\$${invoice.total}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.grey[500],
                          ),

                        ],
                      )

                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}