import 'package:flutter/material.dart';
import '../data/products_api.dart';

class CrearProductoPage extends StatefulWidget {
  const CrearProductoPage({super.key});

  @override
  State<CrearProductoPage> createState() => _CrearProductoPageState();
}

class _CrearProductoPageState extends State<CrearProductoPage> {

  final _formKey = GlobalKey<FormState>();

  final nombreCtrl = TextEditingController();
  final precioCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();

  bool loading = false;

  Future<void> guardar() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final ok = await ProductsApi.crearProducto(
      nombre: nombreCtrl.text,
      precio: precioCtrl.text,
      descripcion: descripcionCtrl.text,
    );

    setState(() => loading = false);

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al crear producto")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Producto")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            children: [

              TextFormField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),

              TextFormField(
                controller: precioCtrl,
                decoration: const InputDecoration(labelText: "Precio"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),

              TextFormField(
                controller: descripcionCtrl,
                decoration: const InputDecoration(labelText: "Descripción"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: loading ? null : guardar,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Guardar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}