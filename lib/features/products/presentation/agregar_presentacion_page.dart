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
  final unidadMedidaCtrl = TextEditingController();
  final cantidadPorEnvaseCtrl = TextEditingController();
  final cantidadEnvaseContenidoCtrl = TextEditingController();

  List<BinType> allBinTypes = [];
  List<BinType> availableBinTypes = [];

  BinType? selectedBinType;
  BinType? selectedEnvaseContenido;

  String selectedTipoCobro = "envase";

  bool loadingTypes = true;
  bool saving = false;

  bool get cobraPorKilo => selectedTipoCobro == "kilo";

  @override
  void initState() {
    super.initState();
    cargarTiposDisponibles();
  }

  Future<void> cargarTiposDisponibles() async {
    try {
      final allTypes = await binTypeService.getBinTypes();

      if (!mounted) return;

      setState(() {
        allBinTypes = allTypes;
        availableBinTypes = allTypes;
        selectedBinType =
            allTypes.isNotEmpty ? allTypes.first : null;
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

  double? _parseOptionalDouble(String value) {
    final cleanValue = value.trim().replaceAll(",", ".");

    if (cleanValue.isEmpty) {
      return null;
    }

    return double.tryParse(cleanValue);
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

    final cantidadPorEnvase = _parseOptionalDouble(
      cantidadPorEnvaseCtrl.text,
    );

    final cantidadEnvaseContenido = _parseOptionalDouble(
      cantidadEnvaseContenidoCtrl.text,
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

    if (cantidadPorEnvaseCtrl.text.trim().isNotEmpty &&
        (cantidadPorEnvase == null || cantidadPorEnvase <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Ingresa una cantidad por envase válida o deja el campo vacío.",
          ),
        ),
      );
      return;
    }

    if (cantidadEnvaseContenidoCtrl.text.trim().isNotEmpty &&
        (cantidadEnvaseContenido == null ||
            cantidadEnvaseContenido <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Ingresa una cantidad contenida válida o deja el campo vacío.",
          ),
        ),
      );
      return;
    }

    if (selectedEnvaseContenido != null &&
        selectedEnvaseContenido!.id == selectedBinType!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "El envase contenido debe ser distinto al envase principal.",
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
        tipoCobro: selectedTipoCobro,
        unidadMedida: unidadMedidaCtrl.text.trim(),
        cantidadPorEnvase: cantidadPorEnvase,
        envaseContenidoId: selectedEnvaseContenido?.id,
        cantidadEnvaseContenido: cantidadEnvaseContenido,
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
    unidadMedidaCtrl.dispose();
    cantidadPorEnvaseCtrl.dispose();
    cantidadEnvaseContenidoCtrl.dispose();
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
                              isExpanded: true,
                              dropdownColor: card,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              selectedItemBuilder: (context) {
                                return availableBinTypes.map(
                                  (binType) {
                                    return Align(
                                      alignment:
                                          Alignment.centerLeft,
                                      child: Text(
                                        binType.nombre,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        overflow:
                                            TextOverflow.ellipsis,
                                      ),
                                    );
                                  },
                                ).toList();
                              },
                              decoration:
                                  const InputDecoration(
                                labelText: "Tipo de envase",
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
                              "Puedes usar el mismo envase en dos "
                              "presentaciones distintas: una por envase "
                              "y otra por kilo.",
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _sectionCard(
                          title: "Tipo de cobro",
                          icon: Icons.sell,
                          color: Colors.purpleAccent,
                          children: [
                            DropdownButtonFormField<String>(
                              initialValue: selectedTipoCobro,
                              dropdownColor: card,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              decoration:
                                  const InputDecoration(
                                labelText: "Cómo se cobra",
                              ),
                              items: const [
                                DropdownMenuItem<String>(
                                  value: "envase",
                                  child: Text(
                                    "Por envase completo",
                                  ),
                                ),
                                DropdownMenuItem<String>(
                                  value: "kilo",
                                  child: Text(
                                    "Por kilo pesado",
                                  ),
                                ),
                              ],
                              onChanged: saving
                                  ? null
                                  : (value) {
                                      if (value == null) return;

                                      setState(() {
                                        selectedTipoCobro =
                                            value;
                                      });
                                    },
                            ),
                            const SizedBox(height: 10),
                            _smallHelp(
                              cobraPorKilo
                                  ? "El cliente se lleva el envase lleno, "
                                      "pero el total se calcula por kilos."
                                  : "El precio corresponde al envase completo.",
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _sectionCard(
                          title: "Detalle opcional",
                          icon: Icons.schema,
                          color: Colors.lightGreenAccent,
                          children: [
                            AppTextField(
                              controller: unidadMedidaCtrl,
                              label: "Unidad",
                            ),
                            const SizedBox(height: 12),
                            AppTextField(
                              controller: cantidadPorEnvaseCtrl,
                              label: "Cantidad por envase",
                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                decimal: true,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _smallHelp(
                              "Describe la capacidad del envase si te sirve "
                              "como dato interno. Ejemplo: unidad kg y "
                              "cantidad 350 para un bin aproximado de 350 kg. "
                              "Puedes dejarlo vacío.",
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _sectionCard(
                          title: "Contenido opcional",
                          icon: Icons.account_tree,
                          color: Colors.amberAccent,
                          children: [
                            DropdownButtonFormField<BinType>(
                              initialValue:
                                  selectedEnvaseContenido,
                              dropdownColor: card,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              decoration:
                                  const InputDecoration(
                                labelText: "Contenido interno",
                              ),
                              items: allBinTypes
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
                                        selectedEnvaseContenido =
                                            value;
                                      });
                                    },
                            ),
                            if (selectedEnvaseContenido !=
                                null) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment:
                                    Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: saving
                                      ? null
                                      : () {
                                          setState(() {
                                            selectedEnvaseContenido =
                                                null;
                                          });
                                        },
                                  icon: const Icon(
                                    Icons.clear,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    "Quitar contenido interno",
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            AppTextField(
                              controller:
                                  cantidadEnvaseContenidoCtrl,
                              label: "Cantidad contenida",
                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                decimal: true,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _smallHelp(
                              "Úsalo solo si un envase contiene otros "
                              "envases. Ejemplo: un pallet que contiene "
                              "80 cajas. Si vendes bins completos o por kilo, "
                              "puedes dejarlo vacío.",
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
                              label: cobraPorKilo
                                  ? "Precio por kilo"
                                  : "Precio por envase",
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
                              cobraPorKilo
                                  ? "Precio base por kilo. En cada venta "
                                      "podrás mantenerlo o ajustarlo si hay rebaja."
                                  : "Precio base del envase completo. En cada "
                                      "venta podrás mantenerlo o ajustarlo si hay rebaja.",
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
                              label: "Stock inicial",
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
                              cobraPorKilo
                                  ? "Aunque cobre por kilo, el stock sigue "
                                      "siendo cantidad de envases llenos disponibles."
                                  : "Cantidad de envases llenos listos para vender. "
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
              "Una presentación es producto + envase + tipo de cobro "
              "+ precio + stock propio.",
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
            "No hay envases creados",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Primero crea un tipo de envase en el módulo Envases. "
          "Luego podrás volver aquí para agregar una presentación al producto.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white60,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          label: const Text("Volver"),
        ),
      ],
    );
  }
}