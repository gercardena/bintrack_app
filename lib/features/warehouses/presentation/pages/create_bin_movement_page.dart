import 'package:flutter/material.dart';

import '../../data/models/bin_client_model.dart';
import '../../data/models/bin_type_model.dart';
import '../../data/services/bin_client_service.dart';
import '../../data/services/bin_type_service.dart';
import '../../data/services/bin_movement_service.dart';

class CreateBinMovementPage extends StatefulWidget {
  const CreateBinMovementPage({super.key});

  @override
  State<CreateBinMovementPage> createState() =>
      _CreateBinMovementPageState();
}

class _CreateBinMovementPageState
    extends State<CreateBinMovementPage> {
  final BinClientService clientService =
      BinClientService();

  final BinTypeService typeService = BinTypeService();

  final BinMovementService movementService =
      BinMovementService();

  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);

  List<BinClient> clients = [];
  List<BinType> types = [];

  BinClient? selectedClient;
  BinType? selectedType;

  String movementType = "entrada";

  final cantidadController = TextEditingController();
  final depositoController = TextEditingController();
  final referenciaController = TextEditingController();

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    cantidadController.dispose();
    depositoController.dispose();
    referenciaController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      final loadedClients =
          await clientService.getClients();

      final loadedTypes = await typeService.getBinTypes();

      if (!mounted) return;

      setState(() {
        clients = loadedClients;
        types = loadedTypes;

        if (clients.isNotEmpty) {
          selectedClient = clients.first;
        }

        if (types.isNotEmpty) {
          selectedType = types.first;
        }

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error cargando datos: $e",
          ),
        ),
      );
    }
  }

  String movementLabel(String value) {
    switch (value) {
      case "entrada":
        return "Entrada";
      case "prestamo":
        return "Préstamo";
      case "devolucion":
        return "Devolución";
      case "baja":
        return "Baja";
      default:
        return value;
    }
  }

  String movementDescription(String value) {
    switch (value) {
      case "entrada":
        return "Aumenta los envases físicos disponibles. No representa envases entregados a un cliente.";
      case "prestamo":
        return "Entrega envases a un cliente y aumenta su saldo pendiente.";
      case "devolucion":
        return "Registra envases que vuelven desde un cliente.";
      case "baja":
        return "Descuenta envases perdidos, rotos o no utilizables.";
      default:
        return "Movimiento de envases.";
    }
  }

  String clienteLabel() {
    if (movementType == "entrada") {
      return "Cliente de referencia / responsable";
    }

    return "Cliente";
  }

  String clienteHelp() {
    if (movementType == "entrada") {
      return "Las entradas aumentan stock físico; el cliente solo queda como referencia o responsable.";
    }

    if (movementType == "prestamo") {
      return "Selecciona el cliente que recibe los envases.";
    }

    if (movementType == "devolucion") {
      return "Selecciona el cliente que devuelve los envases.";
    }

    return "Selecciona el cliente asociado como referencia del movimiento.";
  }

  Color movementColor(String value) {
    switch (value) {
      case "entrada":
        return Colors.greenAccent;
      case "prestamo":
        return Colors.orangeAccent;
      case "devolucion":
        return Colors.cyanAccent;
      case "baja":
        return Colors.redAccent;
      default:
        return Colors.blueAccent;
    }
  }

  bool validarFormulario() {
    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Selecciona un tipo de envase.",
          ),
        ),
      );
      return false;
    }

    if (selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Selecciona un cliente de referencia.",
          ),
        ),
      );
      return false;
    }

    final cantidad =
        int.tryParse(cantidadController.text.trim()) ?? 0;

    if (cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "La cantidad debe ser mayor que cero.",
          ),
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> saveMovement() async {
    if (saving) return;

    if (!validarFormulario()) return;

    final deposito = double.tryParse(
          depositoController.text
              .trim()
              .replaceAll(",", "."),
        ) ??
        0;

    setState(() {
      saving = true;
    });

    try {
      final ok = await movementService.createMovement(
        cliente: selectedClient!.id,
        binType: selectedType!.id,
        tipoMovimiento: movementType,
        cantidad: int.parse(
          cantidadController.text.trim(),
        ),
        depositoPagado: deposito,
        referencia:
            referenciaController.text.trim().isEmpty
                ? "Movimiento ${movementLabel(movementType)}"
                : referenciaController.text.trim(),
      );

      if (!mounted) return;

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Movimiento creado correctamente.",
            ),
          ),
        );

        Navigator.pop(context, true);
      } else {
        setState(() {
          saving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "No fue posible crear el movimiento.",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "No fue posible crear el movimiento: $e",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
              color: Colors.orangeAccent,
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
          title: const Text("Nuevo movimiento"),
          centerTitle: true,
          backgroundColor: background,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _introCard(),
            const SizedBox(height: 16),
            _sectionCard(
              title: "Movimiento",
              icon: Icons.swap_horiz,
              color: movementColor(movementType),
              children: [
                selectorMovimiento(),
                const SizedBox(height: 10),
                _smallHelp(
                  movementDescription(movementType),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: "Envase y cliente",
              icon: Icons.inventory_2,
              color: Colors.cyanAccent,
              children: [
                selectorTipoEnvase(),
                const SizedBox(height: 12),
                selectorCliente(),
                const SizedBox(height: 10),
                _smallHelp(
                  clienteHelp(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: "Detalle",
              icon: Icons.edit_note,
              color: Colors.orangeAccent,
              children: [
                campoCantidad(),
                const SizedBox(height: 12),
                campoDeposito(),
                const SizedBox(height: 10),
                _smallHelp(
                  "El depósito pagado es una garantía asociada "
                  "a envases prestados. No es precio de venta.",
                ),
                const SizedBox(height: 12),
                campoReferencia(),
              ],
            ),
            const SizedBox(height: 28),
            botonGuardar(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget selectorCliente() {
    return DropdownButtonFormField<BinClient>(
      initialValue: selectedClient,
      isExpanded: true,
      dropdownColor: card,
      style: const TextStyle(
        color: Colors.white,
      ),
      items: clients.map((client) {
        return DropdownMenuItem<BinClient>(
          value: client,
          child: Text(
            client.nombre,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: saving
          ? null
          : (value) {
              setState(() {
                selectedClient = value;
              });
            },
      decoration: InputDecoration(
        labelText: clienteLabel(),
      ),
    );
  }

  Widget selectorTipoEnvase() {
    return DropdownButtonFormField<BinType>(
      initialValue: selectedType,
      isExpanded: true,
      dropdownColor: card,
      style: const TextStyle(
        color: Colors.white,
      ),
      items: types.map((type) {
        return DropdownMenuItem<BinType>(
          value: type,
          child: Text(
            type.nombre,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: saving
          ? null
          : (value) {
              setState(() {
                selectedType = value;
              });
            },
      decoration: const InputDecoration(
        labelText: "Tipo de envase",
      ),
    );
  }

  Widget selectorMovimiento() {
    return DropdownButtonFormField<String>(
      initialValue: movementType,
      isExpanded: true,
      dropdownColor: card,
      style: const TextStyle(
        color: Colors.white,
      ),
      items: const [
        DropdownMenuItem(
          value: "entrada",
          child: Text("Entrada"),
        ),
        DropdownMenuItem(
          value: "prestamo",
          child: Text("Préstamo"),
        ),
        DropdownMenuItem(
          value: "devolucion",
          child: Text("Devolución"),
        ),
        DropdownMenuItem(
          value: "baja",
          child: Text("Baja"),
        ),
      ],
      onChanged: saving
          ? null
          : (value) {
              if (value == null) return;

              setState(() {
                movementType = value;
              });
            },
      decoration: const InputDecoration(
        labelText: "Tipo de movimiento",
      ),
    );
  }

  Widget campoCantidad() {
    return TextField(
      controller: cantidadController,
      style: const TextStyle(
        color: Colors.white,
      ),
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Cantidad de envases",
      ),
    );
  }

  Widget campoDeposito() {
    return TextField(
      controller: depositoController,
      style: const TextStyle(
        color: Colors.white,
      ),
      keyboardType:
          const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: const InputDecoration(
        labelText: "Depósito pagado",
        prefixText: "\$",
      ),
    );
  }

  Widget campoReferencia() {
    return TextField(
      controller: referenciaController,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: const InputDecoration(
        labelText: "Referencia",
        hintText: "Ej: Stock inicial, guía, nota interna",
      ),
    );
  }

  Widget botonGuardar() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: saving ? null : saveMovement,
        icon: saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.save),
        label: const Text("Guardar movimiento"),
      ),
    );
  }

  Widget _introCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEA580C),
            Color(0xFFEAB308),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.add_box,
            color: Colors.white,
            size: 32,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Registra un movimiento para actualizar el control "
              "de envases físicos y saldos por cliente.",
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