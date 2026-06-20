import 'package:flutter/material.dart';

import '../../../core/theme/spacing.dart';

import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_section_title.dart';

import '../data/services/sale_service.dart';

import '../../products/data/products_service.dart';

import '../../warehouses/data/services/bin_type_service.dart';
import '../../warehouses/data/models/bin_type_model.dart';

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

class _SaleDetailPageState
    extends State<SaleDetailPage> {

  final ProductsService _productsService =
      ProductsService();

  final SalesService _salesService =
      SalesService();

  final BinTypeService _binTypeService =
      BinTypeService();

  List<Product> productos = [];

  List<BinType> bins = [];

  Product? productoSeleccionado;

  BinType? binSeleccionado;

  final TextEditingController cantidadController =
      TextEditingController();

  bool loading = true;

  bool saving = false;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  // =========================================
  // 🔥 CARGAR DATOS
  // =========================================

  Future<void> cargarDatos() async {

    try {

      final productosData =
          await _productsService.getProducts();

      final binsData =
          await _binTypeService.getBinTypes();

      if (!mounted) return;

      setState(() {

        productos = productosData;

        bins = binsData;

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

  // =========================================
  // 🔥 AGREGAR ITEM
  // =========================================

  Future<void> agregarItem() async {

    if (productoSeleccionado == null) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text(
            "Selecciona un producto",
          ),
        ),
      );

      return;
    }

    if (binSeleccionado == null) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text(
            "Selecciona un BIN",
          ),
        ),
      );

      return;
    }

    if (cantidadController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text(
            "Ingresa cantidad",
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

        productId: productoSeleccionado!.id,

        binId: binSeleccionado!.id,

        cantidad: int.parse(
          cantidadController.text,
        ),

        precio: double.parse(
          productoSeleccionado!.precio.toString(),
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text(
            "Item agregado correctamente",
          ),
        ),
      );

      cantidadController.clear();

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text(
            e.toString(),
          ),
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

  // =========================================
  // 🔥 CONFIRMAR VENTA
  // =========================================

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
          content: Text(
            e.toString(),
          ),
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

  @override
  void dispose() {

    cantidadController.dispose();

    super.dispose();
  }

  // =========================================
  // 🔥 UI
  // =========================================

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

                  // =====================================
                  // PRODUCTO
                  // =====================================

                  const AppSectionTitle(
                    title: "Producto",
                  ),

                  const SizedBox(
                    height: AppSpacing.sm,
                  ),

                  AppCard(

                    child: DropdownButtonFormField<Product>(

                      value: productoSeleccionado,

                      items: productos.map((producto) {

                        return DropdownMenuItem<Product>(

                          value: producto,

                          child: Text(
                            "${producto.nombre} - \$${producto.precio}",
                          ),
                        );

                      }).toList(),

                      onChanged: (value) {

                        setState(() {
                          productoSeleccionado = value;
                        });
                      },

                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: AppSpacing.lg,
                  ),

                  // =====================================
                  // BIN
                  // =====================================

                  const AppSectionTitle(
                    title: "BIN",
                  ),

                  const SizedBox(
                    height: AppSpacing.sm,
                  ),

                  AppCard(

                    child: DropdownButtonFormField<BinType>(

                      value: binSeleccionado,

                      items:
                          bins.map<DropdownMenuItem<BinType>>((bin) {

                        return DropdownMenuItem<BinType>(

                          value: bin,

                          child: Text(
                            bin.nombre,
                          ),
                        );

                      }).toList(),

                      onChanged: (value) {

                        setState(() {
                          binSeleccionado = value;
                        });
                      },

                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: AppSpacing.lg,
                  ),

                  // =====================================
                  // CANTIDAD Y ACCIONES
                  // =====================================

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

                          controller: cantidadController,

                          label: "Cantidad",

                          keyboardType:
                              TextInputType.number,
                        ),

                        const SizedBox(
                          height: AppSpacing.xl,
                        ),

                        // ===============================
                        // BOTON AGREGAR ITEM
                        // ===============================

                        PrimaryButton(

                          text: "Agregar Item",

                          loading: saving,

                          onPressed: agregarItem,
                        ),

                        const SizedBox(
                          height: AppSpacing.md,
                        ),

                        // ===============================
                        // BOTON CONFIRMAR
                        // ===============================

                        PrimaryButton(

                          text: "Confirmar Venta",

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