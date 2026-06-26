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

  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);

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

    final deposito = double.tryParse(
      depositoController.text.trim().replaceAll(",", "."),
    );

    if (deposito == null || deposito < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Ingresa un valor de depósito válido.",
          ),
        ),
      );
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
        valorDeposito: deposito,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Tipo de envase creado correctamente.",
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "No fue posible crear el tipo de envase: $e",
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
  void dispose() {
    nombreController.dispose();
    materialController.dispose();
    depositoController.dispose();

    super.dispose();
  }

  String? requerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Campo obligatorio";
    }

    return null;
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
          prefixStyle: const TextStyle(
            color: Colors.white,
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
              color: Colors.blueAccent,
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
          title: const Text("Nuevo tipo de envase"),
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
                title: "Identificación",
                icon: Icons.inventory_2,
                color: Colors.blueAccent,
                children: [
                  TextFormField(
                    controller: nombreController,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Nombre del envase",
                      hintText: "Ej: Bin Azul",
                    ),
                    validator: requerido,
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: tipo,
                    dropdownColor: card,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Tipo",
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
                    onChanged: saving
                        ? null
                        : (value) {
                            if (value == null) return;

                            setState(() {
                              tipo = value;
                            });
                          },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: materialController,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Material",
                      hintText: "Ej: Plástico, madera",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _sectionCard(
                title: "Depósito",
                icon: Icons.savings_outlined,
                color: Colors.greenAccent,
                children: [
                  TextFormField(
                    controller: depositoController,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Valor depósito",
                      prefixText: "\$",
                    ),
                    validator: requerido,
                  ),

                  const SizedBox(height: 10),

                  _smallHelp(
                    "Este valor representa la garantía por cada envase "
                    "prestado a un cliente. Puede ser 0 si no aplica.",
                  ),
                ],
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: saving ? null : guardar,
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
                        : "Guardar tipo de envase",
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
            Color(0xFF1D4ED8),
            Color(0xFF0EA5E9),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.add_box,
            color: Colors.white,
            size: 32,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Crea un tipo de envase para controlar entradas, "
              "préstamos, devoluciones y depósitos.",
              style: TextStyle(
                color: Colors.white,
                height: 1.35,
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