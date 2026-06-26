import 'package:flutter/material.dart';

import '../data/models/sale_model.dart';
import '../data/services/sale_service.dart';

class SaleReadonlyPage extends StatefulWidget {
  final int saleId;

  const SaleReadonlyPage({
    super.key,
    required this.saleId,
  });

  @override
  State<SaleReadonlyPage> createState() =>
      _SaleReadonlyPageState();
}

class _SaleReadonlyPageState
    extends State<SaleReadonlyPage> {
  final SalesService _service = SalesService();

  Sale? sale;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarVenta();
  }

  Future<void> cargarVenta() async {
    try {
      final data = await _service.getSale(
        widget.saleId,
      );

      if (!mounted) return;

      setState(() {
        sale = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
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

  Color estadoColor(String estado) {
    switch (estado) {
      case "draft":
        return Colors.amber;
      case "confirmed":
        return Colors.lightBlueAccent;
      case "paid":
        return Colors.greenAccent;
      case "cancelled":
        return Colors.redAccent;
      default:
        return Colors.white70;
    }
  }

  IconData estadoIcon(String estado) {
    switch (estado) {
      case "draft":
        return Icons.edit_note;
      case "confirmed":
        return Icons.check_circle_outline;
      case "paid":
        return Icons.payments_outlined;
      case "cancelled":
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String descripcionEstado(String estado) {
    switch (estado) {
      case "draft":
        return "Esta venta todavía está en borrador.";
      case "confirmed":
        return "Venta confirmada. El stock ya fue descontado.";
      case "paid":
        return "Venta pagada. Puede tener factura asociada.";
      case "cancelled":
        return "Venta cancelada. No se puede modificar.";
      default:
        return "Estado de venta.";
    }
  }

  String precio(double valor) {
    return valor.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final currentSale = sale;

    return Scaffold(
      backgroundColor: const Color(0xFF101827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101827),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          currentSale == null
              ? "Detalle de venta"
              : "Venta #${currentSale.numero}",
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : currentSale == null
              ? _errorState()
              : RefreshIndicator(
                  onRefresh: cargarVenta,
                  child: ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      _headerCard(currentSale),
                      const SizedBox(height: 18),
                      _sectionTitle(
                        icon: Icons.shopping_bag_outlined,
                        title: "Artículos vendidos",
                        subtitle:
                            "Detalle de productos y envases usados.",
                      ),
                      const SizedBox(height: 12),
                      if (currentSale.items.isEmpty)
                        _emptyItemsCard()
                      else
                        ...currentSale.items.map(
                          _itemCard,
                        ),
                      const SizedBox(height: 18),
                      _totalsCard(currentSale),
                      const SizedBox(height: 18),
                      _readonlyNote(currentSale),
                    ],
                  ),
                ),
    );
  }

  Widget _headerCard(Sale currentSale) {
    final color = estadoColor(currentSale.estado);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E293B),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    color.withValues(alpha: 0.18),
                child: Icon(
                  estadoIcon(currentSale.estado),
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
                      "Venta #${currentSale.numero}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentSale.clienteNombre ??
                          "Sin cliente",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: color.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  estadoIcon(currentSale.estado),
                  color: color,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  etiquetaEstado(currentSale.estado),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            descripcionEstado(currentSale.estado),
            style: const TextStyle(
              color: Colors.white70,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.cyanAccent,
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
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

  Widget _emptyItemsCard() {
    return _sectionCard(
      child: const Text(
        "Esta venta no tiene artículos registrados.",
        style: TextStyle(
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _itemCard(SaleItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _sectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${item.productNombre} + ${item.binNombre}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _infoLine(
              Icons.confirmation_number_outlined,
              "Cantidad",
              item.cantidad.toString(),
            ),
            _infoLine(
              Icons.inventory_2_outlined,
              "Envases",
              item.binsCantidad.toString(),
            ),
            _infoLine(
              Icons.sell_outlined,
              "Precio unitario",
              "\$${precio(item.precioUnitario)}",
            ),
            const Divider(
              color: Colors.white12,
              height: 22,
            ),
            _infoLine(
              Icons.attach_money,
              "Subtotal",
              "\$${precio(item.subtotal)}",
              strong: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalsCard(Sale currentSale) {
    return _sectionCard(
      child: Column(
        children: [
          _totalRow(
            "Subtotal",
            currentSale.subtotal,
          ),
          const SizedBox(height: 10),
          _totalRow(
            "IVA",
            currentSale.iva,
          ),
          const Divider(
            color: Colors.white12,
            height: 24,
          ),
          _totalRow(
            "Total",
            currentSale.total,
            highlighted: true,
          ),
        ],
      ),
    );
  }

  Widget _readonlyNote(Sale currentSale) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline,
            color: Colors.white60,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              currentSale.estado == "cancelled"
                  ? "Esta venta está cancelada y se muestra solo como historial."
                  : "Esta vista es solo de lectura. Para modificar una venta debe estar en borrador.",
              style: const TextStyle(
                color: Colors.white70,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF172033),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: child,
    );
  }

  Widget _infoLine(
    IconData icon,
    String label,
    String value, {
    bool strong = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white38,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontWeight:
                    strong ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(
    String label,
    double value, {
    bool highlighted = false,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: highlighted
                ? Colors.white
                : Colors.white70,
            fontSize: highlighted ? 18 : 14,
            fontWeight: highlighted
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        Text(
          "\$${precio(value)}",
          style: TextStyle(
            color: highlighted
                ? Colors.greenAccent
                : Colors.white,
            fontSize: highlighted ? 20 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _errorState() {
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
              "No se pudo cargar la venta",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Intenta volver atrás y abrirla nuevamente.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: cargarVenta,
              icon: const Icon(Icons.refresh),
              label: const Text("Reintentar"),
            ),
          ],
        ),
      ),
    );
  }
}