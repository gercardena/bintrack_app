import 'package:flutter/material.dart';
import '../../data/services/bin_movement_service.dart';
import '../../data/models/bin_movement_model.dart';

class BinMovementsPage extends StatefulWidget {
  const BinMovementsPage({super.key});

  @override
  State<BinMovementsPage> createState() => _BinMovementsPageState();
}

class _BinMovementsPageState extends State<BinMovementsPage> {

  final BinMovementService service = BinMovementService();

  List<BinMovement> movements = [];

  @override
  void initState() {
    super.initState();
    loadMovements();
  }

  Future<void> loadMovements() async {

    final data = await service.getMovements();

    setState(() {
      movements = data;
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Movimientos de Bins"),
      ),

      body: movements.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: movements.length,
              itemBuilder: (context, index) {

                final movement = movements[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(

                    title: Text(
                      movement.tipoMovimiento,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text("Cantidad: ${movement.cantidad}"),

                        Text("Cliente ID: ${movement.cliente}"),

                        Text("Fecha: ${movement.fecha}"),

                        Text(
                          "Depósito pagado: ${movement.depositoPagado}",
                        ),

                      ],
                    ),
                  ),
                );

              },
            ),

    );

  }
}