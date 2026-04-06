import 'package:flutter/material.dart';
import '../data/clientes_api.dart';

class CrearClientePage extends StatefulWidget {
  const CrearClientePage({super.key});

  @override
  State<CrearClientePage> createState() => _CrearClientePageState();
}

class _CrearClientePageState extends State<CrearClientePage> {

  final _formKey = GlobalKey<FormState>();

  final nombreCtrl = TextEditingController();
  final rutCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();

  bool loading = false;

  Future<void> _guardarCliente() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {

      final ok = await ClientesApi.crearCliente(
        nombre: nombreCtrl.text,
        rut: rutCtrl.text,
        email: emailCtrl.text,
        telefono: telefonoCtrl.text,
        direccion: direccionCtrl.text,
      );

      if (ok) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cliente creado correctamente")),
        );

        Navigator.pop(context, true); // 🔥 vuelve y refresca

      } else {

        throw Exception("Error al crear cliente");

      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Nuevo Cliente"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            children: [

              _input(nombreCtrl, "Nombre", obligatorio: true),
              _input(rutCtrl, "RUT", obligatorio: true),
              _input(emailCtrl, "Email"),
              _input(telefonoCtrl, "Teléfono"),
              _input(direccionCtrl, "Dirección"),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : _guardarCliente,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Guardar"),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  // 🔥 INPUT REUTILIZABLE
  Widget _input(TextEditingController ctrl, String label,
      {bool obligatorio = false}) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: TextFormField(
        controller: ctrl,

        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        validator: (value) {
          if (obligatorio && (value == null || value.isEmpty)) {
            return "Campo obligatorio";
          }
          return null;
        },
      ),
    );
  }
}