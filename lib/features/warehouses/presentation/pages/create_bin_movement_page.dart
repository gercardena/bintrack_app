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

  final BinTypeService typeService =
      BinTypeService();

  final BinMovementService movementService =
      BinMovementService();

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

      final loadedTypes =
          await typeService.getBinTypes();

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

  bool validarFormulario() {
    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecciona un tipo de envase"),
        ),
      );
      return false;
    }

    if (selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecciona un cliente"),
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
            "La cantidad debe ser mayor que cero",
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
        depositoPagado:
            double.tryParse(
                  depositoController.text.trim(),
                ) ??
                0,
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
              "Movimiento creado correctamente",
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
              "Error al crear movimiento",
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
            "Error al crear movimiento: $e",
          ),
        ),
      );
    }
  }

  Widget selectorCliente() {
    return DropdownButtonFormField<BinClient>(
      value: selectedClient,
      isExpanded: true,
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
      decoration: const InputDecoration(
        labelText: "Cliente",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget selectorTipoEnvase() {
    return DropdownButtonFormField<BinType>(
      value: selectedType,
      isExpanded: true,
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
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget selectorMovimiento() {
    return DropdownButtonFormField<String>(
      value: movementType,
      isExpanded: true,
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
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget campoCantidad() {
    return TextField(
      controller: cantidadController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Cantidad",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget campoDeposito() {
    return TextField(
      controller: depositoController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Depósito pagado",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget campoReferencia() {
    return TextField(
      controller: referenciaController,
      decoration: const InputDecoration(
        labelText: "Referencia",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget botonGuardar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: saving ? null : saveMovement,
        child: saving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Text("Guardar movimiento"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo movimiento"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            selectorCliente(),
            const SizedBox(height: 16),
            selectorTipoEnvase(),
            const SizedBox(height: 16),
            selectorMovimiento(),
            const SizedBox(height: 16),
            campoCantidad(),
            const SizedBox(height: 16),
            campoDeposito(),
            const SizedBox(height: 16),
            campoReferencia(),
            const SizedBox(height: 24),
            botonGuardar(),
          ],
        ),
      ),
    );
  }
}