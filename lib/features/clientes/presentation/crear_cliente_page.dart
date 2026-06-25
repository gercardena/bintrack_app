import 'package:flutter/material.dart';

import '../data/clientes_api.dart';

class CrearClientePage extends StatefulWidget {
  const CrearClientePage({super.key});

  @override
  State<CrearClientePage> createState() =>
      _CrearClientePageState();
}

class _CrearClientePageState
    extends State<CrearClientePage> {
  final _formKey = GlobalKey<FormState>();

  final nombreCtrl = TextEditingController();
  final rutCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    nombreCtrl.dispose();
    rutCtrl.dispose();
    emailCtrl.dispose();
    telefonoCtrl.dispose();
    direccionCtrl.dispose();
    super.dispose();
  }

  String? requerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Requerido";
    }

    return null;
  }

  Future<void> guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    try {
      await ClientesApi.crearCliente(
        nombre: nombreCtrl.text.trim(),
        rut: rutCtrl.text.trim(),
        email: emailCtrl.text.trim().isEmpty
            ? null
            : emailCtrl.text.trim(),
        telefono: telefonoCtrl.text.trim().isEmpty
            ? null
            : telefonoCtrl.text.trim(),
        direccion: direccionCtrl.text.trim().isEmpty
            ? null
            : direccionCtrl.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cliente creado correctamente"),
        ),
      );

      Navigator.pop(context, true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear cliente"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nombreCtrl,
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  border: OutlineInputBorder(),
                ),
                validator: requerido,
              ),
              const SizedBox(
                height: 12,
              ),
              TextFormField(
                controller: rutCtrl,
                decoration: const InputDecoration(
                  labelText: "RUT",
                  border: OutlineInputBorder(),
                ),
                validator: requerido,
              ),
              const SizedBox(
                height: 12,
              ),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(
                height: 12,
              ),
              TextFormField(
                controller: telefonoCtrl,
                decoration: const InputDecoration(
                  labelText: "Teléfono",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(
                height: 12,
              ),
              TextFormField(
                controller: direccionCtrl,
                decoration: const InputDecoration(
                  labelText: "Dirección",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : guardar,
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Guardar cliente"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}