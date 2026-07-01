import 'package:flutter/material.dart';

import '../../products/data/models/product_presentation_model.dart';
import '../../products/data/product_presentations_service.dart';

import '../data/models/sale_model.dart';
import '../data/services/sale_service.dart';

class SaleDetailPage extends StatefulWidget {
  final int saleId;

  const SaleDetailPage({
    super.key,
    required this.saleId,
  });

  @override
  State<SaleDetailPage> createState() =>
      _SaleDetailPageState();
}

class _SaleDetailPageState extends State<SaleDetailPage> {
  final SalesService _salesService = SalesService();

  final ProductPresentationsService _presentationsService =
      ProductPresentationsService();

  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);

  final TextEditingController cantidadController =
      TextEditingController();

  List<ProductPresentation> presentations = [];

  ProductPresentation? presentationSeleccionada;
  Sale? venta;

  bool loading = true;
  bool saving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final presentationsData =
          await _presentationsService.getAll();

      final saleData = await _salesService.getSale(
        widget.saleId,
      );

      if (!mounted) return;

      setState(() {
        presentations = presentationsData
            .where(
              (presentation) =>
                  presentation.activo &&
                  presentation.stockCantidad > 0,
            )
            .toList();

        venta = saleData;
        loading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> recargarVenta() async {
    final saleData = await _salesService.getSale(
      widget.saleId,
    );

    if (!mounted) return;

    setState(() {
      venta = saleData;
    });
  }

  Future<void> agregarItem() async {
    final presentation = presentationSeleccionada;

    if (presentation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Selecciona un producto y envase.",
          ),
        ),
      );

      return;
    }

    final cantidad = int.tryParse(
      cantidadController.text.trim(),
    );

    if (cantidad == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Ingresa una cantidad válida mayor que cero.",
          ),
        ),
      );

      return;
    }

    if (cantidad > presentation.stockCantidad) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Solo hay ${presentation.stockCantidad} "
            "envases llenos disponibles para esta presentación.",
          ),
        ),
      );

      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await _salesService.addItemToSale(
        saleId: widget.saleId,
        productId: presentation.productId,
        binId: presentation.binTypeId,
        cantidad: cantidad,
      );

      await recargarVenta();

      if (!mounted) return;

      cantidadController.clear();

      setState(() {
        presentationSeleccionada = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Producto agregado correctamente.",
          ),
        ),
      );
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
          saving = false;
        });
      }
    }
  }

  Future<void> confirmarVenta() async {
    final currentSale = venta;

    if (currentSale == null ||
        currentSale.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Agrega al menos un producto antes de confirmar.",
          ),
        ),
      );

      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Confirmar venta",
          ),
          content: Text(
            "Al confirmar se descontará el stock lleno "
            "y se registrarán los envases entregados al cliente.\n\n"
            "Total: \$${precioFormateado(currentSale.total)}",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Volver"),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    setState(() {
      saving = true;
    });

    try {
      await _salesService.confirmSale(
        widget.saleId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Venta confirmada correctamente.",
          ),
        ),
      );

      Navigator.pop(context, true);
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
          saving = false;
        });
      }
    }
  }

  String precioFormateado(double precio) {
    return precio.toStringAsFixed(0);
  }

  @override
  void dispose() {
    cantidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSale = venta;

    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.06),
          labelStyle: const TextStyle(
            color: Colors.white70,
          ),
          hintStyle: const TextStyle(
            color: Colors.white38,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.blueAccent,
            ),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: Text(
            "Venta #${currentSale?.numero ?? widget.saleId}",
          ),
          centerTitle: true,
          backgroundColor: background,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : errorMessage != null
                ? _errorState()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _headerCard(),

                        const SizedBox(height: 16),

                        _sectionCard(
                          title: "Agregar producto",
                          icon: Icons.add_shopping_cart,
                          color: Colors.blueAccent,
                          children: [
                            _productSelector(),
                            const SizedBox(height: 12),
                            _quantityField(),
                            const SizedBox(height: 12),
                            _smallHelp(
                              "La cantidad corresponde a envases llenos "
                              "de la presentación seleccionada.",
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: saving ||
                                        presentations.isEmpty
                                    ? null
                                    : agregarItem,
                                icon: saving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.add),
                                label: const Text(
                                  "Agregar producto",
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        _sectionTitle(
                          "Artículos de la venta",
                          "Productos agregados al borrador.",
                        ),

                        const SizedBox(height: 10),

                        construirArticulos(),

                        const SizedBox(height: 16),

                        construirTotales(),

                        const SizedBox(height: 22),

                        _confirmCard(),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _headerCard() {
    final currentSale = venta;

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
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.point_of_sale,
            color: Colors.white,
            size: 34,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "Venta #${currentSale?.numero ?? widget.saleId}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  currentSale?.clienteNombre ??
                      "Cliente no disponible",
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Mientras esté en borrador puedes agregar productos. "
                  "Al confirmar se descuenta stock y se registran envases.",
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.3,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _productSelector() {
    if (presentations.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.orange.withValues(alpha: 0.35),
          ),
        ),
        child: const Text(
          "No hay presentaciones activas con stock disponible.",
          style: TextStyle(
            color: Colors.white,
            height: 1.35,
          ),
        ),
      );
    }

    return DropdownButtonFormField<ProductPresentation>(
      initialValue: presentationSeleccionada,
      isExpanded: true,
      dropdownColor: card,
      style: const TextStyle(
        color: Colors.white,
      ),
      items: presentations.map(
        (presentation) {
          return DropdownMenuItem<ProductPresentation>(
            value: presentation,
            child: Text(
              "${presentation.productNombre} + "
              "${presentation.binNombre} - "
              "\$${precioFormateado(presentation.precio)} "
              "(Stock: ${presentation.stockCantidad})",
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ).toList(),
      onChanged: saving
          ? null
          : (value) {
              setState(() {
                presentationSeleccionada = value;
              });
            },
      decoration: const InputDecoration(
        labelText: "Producto y envase",
      ),
    );
  }

  Widget _quantityField() {
    return TextField(
      controller: cantidadController,
      style: const TextStyle(
        color: Colors.white,
      ),
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Cantidad",
        hintText: "Ej: 1",
      ),
    );
  }

  Widget construirArticulos() {
    final items = venta?.items ?? [];

    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: const Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.white54,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Todavía no se han agregado productos.",
                style: TextStyle(
                  color: Colors.white70,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: items.map(_itemCard).toList(),
    );
  }

  Widget _itemCard(SaleItem item) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.cyanAccent.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            "${item.productNombre} + ${item.binNombre}",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _miniMetric(
                label: "Cantidad",
                value: "${item.cantidad}",
                color: Colors.cyanAccent,
              ),
              const SizedBox(width: 10),
              _miniMetric(
                label: "Precio unit.",
                value:
                    "\$${precioFormateado(item.precioUnitario)}",
                color: Colors.greenAccent,
              ),
            ],
          ),

          const SizedBox(height: 10),

          _infoLine(
            Icons.attach_money,
            "Subtotal: \$${precioFormateado(item.subtotal)}",
          ),
        ],
      ),
    );
  }

  Widget construirTotales() {
    final currentSale = venta;

    if (currentSale == null ||
        currentSale.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.greenAccent.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        children: [
          filaTotal(
            "Subtotal",
            currentSale.subtotal,
          ),
          const SizedBox(height: 8),
          filaTotal(
            "IVA",
            currentSale.iva,
          ),
          const Divider(
            height: 24,
            color: Colors.white24,
          ),
          filaTotal(
            "Total",
            currentSale.total,
            destacado: true,
          ),
        ],
      ),
    );
  }

  Widget filaTotal(
    String etiqueta,
    double valor, {
    bool destacado = false,
  }) {
    final style = TextStyle(
      color: destacado
          ? Colors.greenAccent
          : Colors.white70,
      fontWeight:
          destacado ? FontWeight.bold : FontWeight.normal,
      fontSize: destacado ? 19 : 14,
    );

    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          etiqueta,
          style: style,
        ),
        Text(
          "\$${precioFormateado(valor)}",
          style: style,
        ),
      ],
    );
  }

  Widget _confirmCard() {
    final currentSale = venta;
    final hasItems = currentSale != null &&
        currentSale.items.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber,
                color: Colors.orangeAccent,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Confirmar la venta descontará stock lleno "
                  "y registrará envases entregados al cliente.",
                  style: TextStyle(
                    color: Colors.white,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: saving || !hasItems
                  ? null
                  : confirmarVenta,
              icon: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_circle),
              label: const Text("Confirmar venta"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white60,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _smallHelp(String text) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.info_outline,
          size: 18,
          color: Colors.white54,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white60,
              height: 1.3,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniMetric({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.22),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoLine(
    IconData icon,
    String text,
  ) {
    return Row(
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
            style: const TextStyle(
              color: Colors.white70,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }

  Widget _errorState() {
    return ListView(
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
            "No pudimos cargar la venta",
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
      ],
    );
  }
}