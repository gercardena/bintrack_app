import 'package:flutter/material.dart';

import '../data/payments_service.dart';
import '../models/payment_model.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {

  late Future<List<Payment>> _futurePayments;

  @override
  void initState() {
    super.initState();
    _futurePayments = PaymentsService().getPayments();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Pagos"),
        elevation: 0,
      ),

      body: FutureBuilder<List<Payment>>(
        future: _futurePayments,

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Error cargando pagos"),
            );
          }

          final payments = snapshot.data!;

          if (payments.isEmpty) {
            return const Center(
              child: Text("No hay pagos registrados"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: payments.length,

            itemBuilder: (context, index) {

              final payment = payments[index];

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

                      // 🟢 ICONO
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.payments,
                          color: Colors.green,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 📄 INFO
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              "Pago #${payment.id}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "Factura: ${payment.factura}",
                              style: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "Fecha: ${payment.fecha ?? '---'}",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),

                          ],
                        ),
                      ),

                      // 💰 MONTO
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [

                          Text(
                            "\$${payment.monto}",
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