import 'package:flutter/material.dart';

import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';

import '../data/product_presentations_service.dart';
import '../data/models/product_presentation_model.dart';

import '../../warehouses/data/models/bin_type_model.dart';
import '../../warehouses/data/services/bin_type_service.dart';

class AgregarPresentacionPage extends StatefulWidget {
  final int productId;
  final Set<int> existingBinTypeIds;

  const AgregarPresentacionPage({
    super.key,
    required this.productId,
    required this.existingBinTypeIds,
  });

  @override
  State<AgregarPresentacionPage> createState() =>
      _AgregarPresentacionPageState();
}

class _AgregarPresentacionPageState
    extends State<AgregarPresentacionPage> {
  final _formKey = GlobalKey<FormState>();

  final ProductPresentationsService presentationsService =
      ProductPresentationsService();

  final BinTypeService binTypeService = BinTypeService();

  final precioCtrl = TextEditingController();
  final stockCtrl = TextEditingController(text: "0");

  List<BinType> availableBinTypes = [];
  BinType? selectedBinType;

  bool loadingTypes = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    cargarTiposDisponibles();
  }

  Future<void> cargarTiposDisponibles() async {
    try {
      final allTypes = await binTypeService.getBinTypes();

      final available = allTypes
          .where(
            (binType) => !widget.existingBinTypeIds.contains(
              binType.id,
            ),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        availableBinTypes = available;
        selectedBinType =
            available.isNotEmpty ? available.first : null;
        loadingTypes = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingTypes = false;
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
    if (saving) return;

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
      saving = true;
    });

    ProductPresentation? createdPresentation;

    try {
      createdPresentation =
          await presentationsService.createPresentation(
        productId: widget.productId,
        binTypeId: selectedBinType!.id,
        precio: precio,
      );

      await presentationsService.saveStock(
        presentation: createdPresentation,
        cantidad: stock,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (createdPresentation != null) {
        try {
          await presentationsService.deletePresentation(
            createdPresentation.id,
          );
        } catch (_) {
          // Conservamos el error original.
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
          saving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    precioCtrl.dispose();
    stockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Agregar presentación",
        ),
      ),
      body: loadingTypes
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : availableBinTypes.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      "No hay otros tipos de envase disponibles "
                      "para este producto.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      DropdownButtonFormField<BinType>(
                        initialValue: selectedBinType,
                        decoration: const InputDecoration(
                          labelText: "Tipo de envase",
                          border: OutlineInputBorder(),
                        ),
                        items: availableBinTypes
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
                        onChanged: saving
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
                        keyboardType: const TextInputType
                            .numberWithOptions(
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
                        label:
                            "Stock inicial de envases llenos",
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value == null ||
                                    value.trim().isEmpty
                                ? "Requerido"
                                : null,
                      ),
                      const SizedBox(height: 30),
                      PrimaryButton(
                        text: "Agregar presentación",
                        loading: saving,
                        onPressed: guardar,
                      ),
                    ],
                  ),
                ),
    );
  }
}