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
      case "draft":
        return "Borrador";
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

  Color estadoColor(String estado) {
    switch (estado) {
      case "paid":
        return Colors.greenAccent;
      case "confirmed":
        return Colors.lightBlueAccent;
      case "cancelled":
        return Colors.redAccent;
      case "draft":
        return Colors.amber;
      default:
        return Colors.white70;
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

  double totalFacturado(List<Invoice> invoices) {
    return invoices.fold<double>(
      0,
      (total, invoice) => total + invoice.total,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101827),
        foregroundColor: Colors.white,
        elevation: 0,
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
            return _errorState(
              snapshot.error.toString(),
            );
          }

          final invoices =
              snapshot.data ?? [];

          if (invoices.isEmpty) {
            return _emptyState();
          }

          return RefreshIndicator(
            onRefresh: recargar,
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _summaryCard(invoices),
                const SizedBox(height: 18),
                _sectionTitle(),
                const SizedBox(height: 12),
                ...invoices.map(_invoiceCard),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _summaryCard(List<Invoice> invoices) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF312E81),
            Color(0xFF111827),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.purpleAccent.withValues(
                alpha: 0.16,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Colors.purpleAccent,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  "Facturas emitidas",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  invoices.length.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Total facturado: "
                  "\$${formatearMonto(totalFacturado(invoices))}",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Icon(
          Icons.description_outlined,
          color: Colors.cyanAccent,
          size: 22,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                "Historial de facturación",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 3),
              Text(
                "Facturas generadas desde ventas pagadas.",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _invoiceCard(Invoice invoice) {
    final color = estadoColor(invoice.saleEstado);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF172033),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purpleAccent.withValues(
                    alpha: 0.14,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Colors.purpleAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Factura #${invoice.numero}",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Venta #${invoice.saleNumero}",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "\$${formatearMonto(invoice.total)}",
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(
            color: Colors.white12,
            height: 24,
          ),
          _infoLine(
            Icons.person_outline,
            "Cliente",
            invoice.clienteNombre,
          ),
          _infoLine(
            Icons.badge_outlined,
            "RUT",
            invoice.clienteRut,
          ),
          if (invoice.clienteDireccion?.isNotEmpty ==
              true)
            _infoLine(
              Icons.location_on_outlined,
              "Dirección",
              invoice.clienteDireccion!,
            ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: color.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              "Venta ${estadoVenta(invoice.saleEstado)}",
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _amountLine(
            "Subtotal",
            invoice.subtotal,
          ),
          _amountLine(
            "IVA",
            invoice.iva,
          ),
          const Divider(
            color: Colors.white12,
            height: 20,
          ),
          _amountLine(
            "Total",
            invoice.total,
            highlighted: true,
          ),
          const SizedBox(height: 10),
          _infoLine(
            Icons.calendar_month_outlined,
            "Emitida",
            formatearFecha(invoice.fechaEmision),
          ),
        ],
      ),
    );
  }

  Widget _infoLine(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white38,
            size: 18,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountLine(
    String label,
    double value, {
    bool highlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: highlighted
                  ? Colors.white
                  : Colors.white60,
              fontSize: highlighted ? 16 : 13,
              fontWeight: highlighted
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          Text(
            "\$${formatearMonto(value)}",
            style: TextStyle(
              color: highlighted
                  ? Colors.greenAccent
                  : Colors.white,
              fontSize: highlighted ? 17 : 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return RefreshIndicator(
      onRefresh: recargar,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF172033),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  color: Colors.purpleAccent,
                  size: 54,
                ),
                SizedBox(height: 14),
                Text(
                  "No hay facturas emitidas",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Cuando una venta pagada sea facturada, aparecerá en este historial.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 52,
            ),
            const SizedBox(height: 12),
            const Text(
              "No se pudieron cargar las facturas",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: recargar,
              icon: const Icon(Icons.refresh),
              label: const Text("Reintentar"),
            ),
          ],
        ),
      ),
    );
  }
}