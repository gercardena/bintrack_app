import 'package:flutter/material.dart';

import '../../data/services/bin_client_service.dart';

class CreateClientPage extends StatefulWidget {
  const CreateClientPage({super.key});

  @override
  State<CreateClientPage> createState() =>
      _CreateClientPageState();
}

class _CreateClientPageState
    extends State<CreateClientPage> {

  final _formKey = GlobalKey<FormState>();

  final nombreController = TextEditingController();
  final rutController = TextEditingController();
  final emailController = TextEditingController();
  final telefonoController = TextEditingController();
  final direccionController = TextEditingController();

  bool saving = false;

  final service = BinClientService();

  Future<void> guardar() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      saving = true;
    });

    try {

      await service.createClient(
        nombre: nombreController.text.trim(),
        rut: rutController.text.trim(),
        email: emailController.text.trim(),
        telefono: telefonoController.text.trim(),
        direccion: direccionController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context, true);

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
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

    nombreController.dispose();
    rutController.dispose();
    emailController.dispose();
    telefonoController.dispose();
    direccionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Nuevo Cliente"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: ListView(
            children: [

              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return "Ingrese un nombre";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: rutController,
                decoration: const InputDecoration(
                  labelText: "RUT",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return "Ingrese un RUT";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: telefonoController,
                decoration: const InputDecoration(
                  labelText: "Teléfono",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: direccionController,
                decoration: const InputDecoration(
                  labelText: "Dirección",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 50,

                child: ElevatedButton(
                  onPressed:
                      saving ? null : guardar,

                  child: Text(
                    saving
                        ? "Guardando..."
                        : "Guardar",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}