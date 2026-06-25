import 'package:flutter/material.dart';

import '../data/clientes_api.dart';
import '../models/cliente.dart';

class EditarClientePage extends StatefulWidget {
  final Cliente cliente;

  const EditarClientePage({
    super.key,
    required this.cliente,
  });

  @override
  State<EditarClientePage> createState() =>
      _EditarClientePageState();
}

class _EditarClientePageState
    extends State<EditarClientePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nombreCtrl;
  late TextEditingController rutCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController telefonoCtrl;
  late TextEditingController direccionCtrl;

  late bool activo;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    nombreCtrl = TextEditingController(
      text: widget.cliente.nombre,
    );
    rutCtrl = TextEditingController(
      text: widget.cliente.rut,
    );
    emailCtrl = TextEditingController(
      text: widget.cliente.email ?? "",
    );
    telefonoCtrl = TextEditingController(
      text: widget.cliente.telefono ?? "",
    );
    direccionCtrl = TextEditingController(
      text: widget.cliente.direccion ?? "",
    );

    activo = widget.cliente.activo;
  }

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
      return "Campo obligatorio";
    }

    return null;
  }

  Future<void> guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    try {
      await ClientesApi.actualizarCliente(
        widget.cliente.id,
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
        activo: activo,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cliente actualizado"),
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

  Widget input(
    TextEditingController controller,
    String label, {
    bool obligatorio = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              10,
            ),
          ),
        ),
        validator: obligatorio ? requerido : null,
      ),
    );
  }

  Widget estadoCliente() {
    return SwitchListTile(
      value: activo,
      title: const Text("Cliente activo"),
      subtitle: Text(
        activo
            ? "Disponible para nuevas ventas"
            : "Oculto para nuevas ventas",
      ),
      onChanged: loading
          ? null
          : (value) {
              setState(() {
                activo = value;
              });
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar cliente"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              input(
                nombreCtrl,
                "Nombre",
                obligatorio: true,
              ),
              input(
                rutCtrl,
                "RUT",
                obligatorio: true,
              ),
              input(
                emailCtrl,
                "Email",
                keyboardType: TextInputType.emailAddress,
              ),
              input(
                telefonoCtrl,
                "Teléfono",
                keyboardType: TextInputType.phone,
              ),
              input(
                direccionCtrl,
                "Dirección",
              ),
              estadoCliente(),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : guardarCambios,
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Guardar cambios"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}