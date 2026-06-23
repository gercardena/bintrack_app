import 'package:flutter/material.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_section_title.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';

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

  final ProductPresentationsService
      _presentationsService =
      ProductPresentationsService();

  final TextEditingController cantidadController =
      TextEditingController();

  List<ProductPresentation> presentations = [];

  ProductPresentation? presentationSeleccionada;
  Sale? venta;

  bool loading = true;
  bool saving = false;

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
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error cargando venta: $e",
          ),
        ),
      );
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
            "Selecciona una presentación",
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
            "Ingresa una cantidad válida",
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
            "unidades disponibles",
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
            "Producto agregado correctamente",
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
            "Agrega al menos un producto",
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
            "Se descontará el stock y se registrarán "
            "los envases entregados al cliente.\n\n"
            "Total: \$${precioFormateado(currentSale.total)}",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Volver"),
            ),
            ElevatedButton(
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
            "Venta confirmada correctamente",
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

  Widget construirArticulos() {
    final items = venta?.items ?? [];

    if (items.isEmpty) {
      return const AppCard(
        child: Text(
          "Todavía no se han agregado productos.",
        ),
      );
    }

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(
            bottom: AppSpacing.sm,
          ),
          child: AppCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "${item.productNombre} + "
                  "${item.binNombre}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                Text(
                  "Cantidad: ${item.cantidad}",
                ),
                Text(
                  "Precio unitario: "
                  "\$${precioFormateado(item.precioUnitario)}",
                ),
                Text(
                  "Subtotal: "
                  "\$${precioFormateado(item.subtotal)}",
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget construirTotales() {
    final currentSale = venta;

    if (currentSale == null ||
        currentSale.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppCard(
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
    );
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
          "\$${precioFormateado(valor)}",
          style: style,
        ),
      ],
    );
  }

  @override
  void dispose() {
    cantidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Venta #${venta?.numero ?? widget.saleId}",
        ),
      ),
      body: loading
          ? const AppLoader()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(
                AppSpacing.screenPadding,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const AppSectionTitle(
                    title: "Agregar producto",
                  ),
                  const SizedBox(
                    height: AppSpacing.sm,
                  ),
                  AppCard(
                    child: presentations.isEmpty
                        ? const Text(
                            "No hay presentaciones activas "
                            "con stock disponible.",
                          )
                        : DropdownButtonFormField<
                            ProductPresentation>(
                            value:
                                presentationSeleccionada,
                            isExpanded: true,
                            items: presentations.map(
                              (presentation) {
                                return DropdownMenuItem<
                                    ProductPresentation>(
                                  value: presentation,
                                  child: Text(
                                    "${presentation.productNombre} "
                                    "+ ${presentation.binNombre} "
                                    "- \$${precioFormateado(presentation.precio)} "
                                    "(Stock: ${presentation.stockCantidad})",
                                    overflow:
                                        TextOverflow.ellipsis,
                                  ),
                                );
                              },
                            ).toList(),
                            onChanged: saving
                                ? null
                                : (value) {
                                    setState(() {
                                      presentationSeleccionada =
                                          value;
                                    });
                                  },
                            decoration:
                                const InputDecoration(
                              border:
                                  OutlineInputBorder(),
                              labelText:
                                  "Producto y envase",
                            ),
                          ),
                  ),
                  const SizedBox(
                    height: AppSpacing.md,
                  ),
                  AppCard(
                    child: Column(
                      children: [
                        AppTextField(
                          controller:
                              cantidadController,
                          label: "Cantidad",
                          keyboardType:
                              TextInputType.number,
                        ),
                        const SizedBox(
                          height: AppSpacing.lg,
                        ),
                        PrimaryButton(
                          text: "Agregar producto",
                          loading: saving,
                          onPressed:
                              presentations.isEmpty
                                  ? null
                                  : agregarItem,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: AppSpacing.xl,
                  ),
                  const AppSectionTitle(
                    title: "Artículos de la venta",
                  ),
                  const SizedBox(
                    height: AppSpacing.sm,
                  ),
                  construirArticulos(),
                  const SizedBox(
                    height: AppSpacing.lg,
                  ),
                  construirTotales(),
                  const SizedBox(
                    height: AppSpacing.xl,
                  ),
                  PrimaryButton(
                    text: "Confirmar venta",
                    loading: saving,
                    onPressed: confirmarVenta,
                  ),
                ],
              ),
            ),
    );
  }
}