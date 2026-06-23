import 'package:flutter/material.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_section_title.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';

import '../../products/data/models/product_presentation_model.dart';
import '../../products/data/product_presentations_service.dart';

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

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    cargarPresentaciones();
  }

  Future<void> cargarPresentaciones() async {
    try {
      final data = await _presentationsService.getAll();

      if (!mounted) return;

      setState(() {
        presentations = data
            .where(
              (presentation) =>
                  presentation.activo &&
                  presentation.stockCantidad > 0,
            )
            .toList();

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
            "Error cargando presentaciones: $e",
          ),
        ),
      );
    }
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

      if (!mounted) return;

      cantidadController.clear();

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
          "Venta #${widget.saleId}",
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
                  Text(
                    "Detalle Venta #${widget.saleId}",
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium,
                  ),
                  const SizedBox(
                    height: AppSpacing.xl,
                  ),
                  const AppSectionTitle(
                    title: "Presentación",
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
                    height: AppSpacing.lg,
                  ),
                  const AppSectionTitle(
                    title: "Cantidad",
                  ),
                  const SizedBox(
                    height: AppSpacing.sm,
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
                          height: AppSpacing.xl,
                        ),
                        PrimaryButton(
                          text: "Agregar producto",
                          loading: saving,
                          onPressed:
                              presentations.isEmpty
                                  ? null
                                  : agregarItem,
                        ),
                        const SizedBox(
                          height: AppSpacing.md,
                        ),
                        PrimaryButton(
                          text: "Confirmar venta",
                          loading: saving,
                          onPressed: confirmarVenta,
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