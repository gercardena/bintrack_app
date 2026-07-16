import 'package:flutter/material.dart';

import '../../auth/presentation/protected_page.dart';

import '../data/models/sale_model.dart';
import '../data/models/sales_dashboard_model.dart';
import '../data/services/sale_service.dart';

import 'create_sale_page.dart';
import 'sale_detail_page.dart';
import 'sale_readonly_page.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() =>
      _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final SalesService _service = SalesService();

  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);

  List<Sale> sales = [];
  SalesDashboard? dashboard;

  bool loading = true;
  String? errorMessage;
  int? processingSaleId;

  @override
  void initState() {
    super.initState();
    cargarVentas();
  }

  Future<void> cargarVentas() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final data = await _service.getSales();
      final dashboardData = await _service.getDashboard();

      if (!mounted) return;

      setState(() {
        sales = data;
        dashboard = dashboardData;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> nuevaVenta() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateSalePage(),
      ),
    );

    if (!mounted) return;

    await cargarVentas();
  }

  Future<void> abrirDetalle(Sale sale) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SaleReadonlyPage(
          saleId: sale.id,
        ),
      ),
    );

    if (!mounted) return;

    await cargarVentas();
  }

  Future<void> abrirBorrador(Sale sale) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SaleDetailPage(
          saleId: sale.id,
        ),
      ),
    );

    if (!mounted) return;

    await cargarVentas();
  }

  Future<void> eliminarBorrador(
    Sale sale,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Eliminar borrador",
          ),
          content: Text(
            "¿Quieres eliminar la venta "
            "#${sale.numero}?\n\n"
            "También se eliminarán sus artículos. "
            "Esta acción no afecta inventario porque la venta "
            "aún no fue confirmada.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text("Volver"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    setState(() {
      processingSaleId = sale.id;
    });

    try {
      await _service.deleteDraftSale(
        sale.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Borrador eliminado correctamente.",
          ),
        ),
      );

      await cargarVentas();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          processingSaleId = null;
        });
      }
    }
  }

  Future<void> cancelarVenta(Sale sale) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Cancelar venta",
          ),
          content: Text(
            "¿Quieres cancelar la venta "
            "#${sale.numero}?\n\n"
            "Se restaurará el stock y se registrará "
            "la devolución de los envases.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text("Volver"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                "Cancelar venta",
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    setState(() {
      processingSaleId = sale.id;
    });

    try {
      await _service.cancelSale(sale.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Venta cancelada correctamente.",
          ),
        ),
      );

      await cargarVentas();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          processingSaleId = null;
        });
      }
    }
  }

  Future<void> registrarPago(Sale sale) async {
    String metodoSeleccionado = "transferencia";
    String referencia = "";

    final datos = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                "Registrar pago",
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Venta #${sale.numero}",
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Monto total: "
                      "\$${precioFormateado(sale.total)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: metodoSeleccionado,
                      isExpanded: true,
                      decoration:
                          const InputDecoration(
                        labelText: "Método de pago",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "efectivo",
                          child: Text("Efectivo"),
                        ),
                        DropdownMenuItem(
                          value: "transferencia",
                          child: Text("Transferencia"),
                        ),
                        DropdownMenuItem(
                          value: "tarjeta",
                          child: Text("Tarjeta"),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          metodoSeleccionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      onChanged: (value) {
                        referencia = value;
                      },
                      decoration:
                          const InputDecoration(
                        labelText: "Referencia opcional",
                        hintText: "Ej: transferencia, folio, nota",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text("Volver"),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      {
                        "metodo": metodoSeleccionado,
                        "referencia": referencia,
                      },
                    );
                  },
                  child: const Text(
                    "Registrar pago",
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (datos == null || !mounted) return;

    setState(() {
      processingSaleId = sale.id;
    });

    try {
      await _service.registerPayment(
        saleId: sale.id,
        metodo: datos["metodo"]!,
        referencia: datos["referencia"],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Pago registrado correctamente.",
          ),
        ),
      );

      await cargarVentas();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          processingSaleId = null;
        });
      }
    }
  }

  Future<void> generarFactura(Sale sale) async {
    setState(() {
      processingSaleId = sale.id;
    });

    try {
      await _service.generateInvoice(
        sale.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Comprobante generado correctamente.",
          ),
        ),
      );

      await cargarVentas();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          processingSaleId = null;
        });
      }
    }
  }

  String etiquetaEstado(String estado) {
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

  String ayudaEstado(String estado) {
    switch (estado) {
      case "draft":
        return "Puedes seguir agregando o quitando artículos.";
      case "confirmed":
        return "Stock descontado. Lista para registrar pago.";
      case "paid":
        return "Pago registrado. Puedes generar comprobante.";
      case "cancelled":
        return "Venta anulada. Stock/envases fueron restaurados.";
      default:
        return "Estado de venta.";
    }
  }

  Color estadoColor(String estado) {
    switch (estado) {
      case "draft":
        return Colors.cyanAccent;
      case "confirmed":
        return Colors.orangeAccent;
      case "paid":
        return Colors.greenAccent;
      case "cancelled":
        return Colors.redAccent;
      default:
        return Colors.blueAccent;
    }
  }

  IconData estadoIcon(String estado) {
    switch (estado) {
      case "draft":
        return Icons.edit_note;
      case "confirmed":
        return Icons.check_circle_outline;
      case "paid":
        return Icons.payments;
      case "cancelled":
        return Icons.cancel_outlined;
      default:
        return Icons.point_of_sale;
    }
  }

  String precioFormateado(double precio) {
    return precio.toStringAsFixed(0);
  }

  int get totalBorradores {
    return sales
        .where(
          (sale) => sale.estado == "draft",
        )
        .length;
  }

  int get totalConfirmadas {
    return sales
        .where(
          (sale) => sale.estado == "confirmed",
        )
        .length;
  }

  int get totalPagadas {
    return sales
        .where(
          (sale) => sale.estado == "paid",
        )
        .length;
  }

  double get totalVendido {
    return sales
        .where(
          (sale) =>
              sale.estado == "paid" ||
              sale.estado == "confirmed",
        )
        .fold(
          0,
          (sum, sale) => sum + sale.total,
        );
  }

  @override
  Widget build(BuildContext context) {
    return ProtectedPage(
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: const Text("Ventas"),
          centerTitle: true,
          backgroundColor: background,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButton:
            FloatingActionButton.extended(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          onPressed: nuevaVenta,
          icon: const Icon(Icons.add),
          label: const Text("Nueva venta"),
        ),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : errorMessage != null
                ? _errorState()
                : RefreshIndicator(
                    onRefresh: cargarVentas,
                    child: sales.isEmpty
                        ? _emptyState()
                        : ListView(
                            physics:
                                const AlwaysScrollableScrollPhysics(),
                            padding:
                                const EdgeInsets.all(16),
                            children: [
                              _introCard(),
                              const SizedBox(height: 14),
                              _summaryCard(),
                              const SizedBox(height: 14),
                              ...sales.map(
                                construirTarjeta,
                              ),
                              const SizedBox(height: 80),
                            ],
                          ),
                  ),
      ),
    );
  }

  Widget _introCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blueAccent.withValues(alpha: 0.30),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.point_of_sale,
            color: Colors.blueAccent,
            size: 30,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Gestiona el flujo de venta: borrador, confirmación, "
              "pago y comprobante. Confirmar una venta descuenta stock "
              "y registra movimiento de envases.",
              style: TextStyle(
                color: Colors.white,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1D4ED8),
            Color(0xFF0EA5E9),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Resumen de ventas",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Ingresos calculados sobre ventas pagadas.",
            style: TextStyle(
              color: Colors.white70,
              height: 1.3,
              fontSize: 12.5,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _summaryBox(
                label: "Hoy",
                value:
                "\$${precioFormateado(dashboard?.ingresosHoy ?? 0)}",
                icon: Icons.today,
                color: Colors.cyanAccent,
              ),
              const SizedBox(width: 10),
              _summaryBox(
                label: "Mes",
                value:
                "\$${precioFormateado(dashboard?.ingresosMes ?? 0)}",
                icon: Icons.calendar_month,
                color: Colors.orangeAccent,
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _summaryBox(
                label: "Pagadas",
                value: "${dashboard?.ventasPagadas ?? totalPagadas}",
                icon: Icons.payments,
                color: Colors.greenAccent,
              ),
              const SizedBox(width: 10),
              _summaryBox(
                label: "Pendientes",
                value:
                    "${dashboard?.ventasConfirmadas ?? totalConfirmadas}",
                icon: Icons.pending_actions,
                color: Colors.amberAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
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
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11.5,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget construirTarjeta(Sale sale) {
    final processing =
        processingSaleId == sale.id;

    final color = estadoColor(sale.estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.24),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    color.withValues(alpha: 0.16),
                child: Icon(
                  estadoIcon(sale.estado),
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
                      "Venta #${sale.numero}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ayudaEstado(sale.estado),
                      style: const TextStyle(
                        color: Colors.white60,
                        height: 1.25,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              _statusPill(
                text: etiquetaEstado(sale.estado),
                color: color,
              ),
            ],
          ),

          const SizedBox(height: 14),

          _infoLine(
            Icons.person_outline,
            "Cliente: ${sale.clienteNombre ?? "Sin cliente"}",
          ),

          _infoLine(
            Icons.shopping_basket_outlined,
            "Artículos: ${sale.items.length}",
          ),

          _infoLine(
            Icons.attach_money,
            "Total: \$${precioFormateado(sale.total)}",
          ),

          const SizedBox(height: 14),

          _actionButtons(
            sale: sale,
            processing: processing,
          ),

          if (sale.estado == "cancelled") ...[
            const SizedBox(height: 10),
            const Text(
              "Esta venta fue cancelada.",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionButtons({
    required Sale sale,
    required bool processing,
  }) {
    if (sale.estado == "draft") {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: processing
                  ? null
                  : () => abrirBorrador(sale),
              icon: processing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.edit),
              label: const Text("Continuar borrador"),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: processing
                  ? null
                  : () => eliminarBorrador(sale),
              icon: const Icon(Icons.delete_outline),
              label: const Text("Eliminar borrador"),
            ),
          ),
        ],
      );
    }

    if (sale.estado == "confirmed") {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: processing
                  ? null
                  : () => registrarPago(sale),
              icon: processing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.payments),
              label: const Text("Registrar pago"),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: processing
                  ? null
                  : () => cancelarVenta(sale),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text("Cancelar venta"),
            ),
          ),
          const SizedBox(height: 8),
          _detailButton(sale, processing),
        ],
      );
    }

    if (sale.estado == "paid") {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: processing
                  ? null
                  : () => generarFactura(sale),
              icon: processing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.receipt_long),
              label: const Text("Generar comprobante"),
            ),
          ),
          const SizedBox(height: 8),
          _detailButton(sale, processing),
        ],
      );
    }

    return _detailButton(sale, processing);
  }

  Widget _detailButton(
    Sale sale,
    bool processing,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed:
            processing ? null : () => abrirDetalle(sale),
        icon: const Icon(Icons.visibility_outlined),
        label: const Text("Ver detalle"),
      ),
    );
  }

  Widget _statusPill({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.30),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoLine(
    IconData icon,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white54,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 90),
        Icon(
          Icons.point_of_sale,
          size: 82,
          color: Colors.white.withValues(alpha: 0.35),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            "No hay ventas registradas",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Crea una venta para seleccionar cliente, agregar productos "
          "y luego confirmar el movimiento.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white60,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: nuevaVenta,
          icon: const Icon(Icons.add),
          label: const Text("Crear venta"),
        ),
      ],
    );
  }

  Widget _errorState() {
    return RefreshIndicator(
      onRefresh: cargarVentas,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 90),
          const Icon(
            Icons.error_outline,
            size: 72,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "No pudimos cargar las ventas",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? "",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white60,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: cargarVentas,
            icon: const Icon(Icons.refresh),
            label: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }
}