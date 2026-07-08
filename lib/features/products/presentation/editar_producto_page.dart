import 'package:flutter/material.dart';

import '../data/products_api.dart';
import '../data/product_presentations_service.dart';
import '../data/models/product_model.dart';
import '../data/models/product_presentation_model.dart';

import '../../warehouses/data/models/bin_type_model.dart';
import '../../warehouses/data/services/bin_type_service.dart';
import 'agregar_presentacion_page.dart';

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

  final BinTypeService binTypeService = BinTypeService();

  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);

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
  int? savingActiveId;
  int? savingMetadataId;

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

  Future<void> agregarPresentacion() async {
    final existingBinTypeIds = presentations
        .map(
          (presentation) => presentation.binTypeId,
        )
        .toSet();

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AgregarPresentacionPage(
          productId: widget.product.id,
          existingBinTypeIds: existingBinTypeIds,
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        loadingPresentations = true;
      });

      await cargarPresentaciones();
    }
  }

  double? _parseOptionalDouble(String value) {
    final cleanValue = value.trim().replaceAll(",", ".");

    if (cleanValue.isEmpty) {
      return null;
    }

    return double.tryParse(cleanValue);
  }

  String _formatOptionalDouble(double? value) {
    if (value == null) return "";

    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }

    return value.toString();
  }

  BinType? _findBinTypeById(
    List<BinType> binTypes,
    int? id,
  ) {
    if (id == null) return null;

    for (final binType in binTypes) {
      if (binType.id == id) {
        return binType;
      }
    }

    return null;
  }

  Future<void> editarMetadata(
    ProductPresentation presentation,
  ) async {
    List<BinType> binTypes;

    try {
      binTypes = await binTypeService.getBinTypes();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "No pudimos cargar los envases: $e",
          ),
        ),
      );
      return;
    }

    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final unidadCtrl = TextEditingController(
      text: presentation.unidadMedida ?? "",
    );

    final cantidadPorEnvaseCtrl = TextEditingController(
      text: _formatOptionalDouble(
        presentation.cantidadPorEnvase,
      ),
    );

    final cantidadEnvaseContenidoCtrl = TextEditingController(
      text: _formatOptionalDouble(
        presentation.cantidadEnvaseContenido,
      ),
    );

    BinType? selectedEnvaseContenido = _findBinTypeById(
      binTypes,
      presentation.envaseContenidoId,
    );

    String? errorText;
    bool saving = false;

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: card,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        builder: (sheetContext) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              Future<void> save() async {
                final cantidadPorEnvase = _parseOptionalDouble(
                  cantidadPorEnvaseCtrl.text,
                );

                final cantidadEnvaseContenido =
                    _parseOptionalDouble(
                  cantidadEnvaseContenidoCtrl.text,
                );

                if (cantidadPorEnvaseCtrl.text.trim().isNotEmpty &&
                    (cantidadPorEnvase == null ||
                        cantidadPorEnvase <= 0)) {
                  setModalState(() {
                    errorText =
                        "La cantidad por envase debe ser mayor que cero o quedar vacía.";
                  });
                  return;
                }

                if (cantidadEnvaseContenidoCtrl.text
                        .trim()
                        .isNotEmpty &&
                    (cantidadEnvaseContenido == null ||
                        cantidadEnvaseContenido <= 0)) {
                  setModalState(() {
                    errorText =
                        "La cantidad contenida debe ser mayor que cero o quedar vacía.";
                  });
                  return;
                }

                if (selectedEnvaseContenido != null &&
                    selectedEnvaseContenido!.id ==
                        presentation.binTypeId) {
                  setModalState(() {
                    errorText =
                        "El envase contenido debe ser distinto al envase principal.";
                  });
                  return;
                }

                setModalState(() {
                  saving = true;
                  errorText = null;
                });

                if (mounted) {
                  setState(() {
                    savingMetadataId = presentation.id;
                  });
                }

                try {
                  await presentationsService.saveMetadata(
                    presentation: presentation,
                    unidadMedida: unidadCtrl.text,
                    cantidadPorEnvase: cantidadPorEnvase,
                    envaseContenidoId:
                        selectedEnvaseContenido?.id,
                    cantidadEnvaseContenido:
                        cantidadEnvaseContenido,
                  );

                  await cargarPresentaciones();

                  if (!mounted) return;

                  if (!sheetContext.mounted) return;

                  Navigator.pop(sheetContext);

                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Detalle actualizado correctamente.",
                      ),
                    ),
                  );
                } catch (e) {
                  setModalState(() {
                    saving = false;
                    errorText = e.toString();
                  });
                } finally {
                  if (mounted) {
                    setState(() {
                      savingMetadataId = null;
                    });
                  }
                }
              }

              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 18,
                    bottom: MediaQuery.of(context)
                            .viewInsets
                            .bottom +
                        18,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.schema,
                              color: Colors.lightGreenAccent,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Detalle del envase",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Opcional. Úsalo solo si quieres indicar capacidad o contenido.",
                          style: TextStyle(
                            color: Colors.white60,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: unidadCtrl,
                          enabled: !saving,
                          cursorColor: Colors.black,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            labelText: "Unidad",
                            hintText: "Ej: cajas, kg, unidades",
                            labelStyle: const TextStyle(
                              color: Colors.black54,
                            ),
                            hintStyle: const TextStyle(
                              color: Colors.black38,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: cantidadPorEnvaseCtrl,
                          enabled: !saving,
                          cursorColor: Colors.black,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: "Cantidad",
                            hintText: "Ej: 80",
                            labelStyle: const TextStyle(
                              color: Colors.black54,
                            ),
                            hintStyle: const TextStyle(
                              color: Colors.black38,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<BinType>(
                          initialValue: selectedEnvaseContenido,
                          dropdownColor: card,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            labelText: "Envase contenido",
                            hintText: "Opcional",
                          ),
                          selectedItemBuilder: (context) {
                            return binTypes.map((binType) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  binType.nombre,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          items: binTypes
                              .map(
                                (binType) =>
                                    DropdownMenuItem<BinType>(
                                  value: binType,
                                  child: Text(
                                    binType.nombre,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: saving
                              ? null
                              : (value) {
                                  setModalState(() {
                                    selectedEnvaseContenido = value;
                                  });
                                },
                        ),
                        if (selectedEnvaseContenido != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: saving
                                  ? null
                                  : () {
                                      setModalState(() {
                                        selectedEnvaseContenido = null;
                                      });
                                    },
                              icon: const Icon(
                                Icons.clear,
                                size: 18,
                              ),
                              label: const Text(
                                "Quitar envase contenido",
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        TextFormField(
                          controller:
                              cantidadEnvaseContenidoCtrl,
                          enabled: !saving,
                          cursorColor: Colors.black,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: "Cantidad contenida",
                            hintText: "Ej: 80",
                            labelStyle: const TextStyle(
                              color: Colors.black54,
                            ),
                            hintStyle: const TextStyle(
                              color: Colors.black38,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        if (errorText != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            errorText!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              height: 1.35,
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: saving
                                    ? null
                                    : () => Navigator.pop(
                                          sheetContext,
                                        ),
                                child: const Text("Cancelar"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: saving ? null : save,
                                icon: saving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.save),
                                label: const Text("Guardar"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      unidadCtrl.dispose();
      cantidadPorEnvaseCtrl.dispose();
      cantidadEnvaseContenidoCtrl.dispose();
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
            "Producto actualizado correctamente.",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No fue posible actualizar el producto.",
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
            "Ingresa un precio válido mayor que cero.",
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
            "Precio actualizado correctamente.",
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
            "Ingresa una cantidad válida. Puede ser 0 o mayor.",
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
            "Stock actualizado correctamente.",
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

  Future<void> cambiarEstado(
    ProductPresentation presentation,
  ) async {
    final nuevoEstado = !presentation.activo;

    if (!nuevoEstado) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text(
            "Desactivar presentación",
          ),
          content: Text(
            "¿Quieres desactivar "
            "${presentation.binNombre}?\n\n"
            "Solo será posible si su stock es cero.",
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text("Desactivar"),
            ),
          ],
        ),
      );

      if (confirm != true || !mounted) return;
    }

    setState(() {
      savingActiveId = presentation.id;
    });

    try {
      await presentationsService.saveActive(
        presentation: presentation,
        activo: nuevoEstado,
      );

      await cargarPresentaciones();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nuevoEstado
                ? "Presentación activada."
                : "Presentación desactivada.",
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
          savingActiveId = null;
        });
      }
    }
  }

  Future<void> eliminar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar producto"),
        content: Text(
          "¿Seguro que quieres eliminar "
          "${widget.product.nombre}?\n\n"
          "Esta acción también puede afectar sus presentaciones.",
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () =>
                Navigator.pop(context, true),
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
            "No fue posible eliminar el producto.",
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
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.06),
          labelStyle: const TextStyle(
            color: Colors.white70,
          ),
          prefixStyle: const TextStyle(
            color: Colors.white,
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
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
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
          title: const Text("Editar producto"),
          centerTitle: true,
          backgroundColor: background,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              tooltip: "Eliminar producto",
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
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
              _introCard(),

              const SizedBox(height: 16),

              _sectionCard(
                title: "Datos del producto",
                icon: Icons.eco,
                color: Colors.greenAccent,
                children: [
                  TextFormField(
                    controller: nombreCtrl,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Nombre",
                    ),
                    validator: (value) =>
                        value == null ||
                                value.trim().isEmpty
                            ? "Ingresa el nombre del producto"
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descripcionCtrl,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Descripción",
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: loading
                          ? null
                          : guardarProducto,
                      icon: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: const Text(
                        "Guardar datos del producto",
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _sectionHeader(
                title: "Presentaciones, precios y stock",
                subtitle:
                    "Cada presentación combina este producto con un envase, precio y stock propio.",
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.cyanAccent,
                    side: BorderSide(
                      color: Colors.cyanAccent.withValues(
                        alpha: 0.45,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                  onPressed: loadingPresentations
                      ? null
                      : agregarPresentacion,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    "Agregar presentación",
                  ),
                ),
              ),

              const SizedBox(height: 14),

              if (loadingPresentations)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (presentations.isEmpty)
                _emptyPresentations()
              else
                ...presentations.map(
                  _presentationCard,
                ),

              const SizedBox(height: 24),
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
            Color(0xFF15803D),
            Color(0xFF0F766E),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.20),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.inventory_2,
            color: Colors.white,
            size: 34,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.product.nombre,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white60,
            height: 1.35,
          ),
        ),
      ],
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

  Widget _presentationCard(
    ProductPresentation presentation,
  ) {
    final activeColor = presentation.activo
        ? Colors.greenAccent
        : Colors.grey;

    final isSavingPrice =
        savingPriceId == presentation.id;

    final isSavingStock =
        savingStockId == presentation.id;

    final isSavingActive =
        savingActiveId == presentation.id;

    final isSavingMetadata =
        savingMetadataId == presentation.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: activeColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    activeColor.withValues(alpha: 0.18),
                child: Icon(
                  presentation.activo
                      ? Icons.inventory_2
                      : Icons.block,
                  color: activeColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  presentation.binNombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Chip(
                label: Text(
                  presentation.activo
                      ? "Activa"
                      : "Inactiva",
                ),
                labelStyle: TextStyle(
                  color: activeColor,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor:
                    activeColor.withValues(alpha: 0.12),
                side: BorderSide(
                  color: activeColor.withValues(alpha: 0.25),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _smallHelp(
            "Esta presentación tiene precio y stock propio.",
          ),

          if (presentation.capacidadDescripcion != null) ...[
            const SizedBox(height: 8),
            _infoPill(
              icon: Icons.scale,
              text:
                  "Capacidad: ${presentation.capacidadDescripcion}",
              color: Colors.lightGreenAccent,
            ),
          ],

          if (presentation.contenidoDescripcion != null) ...[
            const SizedBox(height: 8),
            _infoPill(
              icon: Icons.account_tree,
              text:
                  "Contiene: ${presentation.contenidoDescripcion}",
              color: Colors.amberAccent,
            ),
          ],

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.lightGreenAccent,
                side: BorderSide(
                  color: Colors.lightGreenAccent.withValues(
                    alpha: 0.45,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
              ),
              onPressed: isSavingMetadata
                  ? null
                  : () => editarMetadata(
                        presentation,
                      ),
              icon: isSavingMetadata
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.tune),
              label: const Text(
                "Editar detalle",
              ),
            ),
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller:
                priceControllers[presentation.id],
            enabled: presentation.activo,
            style: const TextStyle(
              color: Colors.white,
            ),
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: "Precio para este envase",
              prefixText: "\$",
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: !presentation.activo ||
                      isSavingPrice
                  ? null
                  : () => guardarPrecio(
                        presentation,
                      ),
              icon: isSavingPrice
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.attach_money),
              label: const Text(
                "Actualizar precio",
              ),
            ),
          ),

          const SizedBox(height: 18),

          TextFormField(
            controller:
                stockControllers[presentation.id],
            enabled: presentation.activo,
            style: const TextStyle(
              color: Colors.white,
            ),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText:
                  "Envases llenos listos para vender",
            ),
          ),

          const SizedBox(height: 8),

          _smallHelp(
            "Este stock representa envases llenos, no kilos ni unidades sueltas.",
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: !presentation.activo ||
                      isSavingStock
                  ? null
                  : () => guardarStock(
                        presentation,
                      ),
              icon: isSavingStock
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.inventory),
              label: const Text(
                "Actualizar stock",
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: presentation.activo
                    ? Colors.redAccent
                    : Colors.greenAccent,
                side: BorderSide(
                  color: presentation.activo
                      ? Colors.redAccent.withValues(
                          alpha: 0.55,
                        )
                      : Colors.greenAccent.withValues(
                          alpha: 0.55,
                        ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
              ),
              onPressed: isSavingActive
                  ? null
                  : () => cambiarEstado(
                        presentation,
                      ),
              icon: isSavingActive
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      presentation.activo
                          ? Icons.block
                          : Icons.check_circle,
                    ),
              label: Text(
                presentation.activo
                    ? "Desactivar presentación"
                    : "Activar presentación",
              ),
            ),
          ),
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

  Widget _infoPill({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                height: 1.3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyPresentations() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.35),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orangeAccent,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Este producto todavía no tiene presentaciones. "
              "Agrega una para definir envase, precio y stock.",
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
}







