import 'package:flutter/material.dart';

import '../data/sales_service.dart';

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
  State<SaleDetailPage> createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends State<SaleDetailPage> {

  final ProductsService _productsService = ProductsService();

  final SalesService _salesService = SalesService();

  final BinTypeService _binTypeService = BinTypeService();

  List<Product> productos = [];

  List<BinType> bins = [];

  Product? productoSeleccionado;

  BinType? binSeleccionado;

  final TextEditingController cantidadController =
      TextEditingController();

  bool loading = true;

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
          content: Text("Selecciona un producto"),
        ),
      );

      return;
    }

    if (binSeleccionado == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecciona un BIN"),
        ),
      );

      return;
    }

    if (cantidadController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ingresa cantidad"),
        ),
      );

      return;
    }

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
          content: Text("Item agregado correctamente"),
        ),
      );

      cantidadController.clear();

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  // =========================================
  // 🔥 UI
  // =========================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Venta #${widget.saleId}"),
      ),

      body: loading

          ? const Center(
              child: CircularProgressIndicator(),
            )

          : SingleChildScrollView(

              padding: const EdgeInsets.all(16),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    "Detalle Venta #${widget.saleId}",

                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =====================================
                  // PRODUCTO
                  // =====================================

                  const Text(
                    "Producto",

                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<Product>(

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

                  const SizedBox(height: 20),

                  // =====================================
                  // BIN
                  // =====================================

                  const Text(
                    "BIN",

                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<BinType>(

                    value: binSeleccionado,

                    items: bins.map<DropdownMenuItem<BinType>>((bin) {

                      return DropdownMenuItem<BinType>(

                        value: bin,

                        child: Text(
                          "${bin.nombre}",
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

                  const SizedBox(height: 20),

                  // =====================================
                  // CANTIDAD
                  // =====================================

                  TextField(

                    controller: cantidadController,

                    keyboardType: TextInputType.number,

                    decoration: const InputDecoration(
                      labelText: "Cantidad",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =====================================
                  // BOTON
                  // =====================================

                  SizedBox(

                    width: double.infinity,

                    child: ElevatedButton(

                      onPressed: agregarItem,

                      child: const Text(
                        "Agregar Item",
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}