import 'package:flutter/material.dart';

import '../data/payments_service.dart';
import '../models/payment_model.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() =>
      _PaymentsPageState();
}

class _PaymentsPageState
    extends State<PaymentsPage> {
  final PaymentsService service =
      PaymentsService();

  late Future<List<Payment>> futurePayments;

  @override
  void initState() {
    super.initState();
    futurePayments = service.getPayments();
  }

  Future<void> recargar() async {
    setState(() {
      futurePayments = service.getPayments();
    });

    await futurePayments;
  }

  String etiquetaMetodo(String metodo) {
    switch (metodo) {
      case "efectivo":
        return "Efectivo";
      case "transferencia":
        return "Transferencia";
      case "tarjeta":
        return "Tarjeta";
      default:
        return metodo;
    }
  }

  String formatearFecha(String value) {
    final date = DateTime.tryParse(value);

    if (date == null) return value;

    final local = date.toLocal();

    final day =
        local.day.toString().padLeft(2, "0");
    final month =
        local.month.toString().padLeft(2, "0");
    final hour =
        local.hour.toString().padLeft(2, "0");
    final minute =
        local.minute.toString().padLeft(2, "0");

    return "$day/$month/${local.year} "
        "$hour:$minute";
  }

  String formatearMonto(double monto) {
    return monto.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Pagos"),
      ),
      body: FutureBuilder<List<Payment>>(
        future: futurePayments,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final payments =
              snapshot.data ?? [];

          if (payments.isEmpty) {
            return RefreshIndicator(
              onRefresh: recargar,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Center(
                    child: Text(
                      "No hay pagos registrados",
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: recargar,
            child: ListView.builder(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final payment =
                    payments[index];

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.all(
                            12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green
                                .withValues(
                              alpha: 0.1,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                          ),
                          child: const Icon(
                            Icons.payments,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                "Venta "
                                "#${payment.saleNumero}",
                                style:
                                    const TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Text(
                                payment
                                    .clienteNombre,
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                etiquetaMetodo(
                                  payment.metodo,
                                ),
                              ),
                              if (payment
                                      .referencia
                                      ?.isNotEmpty ==
                                  true) ...[
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  "Referencia: "
                                  "${payment.referencia}",
                                ),
                              ],
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                formatearFecha(
                                  payment.fecha,
                                ),
                                style: TextStyle(
                                  color:
                                      Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "\$${formatearMonto(payment.monto)}",
                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}