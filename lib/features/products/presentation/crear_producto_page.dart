import 'package:flutter/material.dart';

import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';

import '../data/products_api.dart';
import '../data/product_presentations_service.dart';

import '../../warehouses/data/models/bin_type_model.dart';
import '../../warehouses/data/services/bin_type_service.dart';

class CrearProductoPage extends StatefulWidget {
  const CrearProductoPage({super.key});

  @override
  State<CrearProductoPage> createState() =>
      _CrearProductoPageState();
}

class _CrearProductoPageState
    extends State<CrearProductoPage> {
  final _formKey = GlobalKey<FormState>();

  final ProductsApi productsApi = ProductsApi();

  final ProductPresentationsService presentationsService =
      ProductPresentationsService();

  final BinTypeService binTypeService = BinTypeService();

  final nombreCtrl = TextEditingController();
  final precioCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  final stockCtrl = TextEditingController(text: "0");

  List<BinType> binTypes = [];
  BinType? selectedBinType;

  bool loading = false;
  bool loadingBinTypes = true;

  @override
  void initState() {
    super.initState();
    cargarTiposDeEnvase();
  }

  Future<void> cargarTiposDeEnvase() async {
    try {
      final data = await binTypeService.getBinTypes();

      if (!mounted) return;

      setState(() {
        binTypes = data;
        selectedBinType = data.isNotEmpty ? data.first : null;
        loadingBinTypes = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingBinTypes = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error cargando tipos de envase: $e",
          ),
        ),
      );
    }
  }

  Future<void> guardar() async {
    if (loading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedBinType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Selecciona un tipo de envase",
          ),
        ),
      );
      return;
    }

    final precio = double.tryParse(
      precioCtrl.text.trim().replaceAll(",", "."),
    );

    final stock = int.tryParse(
      stockCtrl.text.trim(),
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

    if (stock == null || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Ingresa un stock válido",
          ),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    int? createdProductId;

    try {
      // El precio también se guarda temporalmente en Product
      // hasta retirar el campo antiguo del backend.
      final producto = await ProductsApi.crearProducto(
        nombre: nombreCtrl.text.trim(),
        precio: precio.toStringAsFixed(2),
        descripcion: descripcionCtrl.text.trim(),
      );

      if (producto == null) {
        throw Exception(
          "No fue posible crear el producto",
        );
      }

      createdProductId = producto["id"] as int;

      final presentation =
          await presentationsService.createPresentation(
        productId: createdProductId,
        binTypeId: selectedBinType!.id,
        precio: precio,
      );

      await presentationsService.saveStock(
        presentation: presentation,
        cantidad: stock,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      // Si falla la presentación o el stock, eliminamos
      // el producto incompleto para no dejar datos huérfanos.
      if (createdProductId != null) {
        try {
          await ProductsApi.eliminarProducto(
            createdProductId,
          );
        } catch (_) {
          // El error principal se muestra debajo.
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    precioCtrl.dispose();
    descripcionCtrl.dispose();
    stockCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo Producto"),
      ),
      body: loadingBinTypes
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  AppTextField(
                    controller: nombreCtrl,
                    label: "Nombre",
                    validator: (value) =>
                        value == null ||
                                value.trim().isEmpty
                            ? "Requerido"
                            : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: descripcionCtrl,
                    label: "Descripción",
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<BinType>(
                    initialValue: selectedBinType,
                    decoration: const InputDecoration(
                      labelText: "Tipo de envase",
                      border: OutlineInputBorder(),
                    ),
                    items: binTypes
                        .map(
                          (binType) =>
                              DropdownMenuItem<BinType>(
                            value: binType,
                            child: Text(
                              binType.nombre,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: loading
                        ? null
                        : (value) {
                            setState(() {
                              selectedBinType = value;
                            });
                          },
                    validator: (value) => value == null
                        ? "Selecciona un envase"
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: precioCtrl,
                    label: "Precio de esta presentación",
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) =>
                        value == null ||
                                value.trim().isEmpty
                            ? "Requerido"
                            : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: stockCtrl,
                    label: "Stock inicial de envases llenos",
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null ||
                                value.trim().isEmpty
                            ? "Requerido"
                            : null,
                  ),
                  if (binTypes.isEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      "Primero debes crear un tipo de envase.",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  PrimaryButton(
                    text: "Guardar producto",
                    loading: loading,
                    onPressed:
                        binTypes.isEmpty ? null : guardar,
                  ),
                ],
              ),
            ),
    );
  }
}