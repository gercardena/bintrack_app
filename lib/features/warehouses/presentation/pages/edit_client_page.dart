import 'package:flutter/material.dart';

import '../../data/models/bin_client_model.dart';
import '../../data/services/bin_client_service.dart';

class EditClientPage extends StatefulWidget {
  final BinClient client;

  const EditClientPage({
    super.key,
    required this.client,
  });

  @override
  State<EditClientPage> createState() =>
      _EditClientPageState();
}

class _EditClientPageState
    extends State<EditClientPage> {
  final _formKey = GlobalKey<FormState>();

  final service = BinClientService();

  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);

  late TextEditingController nombreController;
  late TextEditingController rutController;
  late TextEditingController emailController;
  late TextEditingController telefonoController;
  late TextEditingController direccionController;

  bool saving = false;

  @override
  void initState() {
    super.initState();

    nombreController = TextEditingController(
      text: widget.client.nombre,
    );

    rutController = TextEditingController(
      text: widget.client.rut,
    );

    emailController = TextEditingController(
      text: widget.client.email,
    );

    telefonoController = TextEditingController(
      text: widget.client.telefono,
    );

    direccionController = TextEditingController(
      text: widget.client.direccion,
    );
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

  String? requerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Campo obligatorio";
    }

    return null;
  }

  Future<void> saveClient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await service.updateClient(
        id: widget.client.id,
        nombre: nombreController.text.trim(),
        rut: rutController.text.trim(),
        email: emailController.text.trim(),
        telefono: telefonoController.text.trim(),
        direccion: direccionController.text.trim(),
        activo: widget.client.activo,
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "No fue posible actualizar el cliente: $e",
          ),
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
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.06),
          labelStyle: const TextStyle(
            color: Colors.white70,
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
              color: Colors.greenAccent,
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
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _introCard(),

              const SizedBox(height: 16),

              _sectionCard(
                title: "Datos principales",
                icon: Icons.badge,
                color: Colors.greenAccent,
                children: [
                  TextFormField(
                    controller: nombreController,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Nombre o razón social",
                    ),
                    validator: requerido,
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: rutController,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      labelText: "RUT",
                    ),
                    validator: requerido,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _sectionCard(
                title: "Datos de contacto",
                icon: Icons.contact_phone,
                color: Colors.cyanAccent,
                children: [
                  TextFormField(
                    controller: emailController,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Email",
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: telefonoController,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Teléfono",
                    ),
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: direccionController,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Dirección",
                    ),
                  ),

                  const SizedBox(height: 10),

                  _smallHelp(
                    "Estos datos ayudan a identificar al cliente "
                    "en movimientos y balances de envases.",
                  ),
                ],
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: saving ? null : saveClient,
                  icon: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    saving
                        ? "Guardando..."
                        : "Guardar cambios",
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _introCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF15803D),
            Color(0xFF0F766E),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.22),
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
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.client.nombre,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.25,
              ),
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
    return Row(
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
    );
  }
}