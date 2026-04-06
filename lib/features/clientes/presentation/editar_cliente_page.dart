import 'package:flutter/material.dart';
import '../data/clientes_api.dart';
import '../models/cliente.dart';

class EditarClientePage extends StatefulWidget {

  final Cliente cliente;

  const EditarClientePage({super.key, required this.cliente});

  @override
  State<EditarClientePage> createState() => _EditarClientePageState();
}

class _EditarClientePageState extends State<EditarClientePage> {

  final _formKey = GlobalKey<FormState>();

  late TextEditingController nombreCtrl;
  late TextEditingController rutCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController telefonoCtrl;
  late TextEditingController direccionCtrl;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    nombreCtrl = TextEditingController(text: widget.cliente.nombre);
    rutCtrl = TextEditingController(text: widget.cliente.rut);
    emailCtrl = TextEditingController(text: widget.cliente.email ?? "");
    telefonoCtrl = TextEditingController(text: widget.cliente.telefono ?? "");
    direccionCtrl = TextEditingController(text: widget.cliente.direccion ?? "");
  }

  Future<void> _guardarCambios() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {

      final ok = await ClientesApi.actualizarCliente(
        widget.cliente.id,
        nombre: nombreCtrl.text,
        rut: rutCtrl.text,
        email: emailCtrl.text,
        telefono: telefonoCtrl.text,
        direccion: direccionCtrl.text,
      );

      if (ok) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cliente actualizado")),
        );

        Navigator.pop(context, true);
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
        title: const Text("Editar Cliente"),
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
                  onPressed: loading ? null : _guardarCambios,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Guardar cambios"),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

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