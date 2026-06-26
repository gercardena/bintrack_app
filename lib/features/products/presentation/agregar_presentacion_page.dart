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

  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);

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
            (binType) =>
                !widget.existingBinTypeIds.contains(
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
            "No pudimos cargar los tipos de envase: $e",
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Presentación agregada correctamente.",
          ),
        ),
      );

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
          content: Text(
            "No fue posible agregar la presentación: $e",
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
    precioCtrl.dispose();
    stockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.06),
          labelStyle: const TextStyle(
            color: Colors.white70,
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
              color: Colors.cyan,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.redAccent,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.redAccent,
            ),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: const Text(
            "Agregar presentación",
          ),
          centerTitle: true,
          backgroundColor: background,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: loadingTypes
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : availableBinTypes.isEmpty
                ? _emptyState()
                : Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _introCard(),

                        const SizedBox(height: 16),

                        _sectionCard(
                          title: "Envase",
                          icon: Icons.inventory_2,
                          color: Colors.cyanAccent,
                          children: [
                            DropdownButtonFormField<BinType>(
                              initialValue: selectedBinType,
                              dropdownColor: card,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              decoration:
                                  const InputDecoration(
                                labelText:
                                    "Tipo de envase",
                              ),
                              items: availableBinTypes
                                  .map(
                                    (binType) =>
                                        DropdownMenuItem<
                                            BinType>(
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
                                        selectedBinType =
                                            value;
                                      });
                                    },
                              validator: (value) =>
                                  value == null
                                      ? "Selecciona un envase"
                                      : null,
                            ),
                            const SizedBox(height: 10),
                            _smallHelp(
                              "Solo aparecen envases que este producto "
                              "todavía no usa.",
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _sectionCard(
                          title: "Precio",
                          icon: Icons.attach_money,
                          color: Colors.greenAccent,
                          children: [
                            AppTextField(
                              controller: precioCtrl,
                              label:
                                  "Precio para este envase",
                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                decimal: true,
                              ),
                              validator: (value) =>
                                  value == null ||
                                          value
                                              .trim()
                                              .isEmpty
                                      ? "Ingresa el precio"
                                      : null,
                            ),
                            const SizedBox(height: 10),
                            _smallHelp(
                              "Este precio aplica solo a la combinación "
                              "producto + envase seleccionada.",
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _sectionCard(
                          title: "Stock inicial",
                          icon: Icons.inventory,
                          color: Colors.orangeAccent,
                          children: [
                            AppTextField(
                              controller: stockCtrl,
                              label:
                                  "Envases llenos listos para vender",
                              keyboardType:
                                  TextInputType.number,
                              validator: (value) =>
                                  value == null ||
                                          value
                                              .trim()
                                              .isEmpty
                                      ? "Ingresa el stock inicial"
                                      : null,
                            ),
                            const SizedBox(height: 10),
                            _smallHelp(
                              "Este número representa envases llenos. "
                              "Si aún no tienes stock preparado, usa 0.",
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        PrimaryButton(
                          text: "Agregar presentación",
                          loading: saving,
                          onPressed: guardar,
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
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
            Color(0xFF0E7490),
            Color(0xFF2563EB),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withValues(alpha: 0.20),
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
              "Agrega una nueva presentación para este producto. "
              "Una presentación es producto + envase + precio "
              "+ stock propio.",
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

  Widget _emptyState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 90),
        Icon(
          Icons.inventory_2_outlined,
          size: 76,
          color: Colors.white.withValues(alpha: 0.35),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            "No hay envases disponibles",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Este producto ya usa todos los tipos de envase "
          "registrados, o todavía no existen envases creados.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white60,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}