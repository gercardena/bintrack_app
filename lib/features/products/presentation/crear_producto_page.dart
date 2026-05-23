import 'package:flutter/material.dart';

import '../data/products_api.dart';
import '../../inventory/data/inventory_api.dart';

class CrearProductoPage extends StatefulWidget {

  const CrearProductoPage({super.key});

  @override
  State<CrearProductoPage> createState() =>
      _CrearProductoPageState();
}

class _CrearProductoPageState
    extends State<CrearProductoPage> {

  final _formKey = GlobalKey<FormState>();

  final nombreCtrl = TextEditingController();
  final precioCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();

  // 🔥 NUEVO
  final stockCtrl = TextEditingController();

  bool loading = false;

  Future<void> guardar() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    // =====================================
    // 🔹 CREAR PRODUCTO
    // =====================================

    final producto = await ProductsApi.crearProducto(

      nombre: nombreCtrl.text,
      precio: precioCtrl.text,
      descripcion: descripcionCtrl.text,

    );

    // =====================================
    // 🔹 ERROR PRODUCTO
    // =====================================

    if (producto == null) {

      setState(() {
        loading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al crear producto"),
        ),
      );

      return;
    }

    // =====================================
    // 🔥 CREAR INVENTARIO AUTOMÁTICO
    // =====================================

    final int productId = producto['id'];

    final int cantidad =
        int.tryParse(stockCtrl.text) ?? 0;

    final okInventario =
        await InventoryApi.ajustarStock(

      productId: productId,

      // 🔥 BIN DEFAULT
      binId: 1,

      cantidad: cantidad,
    );

    setState(() {
      loading = false;
    });

    // =====================================
    // 🔹 OK
    // =====================================

    if (okInventario) {

      if (!mounted) return;

      Navigator.pop(context, true);

    } else {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Producto creado pero inventario falló",
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
    stockCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Nuevo Producto"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Form(

          key: _formKey,

          child: Column(

            children: [

              // =====================================
              // 🔹 NOMBRE
              // =====================================

              TextFormField(

                controller: nombreCtrl,

                decoration: const InputDecoration(
                  labelText: "Nombre",
                ),

                validator: (v) =>
                    v!.isEmpty ? "Requerido" : null,
              ),

              const SizedBox(height: 16),

              // =====================================
              // 🔹 PRECIO
              // =====================================

              TextFormField(

                controller: precioCtrl,

                decoration: const InputDecoration(
                  labelText: "Precio",
                ),

                keyboardType: TextInputType.number,

                validator: (v) =>
                    v!.isEmpty ? "Requerido" : null,
              ),

              const SizedBox(height: 16),

              // =====================================
              // 🔹 DESCRIPCIÓN
              // =====================================

              TextFormField(

                controller: descripcionCtrl,

                decoration: const InputDecoration(
                  labelText: "Descripción",
                ),
              ),

              const SizedBox(height: 16),

              // =====================================
              // 🔥 STOCK INICIAL
              // =====================================

              TextFormField(

                controller: stockCtrl,

                decoration: const InputDecoration(
                  labelText: "Stock inicial",
                ),

                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 30),

              // =====================================
              // 🔹 BOTÓN
              // =====================================

              SizedBox(

                width: double.infinity,

                child: ElevatedButton(

                  onPressed:
                      loading ? null : guardar,

                  child: loading

                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )

                      : const Text("Guardar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}