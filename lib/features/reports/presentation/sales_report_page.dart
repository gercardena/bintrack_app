import 'package:flutter/material.dart';

import '../data/sales_report_service.dart';
import '../models/sales_report_model.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() =>
      _SalesReportPageState();
}

class _SalesReportPageState
    extends State<SalesReportPage> {
  final SalesReportService service =
      SalesReportService();

  String selectedPeriodo = "semana";

  late Future<SalesReport> futureReport;

  @override
  void initState() {
    super.initState();
    futureReport = service.getReport(
      periodo: selectedPeriodo,
    );
  }

  void cambiarPeriodo(String periodo) {
    setState(() {
      selectedPeriodo = periodo;
      futureReport = service.getReport(
        periodo: selectedPeriodo,
      );
    });
  }

  Future<void> recargar() async {
    setState(() {
      futureReport = service.getReport(
        periodo: selectedPeriodo,
      );
    });

    await futureReport;
  }

  String tituloPeriodo(String periodo) {
    switch (periodo) {
      case "hoy":
        return "Hoy";
      case "mes":
        return "Mes";
      case "semana":
      default:
        return "Semana";
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

    return "$day/$month/${local.year}";
  }

  Color tipoColor(String tipo) {
    if (tipo == "contado") {
      return Colors.greenAccent;
    }

    return Colors.amber;
  }

  String tipoLabel(String tipo) {
    if (tipo == "contado") {
      return "Contado / pagado";
    }

    return "Crédito / pendiente";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101827),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("Reporte de ventas"),
      ),
      body: FutureBuilder<SalesReport>(
        future: futureReport,
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

          final report = snapshot.data;

          if (report == null) {
            return _emptyState();
          }

          return RefreshIndicator(
            onRefresh: recargar,
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _periodSelector(),
                const SizedBox(height: 14),
                _summaryCard(report),
                const SizedBox(height: 12),
                _totalsGrid(report),
                const SizedBox(height: 18),
                _sectionTitle(report),
                const SizedBox(height: 12),
                if (report.ventas.isEmpty)
                  _emptyReportCard()
                else
                  ...report.ventas.map(_saleCard),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _periodSelector() {
    return Row(
      children: [
        _periodButton("hoy"),
        const SizedBox(width: 8),
        _periodButton("semana"),
        const SizedBox(width: 8),
        _periodButton("mes"),
      ],
    );
  }

  Widget _periodButton(String periodo) {
    final selected = selectedPeriodo == periodo;

    return Expanded(
      child: ChoiceChip(
        selected: selected,
        label: Text(tituloPeriodo(periodo)),
        onSelected: (_) => cambiarPeriodo(periodo),
        selectedColor: Colors.cyanAccent.withValues(
          alpha: 0.24,
        ),
        backgroundColor: const Color(0xFF172033),
        labelStyle: TextStyle(
          color: selected
              ? Colors.cyanAccent
              : Colors.white70,
          fontWeight:
              selected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: selected
              ? Colors.cyanAccent.withValues(alpha: 0.65)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
    );
  }

  Widget _summaryCard(SalesReport report) {
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
              Icons.analytics_outlined,
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
                Text(
                  "Reporte ${tituloPeriodo(report.periodo)}",
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${formatearMonto(report.totalVendido)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${formatearFecha(report.desde)} - "
                  "${formatearFecha(report.hasta)}",
                  style: const TextStyle(
                    color: Colors.white60,
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

  Widget _totalsGrid(SalesReport report) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _metricCard(
                title: "Contado / pagado",
                value:
                    "\$${formatearMonto(report.totalContado)}",
                subtitle:
                    "Clientes pagados: ${report.cantidadClientesPagados}",
                color: Colors.greenAccent,
                icon: Icons.payments_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                title: "Crédito / pendiente",
                value:
                    "\$${formatearMonto(report.totalCredito)}",
                subtitle:
                    "Clientes deben: ${report.cantidadClientesCredito}",
                color: Colors.amber,
                icon: Icons.pending_actions_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                title: "Ventas",
                value: report.cantidadVentas.toString(),
                subtitle:
                    "Pagadas: ${report.cantidadVentasContado}",
                color: Colors.lightBlueAccent,
                icon: Icons.receipt_long_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                title: "Pendientes",
                value:
                    report.cantidadVentasCredito.toString(),
                subtitle: "Ventas por cobrar",
                color: Colors.orangeAccent,
                icon: Icons.warning_amber_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF172033),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(SalesReport report) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.list_alt_outlined,
          color: Colors.cyanAccent,
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                "Ventas del período",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                "${report.cantidadVentas} venta(s) "
                "entre contado y crédito.",
                style: const TextStyle(
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

  Widget _saleCard(SalesReportSale sale) {
    final color = tipoColor(sale.tipoReporte);

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
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  sale.esContado
                      ? Icons.check_circle_outline
                      : Icons.schedule_outlined,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale.clienteNombre,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "${sale.numero} · ${formatearFecha(sale.fecha)}",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "\$${formatearMonto(sale.total)}",
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              tipoLabel(sale.tipoReporte),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (sale.items.isNotEmpty) ...[
            const Divider(
              color: Colors.white12,
              height: 22,
            ),
            ...sale.items.map(_saleItemLine),
          ],
        ],
      ),
    );
  }

  Widget _saleItemLine(SalesReportItem item) {
    final cantidad = item.esPorKilo
        ? "${item.binsCantidad} envase(s) · "
            "${item.kilosPesados?.toStringAsFixed(2) ?? "0.00"} kg"
        : "${item.cantidad} envase(s)";

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.circle,
            size: 7,
            color: Colors.white38,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "${item.productNombre} / ${item.binNombre} · $cantidad",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyReportCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF172033),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.analytics_outlined,
            color: Colors.white38,
            size: 44,
          ),
          SizedBox(height: 12),
          Text(
            "No hay ventas en este período",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Cuando existan ventas pagadas o pendientes, aparecerán en este reporte.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white60,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Text(
        "No hay información de reporte.",
        style: TextStyle(
          color: Colors.white70,
        ),
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
              "No se pudo cargar el reporte",
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