import 'package:flutter/material.dart';

import '../../data/services/bin_type_service.dart';

class CreateBinTypePage extends StatefulWidget {
  const CreateBinTypePage({super.key});

  @override
  State<CreateBinTypePage> createState() =>
      _CreateBinTypePageState();
}

class _CreateBinTypePageState
    extends State<CreateBinTypePage> {

  final _formKey = GlobalKey<FormState>();

  final nombreController = TextEditingController();
  final materialController = TextEditingController();
  final depositoController = TextEditingController();

  String tipo = "BIN";

  bool saving = false;

  final service = BinTypeService();

  Future<void> guardar() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      saving = true;
    });

    try {

      await service.createBinType(
        nombre: nombreController.text.trim(),
        tipo: tipo,
        material: materialController.text.trim(),
        valorDeposito:
            double.parse(depositoController.text),
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
    materialController.dispose();
    depositoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Nuevo Tipo de Envase",
        ),
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

              DropdownButtonFormField<String>(
                value: tipo,

                decoration: const InputDecoration(
                  labelText: "Tipo",
                  border: OutlineInputBorder(),
                ),

                items: const [

                  DropdownMenuItem(
                    value: "BIN",
                    child: Text("Bin"),
                  ),

                  DropdownMenuItem(
                    value: "PALLET",
                    child: Text("Pallet"),
                  ),

                  DropdownMenuItem(
                    value: "CAJA",
                    child: Text("Caja"),
                  ),
                ],

                onChanged: (value) {

                  if (value == null) return;

                  setState(() {
                    tipo = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: materialController,
                decoration: const InputDecoration(
                  labelText: "Material",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: depositoController,
                keyboardType: TextInputType.number,

                decoration: const InputDecoration(
                  labelText: "Valor depósito",
                  border: OutlineInputBorder(),
                ),

                validator: (value) {

                  if (value == null ||
                      value.trim().isEmpty) {
                    return "Ingrese un valor";
                  }

                  if (double.tryParse(value) == null) {
                    return "Ingrese un número válido";
                  }

                  return null;
                },
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