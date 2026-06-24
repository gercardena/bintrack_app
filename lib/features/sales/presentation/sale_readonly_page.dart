import 'package:flutter/material.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_section_title.dart';

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

  String precio(double valor) {
    return valor.toStringAsFixed(0);
  }

  Widget filaTotal(
    String etiqueta,
    double valor, {
    bool destacado = false,
  }) {
    final style = TextStyle(
      fontWeight: destacado
          ? FontWeight.bold
          : FontWeight.normal,
      fontSize: destacado ? 18 : 14,
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
          "\$${precio(valor)}",
          style: style,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSale = sale;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentSale == null
              ? "Detalle de venta"
              : "Venta #${currentSale.numero}",
        ),
      ),
      body: loading
          ? const AppLoader()
          : currentSale == null
              ? const Center(
                  child: Text(
                    "No se pudo cargar la venta",
                  ),
                )
              : RefreshIndicator(
                  onRefresh: cargarVenta,
                  child: ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(
                      AppSpacing.screenPadding,
                    ),
                    children: [
                      const AppSectionTitle(
                        title: "Información",
                      ),
                      const SizedBox(
                        height: AppSpacing.sm,
                      ),
                      AppCard(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Cliente: "
                              "${currentSale.clienteNombre ?? "Sin cliente"}",
                            ),
                            const SizedBox(
                              height: AppSpacing.sm,
                            ),
                            Text(
                              "Estado: "
                              "${etiquetaEstado(currentSale.estado)}",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: AppSpacing.xl,
                      ),
                      const AppSectionTitle(
                        title: "Artículos",
                      ),
                      const SizedBox(
                        height: AppSpacing.sm,
                      ),
                      if (currentSale.items.isEmpty)
                        const AppCard(
                          child: Text(
                            "La venta no tiene artículos.",
                          ),
                        )
                      else
                        ...currentSale.items.map(
                          (item) => Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom:
                                  AppSpacing.sm,
                            ),
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    "${item.productNombre} + "
                                    "${item.binNombre}",
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height:
                                        AppSpacing.sm,
                                  ),
                                  Text(
                                    "Cantidad: "
                                    "${item.cantidad}",
                                  ),
                                  Text(
                                    "Precio unitario: "
                                    "\$${precio(item.precioUnitario)}",
                                  ),
                                  Text(
                                    "Subtotal: "
                                    "\$${precio(item.subtotal)}",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(
                        height: AppSpacing.lg,
                      ),
                      AppCard(
                        child: Column(
                          children: [
                            filaTotal(
                              "Subtotal",
                              currentSale.subtotal,
                            ),
                            const SizedBox(
                              height: AppSpacing.sm,
                            ),
                            filaTotal(
                              "IVA",
                              currentSale.iva,
                            ),
                            const Divider(),
                            filaTotal(
                              "Total",
                              currentSale.total,
                              destacado: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}