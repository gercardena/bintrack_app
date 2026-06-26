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

  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);

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
          content: Text(
            "Cliente actualizado correctamente.",
          ),
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
          content: Text(
            "No fue posible actualizar el cliente: $e",
          ),
        ),
      );
    }
  }

  Widget input(
    TextEditingController controller,
    String label, {
    bool obligatorio = false,
    TextInputType? keyboardType,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
        ),
        validator: obligatorio ? requerido : null,
      ),
    );
  }

  Widget estadoCliente() {
    final color =
        activo ? Colors.greenAccent : Colors.orangeAccent;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.30),
        ),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: activo,
        activeColor: Colors.greenAccent,
        title: Text(
          activo ? "Cliente activo" : "Cliente inactivo",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          activo
              ? "Disponible para nuevas ventas."
              : "No aparecerá como opción recomendada para nuevas ventas, pero conserva su historial.",
          style: const TextStyle(
            color: Colors.white60,
            height: 1.3,
          ),
        ),
        onChanged: loading
            ? null
            : (value) {
                setState(() {
                  activo = value;
                });
              },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.06),
          labelStyle: const TextStyle(
            color: Colors.white70,
          ),
          hintStyle: const TextStyle(
            color: Colors.white38,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.indigoAccent,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.redAccent,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.redAccent,
            ),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: const Text("Editar cliente"),
          centerTitle: true,
          backgroundColor: background,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _introCard(),

                const SizedBox(height: 16),

                _sectionCard(
                  title: "Datos principales",
                  icon: Icons.badge,
                  color: Colors.indigoAccent,
                  children: [
                    input(
                      nombreCtrl,
                      "Nombre o razón social",
                      obligatorio: true,
                    ),
                    input(
                      rutCtrl,
                      "RUT",
                      obligatorio: true,
                      hintText: "Ej: 11111111-1",
                    ),
                    _smallHelp(
                      "El RUT será validado por el sistema. "
                      "Puedes ingresarlo con puntos o sin puntos.",
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _sectionCard(
                  title: "Datos de contacto",
                  icon: Icons.contact_phone,
                  color: Colors.cyanAccent,
                  children: [
                    input(
                      emailCtrl,
                      "Email",
                      keyboardType:
                          TextInputType.emailAddress,
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
                    _smallHelp(
                      "Estos datos ayudan para ventas, facturas "
                      "y seguimiento comercial.",
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _sectionCard(
                  title: "Estado del cliente",
                  icon: Icons.toggle_on,
                  color: activo
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                  children: [
                    estadoCliente(),
                  ],
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        loading ? null : guardarCambios,
                    icon: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: const Text("Guardar cambios"),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _introCard() {
    final statusColor =
        activo ? Colors.greenAccent : Colors.orangeAccent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: activo
              ? const [
                  Color(0xFF4F46E5),
                  Color(0xFF0EA5E9),
                ]
              : const [
                  Color(0xFF92400E),
                  Color(0xFFB45309),
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.person,
            color: Colors.white,
            size: 34,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.cliente.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activo
                      ? "Cliente disponible para operar."
                      : "Cliente inactivo, conserva historial.",
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _smallHelp(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 2,
        bottom: 4,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: Colors.white54,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white60,
                height: 1.3,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}