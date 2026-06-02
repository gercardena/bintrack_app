import 'package:flutter/material.dart';

import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';

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

  // 🔥 STOCK INICIAL
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

              AppTextField(

                controller: nombreCtrl,

                label: "Nombre",

                validator: (v) =>
                    v!.isEmpty ? "Requerido" : null,
              ),

              const SizedBox(height: 16),

              // =====================================
              // 🔹 PRECIO
              // =====================================

              AppTextField(

                controller: precioCtrl,

                label: "Precio",

                keyboardType: TextInputType.number,

                validator: (v) =>
                    v!.isEmpty ? "Requerido" : null,
              ),

              const SizedBox(height: 16),

              // =====================================
              // 🔹 DESCRIPCIÓN
              // =====================================

              AppTextField(

                controller: descripcionCtrl,

                label: "Descripción",
              ),

              const SizedBox(height: 16),

              // =====================================
              // 🔥 STOCK INICIAL
              // =====================================

              AppTextField(

                controller: stockCtrl,

                label: "Stock inicial",

                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 30),

              // =====================================
              // 🔹 BOTÓN
              // =====================================

              PrimaryButton(

                text: "Guardar",

                loading: loading,

                onPressed: guardar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}