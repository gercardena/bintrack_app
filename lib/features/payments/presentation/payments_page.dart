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
      appBar: AppBar(
        title: const Text("Pagos"),
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
            itemCount: payments.length,

            itemBuilder: (context, index) {

              final payment = payments[index];

              return ListTile(
                leading: const Icon(Icons.payments),
                title: Text("Pago #${payment.id}"),
                subtitle: Text("Factura ${payment.factura}"),
                trailing: Text("\$${payment.monto}"),
              );
            },
          );
        },
      ),
    );
  }
}
