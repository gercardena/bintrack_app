import 'package:flutter/material.dart';
import '../data/warehouses_api.dart';

class WarehousesPage extends StatefulWidget {
  const WarehousesPage({super.key});

  @override
  State<WarehousesPage> createState() => _WarehousesPageState();
}

class _WarehousesPageState extends State<WarehousesPage> {

  late Future<List<dynamic>> clientesFuture;

  @override
  void initState() {
    super.initState();

    print("LLAMANDO API CLIENTES");

    clientesFuture = WarehousesApi.getClientes();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bins / Warehouses'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: clientesFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          final clientes = snapshot.data!;

          if (clientes.isEmpty) {
            return const Center(child: Text("Sin clientes"));
          }

          return ListView.builder(
            itemCount: clientes.length,
            itemBuilder: (context, index) {

              final cliente = clientes[index];

              return ListTile(
                title: Text(cliente['nombre']),
                subtitle: Text(cliente['telefono'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
