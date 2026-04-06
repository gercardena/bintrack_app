import 'package:flutter/material.dart';

import '../data/products_api.dart';
import '../models/product.dart';

class EditarProductoPage extends StatefulWidget {

  final Product product;

  const EditarProductoPage({
    super.key,
    required this.product,
  });

  @override
  State<EditarProductoPage> createState() => _EditarProductoPageState();
}

class _EditarProductoPageState extends State<EditarProductoPage> {

  final _formKey = GlobalKey<FormState>();

  late TextEditingController nombreCtrl;
  late TextEditingController precioCtrl;
  late TextEditingController descripcionCtrl;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    nombreCtrl = TextEditingController(text: widget.product.name);
    precioCtrl = TextEditingController(text: widget.product.price.toString());
    descripcionCtrl = TextEditingController(
      text: widget.product.description ?? "",
    );
  }

  Future<void> guardar() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final ok = await ProductsApi.actualizarProducto(
      id: widget.product.id,
      nombre: nombreCtrl.text,
      precio: precioCtrl.text,
      descripcion: descripcionCtrl.text,
    );

    setState(() => loading = false);

    if (ok) {

      Navigator.pop(context, true);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al actualizar producto")),
      );

    }
  }

  Future<void> eliminar() async {

    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar producto"),
        content: const Text("¿Seguro que quieres eliminar este producto?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => loading = true);

    final ok = await ProductsApi.eliminarProducto(widget.product.id);

    setState(() => loading = false);

    if (ok) {

      Navigator.pop(context, true);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al eliminar producto")),
      );

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Producto"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: loading ? null : eliminar,
          )
        ],
      ),

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
                    : const Text("Guardar cambios"),
              ),

            ],
          ),
        ),
      ),
    );
  }
}