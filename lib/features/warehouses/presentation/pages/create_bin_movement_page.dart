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

  String movementType = "prestamo";

  final cantidadController =
      TextEditingController();

  final depositoController =
      TextEditingController();

  final referenciaController =
      TextEditingController();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {

    try {

      final loadedClients =
          await clientService.getClients();

      final loadedTypes =
          await typeService.getBinTypes();

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

      print(e);

      setState(() {
        loading = false;
      });

    }
  }

  Future<void> saveMovement() async {

    if (selectedClient == null ||
        selectedType == null) {
      return;
    }

    final ok =
        await movementService.createMovement(
      cliente: selectedClient!.id,
      binType: selectedType!.id,
      tipoMovimiento: movementType,
      cantidad:
          int.tryParse(cantidadController.text) ?? 0,
      depositoPagado:
          double.tryParse(depositoController.text) ?? 0,
      referencia: referenciaController.text,
    );

    if (!mounted) return;

    if (ok) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Movimiento creado correctamente"),
        ),
      );

      Navigator.pop(context, true);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Error al crear movimiento"),
        ),
      );

    }
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
        title: const Text(
          "Nuevo Movimiento",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [

            const Text("Cliente"),

            DropdownButton<BinClient>(
              value: selectedClient,
              isExpanded: true,
              items: clients.map((client) {
                return DropdownMenuItem(
                  value: client,
                  child: Text(client.nombre),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedClient = value;
                });
              },
            ),

            const SizedBox(height: 16),

            const Text("Tipo de Envase"),

            DropdownButton<BinType>(
              value: selectedType,
              isExpanded: true,
              items: types.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.nombre),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
              },
            ),

            const SizedBox(height: 16),

            const Text("Tipo Movimiento"),

            DropdownButton<String>(
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
              onChanged: (value) {
                setState(() {
                  movementType = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: cantidadController,
              keyboardType:
                  TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Cantidad",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: depositoController,
              keyboardType:
                  TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Depósito Pagado",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: referenciaController,
              decoration: const InputDecoration(
                labelText: "Referencia",
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: saveMovement,
              child: const Text(
                "Guardar Movimiento",
              ),
            ),

          ],
        ),
      ),
    );
  }
}