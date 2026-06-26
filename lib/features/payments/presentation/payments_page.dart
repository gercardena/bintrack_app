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

  IconData iconoMetodo(String metodo) {
    switch (metodo) {
      case "efectivo":
        return Icons.payments_outlined;
      case "transferencia":
        return Icons.account_balance_outlined;
      case "tarjeta":
        return Icons.credit_card;
      default:
        return Icons.receipt_long_outlined;
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

  double totalPagado(List<Payment> payments) {
    return payments.fold<double>(
      0,
      (total, payment) => total + payment.monto,
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
            return _errorState(
              snapshot.error.toString(),
            );
          }

          final payments =
              snapshot.data ?? [];

          if (payments.isEmpty) {
            return _emptyState();
          }

          return RefreshIndicator(
            onRefresh: recargar,
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _summaryCard(payments),
                const SizedBox(height: 18),
                _sectionTitle(),
                const SizedBox(height: 12),
                ...payments.map(_paymentCard),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _summaryCard(List<Payment> payments) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF064E3B),
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
              color: Colors.greenAccent.withValues(
                alpha: 0.16,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: Colors.greenAccent,
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
                  "Pagos registrados",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  payments.length.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Total pagado: "
                  "\$${formatearMonto(totalPagado(payments))}",
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
          Icons.receipt_long_outlined,
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
                "Historial de pagos",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 3),
              Text(
                "Pagos asociados a ventas ya registradas.",
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

  Widget _paymentCard(Payment payment) {
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
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(
                alpha: 0.14,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              iconoMetodo(payment.metodo),
              color: Colors.greenAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "Venta #${payment.saleNumero}",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  payment.clienteNombre,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                _infoLine(
                  "Método",
                  etiquetaMetodo(payment.metodo),
                ),
                if (payment.referencia?.isNotEmpty ==
                    true)
                  _infoLine(
                    "Referencia",
                    payment.referencia!,
                  ),
                _infoLine(
                  "Fecha",
                  formatearFecha(payment.fecha),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "\$${formatearMonto(payment.monto)}",
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoLine(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        "$label: $value",
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 13,
        ),
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
                  Icons.payments_outlined,
                  color: Colors.greenAccent,
                  size: 54,
                ),
                SizedBox(height: 14),
                Text(
                  "No hay pagos registrados",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Cuando registres el pago de una venta, aparecerá en este historial.",
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
              "No se pudieron cargar los pagos",
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