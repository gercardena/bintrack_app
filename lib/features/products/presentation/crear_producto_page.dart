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

  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);

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
        selectedBinType =
            data.isNotEmpty ? data.first : null;
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
            "No pudimos cargar los tipos de envase: $e",
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
            "Selecciona el envase de esta presentación.",
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
            "Ingresa un precio válido mayor que cero.",
          ),
        ),
      );
      return;
    }

    if (stock == null || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Ingresa un stock válido. Puede ser 0 o mayor.",
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
          "No fue posible crear el producto.",
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Producto creado correctamente.",
          ),
        ),
      );

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
          content: Text(
            "No fue posible crear el producto: $e",
          ),
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
      backgroundColor: background,
      appBar: AppBar(
        title: const Text("Nuevo producto"),
        centerTitle: true,
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
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
                  _introCard(),

                  const SizedBox(height: 16),

                  _sectionCard(
                    title: "1. Datos del producto",
                    icon: Icons.eco,
                    color: Colors.green,
                    children: [
                      AppTextField(
                        controller: nombreCtrl,
                        label: "Nombre del producto",
                        validator: (value) =>
                            value == null ||
                                    value.trim().isEmpty
                                ? "Ingresa el nombre del producto"
                                : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: descripcionCtrl,
                        label: "Descripción",
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _sectionCard(
                    title: "2. Presentación inicial",
                    icon: Icons.inventory_2,
                    color: Colors.cyan,
                    children: [
                      DropdownButtonFormField<BinType>(
                        initialValue: selectedBinType,
                        dropdownColor: card,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
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
                        validator: (value) =>
                            value == null
                                ? "Selecciona un envase"
                                : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: precioCtrl,
                        label: "Precio para este envase",
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) =>
                            value == null ||
                                    value.trim().isEmpty
                                ? "Ingresa el precio"
                                : null,
                      ),
                      const SizedBox(height: 10),
                      _smallHelp(
                        "Ejemplo: Ciruelas + Bin Azul puede tener "
                        "un precio distinto a Ciruelas + Pallet.",
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _sectionCard(
                    title: "3. Stock inicial",
                    icon: Icons.inventory,
                    color: Colors.orange,
                    children: [
                      AppTextField(
                        controller: stockCtrl,
                        label:
                            "Envases llenos listos para vender",
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value == null ||
                                    value.trim().isEmpty
                                ? "Ingresa el stock inicial"
                                : null,
                      ),
                      const SizedBox(height: 10),
                      _smallHelp(
                        "Este número representa envases llenos, "
                        "no kilos ni unidades sueltas. Si aún no "
                        "tienes stock preparado, usa 0.",
                      ),
                    ],
                  ),

                  if (binTypes.isEmpty) ...[
                    const SizedBox(height: 16),
                    _warningCard(
                      "Primero debes crear un tipo de envase "
                      "antes de registrar productos.",
                    ),
                  ],

                  const SizedBox(height: 30),

                  PrimaryButton(
                    text: "Guardar producto",
                    loading: loading,
                    onPressed:
                        binTypes.isEmpty ? null : guardar,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _introCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF15803D),
            Color(0xFF0F766E),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(
              alpha: 0.22,
            ),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.add_box,
            color: Colors.white,
            size: 32,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Crea el producto junto a su primera "
              "presentación: producto + envase + precio "
              "+ stock inicial.",
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
          color: Colors.white.withValues(
            alpha: 0.06,
          ),
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

  Widget _smallHelp(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _warningCard(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}