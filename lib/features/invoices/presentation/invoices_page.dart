import 'package:flutter/material.dart';

import '../data/invoices_service.dart';
import '../models/invoice_model.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() =>
      _InvoicesPageState();
}

class _InvoicesPageState
    extends State<InvoicesPage> {
  final InvoicesService service =
      InvoicesService();

  late Future<List<Invoice>> futureInvoices;

  @override
  void initState() {
    super.initState();
    futureInvoices = service.getInvoices();
  }

  Future<void> recargar() async {
    setState(() {
      futureInvoices = service.getInvoices();
    });

    await futureInvoices;
  }

  String estadoVenta(String estado) {
    switch (estado) {
      case "confirmed":
        return "Confirmada";
      case "paid":
        return "Pagada";
      case "cancelled":
        return "Cancelada";
      default:
        return estado;
    }
  }

  String formatearMonto(double monto) {
    return monto.toStringAsFixed(0);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Facturas"),
      ),
      body: FutureBuilder<List<Invoice>>(
        future: futureInvoices,
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

          final invoices =
              snapshot.data ?? [];

          if (invoices.isEmpty) {
            return RefreshIndicator(
              onRefresh: recargar,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Center(
                    child: Text(
                      "No hay facturas emitidas",
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
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice =
                    invoices[index];

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets
                                      .all(12),
                              decoration:
                                  BoxDecoration(
                                color: Colors
                                    .deepPurple
                                    .withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(10),
                              ),
                              child: const Icon(
                                Icons.receipt_long,
                                color: Colors
                                    .deepPurple,
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    "Factura "
                                    "#${invoice.numero}",
                                    style:
                                        const TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                  Text(
                                    "Venta "
                                    "#${invoice.saleNumero}",
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "\$${formatearMonto(invoice.total)}",
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
                        const Divider(height: 24),
                        Text(
                          invoice.clienteNombre,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        Text(
                          "RUT: ${invoice.clienteRut}",
                        ),
                        if (invoice
                                .clienteDireccion
                                ?.isNotEmpty ==
                            true)
                          Text(
                            invoice
                                .clienteDireccion!,
                          ),
                        const SizedBox(height: 8),
                        Text(
                          "Estado venta: "
                          "${estadoVenta(invoice.saleEstado)}",
                        ),
                        Text(
                          "Subtotal: "
                          "\$${formatearMonto(invoice.subtotal)}",
                        ),
                        Text(
                          "IVA: "
                          "\$${formatearMonto(invoice.iva)}",
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Emitida: "
                          "${formatearFecha(invoice.fechaEmision)}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
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