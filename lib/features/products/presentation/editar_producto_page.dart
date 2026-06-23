import 'package:flutter/material.dart';

import '../data/products_api.dart';
import '../data/product_presentations_service.dart';
import '../data/models/product_model.dart';
import '../data/models/product_presentation_model.dart';

class EditarProductoPage extends StatefulWidget {
  final Product product;

  const EditarProductoPage({
    super.key,
    required this.product,
  });

  @override
  State<EditarProductoPage> createState() =>
      _EditarProductoPageState();
}

class _EditarProductoPageState
    extends State<EditarProductoPage> {
  final _formKey = GlobalKey<FormState>();

  final ProductPresentationsService presentationsService =
      ProductPresentationsService();

  late TextEditingController nombreCtrl;
  late TextEditingController precioCtrl;
  late TextEditingController descripcionCtrl;

  List<ProductPresentation> presentations = [];

  final Map<int, TextEditingController> stockControllers = {};
  final Map<int, TextEditingController> priceControllers = {};

  bool loading = false;
  bool loadingPresentations = true;

  int? savingStockId;
  int? savingPriceId;

  @override
  void initState() {
    super.initState();

    nombreCtrl = TextEditingController(
      text: widget.product.nombre,
    );

    // Se conserva temporalmente porque Django todavía
    // requiere el precio antiguo al actualizar Product.
    precioCtrl = TextEditingController(
      text: widget.product.precio.toString(),
    );

    descripcionCtrl = TextEditingController(
      text: widget.product.descripcion,
    );

    cargarPresentaciones();
  }

  Future<void> cargarPresentaciones() async {
    try {
      final data = await presentationsService.getByProduct(
        widget.product.id,
      );

      if (!mounted) return;

      for (final controller in stockControllers.values) {
        controller.dispose();
      }

      for (final controller in priceControllers.values) {
        controller.dispose();
      }

      stockControllers.clear();
      priceControllers.clear();

      for (final presentation in data) {
        stockControllers[presentation.id] =
            TextEditingController(
          text: presentation.stockCantidad.toString(),
        );

        priceControllers[presentation.id] =
            TextEditingController(
          text: presentation.precio.toStringAsFixed(0),
        );
      }

      setState(() {
        presentations = data;
        loadingPresentations = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingPresentations = false;
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

  Future<void> guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    final ok = await ProductsApi.actualizarProducto(
      id: widget.product.id,
      nombre: nombreCtrl.text.trim(),
      precio: precioCtrl.text.trim(),
      descripcion: descripcionCtrl.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Producto actualizado correctamente",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Error al actualizar producto",
          ),
        ),
      );
    }
  }

  Future<void> guardarPrecio(
    ProductPresentation presentation,
  ) async {
    final controller = priceControllers[presentation.id];

    final precio = double.tryParse(
      controller?.text.trim().replaceAll(",", ".") ?? "",
    );

    if (precio == null || precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Ingresa un precio válido",
          ),
        ),
      );
      return;
    }

    setState(() {
      savingPriceId = presentation.id;
    });

    try {
      await presentationsService.savePrice(
        presentation: presentation,
        precio: precio,
      );

      await cargarPresentaciones();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Precio actualizado correctamente",
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
          savingPriceId = null;
        });
      }
    }
  }

  Future<void> guardarStock(
    ProductPresentation presentation,
  ) async {
    final controller = stockControllers[presentation.id];

    final cantidad = int.tryParse(
      controller?.text.trim() ?? "",
    );

    if (cantidad == null || cantidad < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Ingresa una cantidad válida",
          ),
        ),
      );
      return;
    }

    setState(() {
      savingStockId = presentation.id;
    });

    try {
      await presentationsService.saveStock(
        presentation: presentation,
        cantidad: cantidad,
      );

      await cargarPresentaciones();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Stock actualizado correctamente",
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
          savingStockId = null;
        });
      }
    }
  }

  Future<void> eliminar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar producto"),
        content: const Text(
          "¿Seguro que quieres eliminar este producto?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() {
      loading = true;
    });

    final ok = await ProductsApi.eliminarProducto(
      widget.product.id,
    );

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Error al eliminar producto",
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    precioCtrl.dispose();
    descripcionCtrl.dispose();

    for (final controller in stockControllers.values) {
      controller.dispose();
    }

    for (final controller in priceControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Producto"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: loading ? null : eliminar,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nombreCtrl,
              decoration: const InputDecoration(
                labelText: "Nombre",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? "Requerido"
                      : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descripcionCtrl,
              decoration: const InputDecoration(
                labelText: "Descripción",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loading ? null : guardarProducto,
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    )
                  : const Text("Guardar producto"),
            ),
            const SizedBox(height: 32),
            Text(
              "Presentaciones, precios y stock",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (loadingPresentations)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (presentations.isEmpty)
              const Text(
                "Este producto no tiene presentaciones.",
              )
            else
              ...presentations.map(
                (presentation) => Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          presentation.binNombre,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: priceControllers[
                              presentation.id],
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText:
                                "Precio de esta presentación",
                            prefixText: "\$",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: savingPriceId ==
                                    presentation.id
                                ? null
                                : () => guardarPrecio(
                                      presentation,
                                    ),
                            child: savingPriceId ==
                                    presentation.id
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                        CircularProgressIndicator(),
                                  )
                                : const Text(
                                    "Actualizar precio",
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: stockControllers[
                              presentation.id],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText:
                                "Stock de envases llenos",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: savingStockId ==
                                    presentation.id
                                ? null
                                : () => guardarStock(
                                      presentation,
                                    ),
                            child: savingStockId ==
                                    presentation.id
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                        CircularProgressIndicator(),
                                  )
                                : const Text(
                                    "Actualizar stock",
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}