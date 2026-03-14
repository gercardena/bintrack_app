import 'package:flutter/material.dart';
import '../../data/services/bin_client_service.dart';
import '../../data/models/bin_client_model.dart';

class BinClientsPage extends StatefulWidget {

  const BinClientsPage({super.key});

  @override
  State<BinClientsPage> createState() => _BinClientsPageState();
}

class _BinClientsPageState extends State<BinClientsPage> {

  final BinClientService service = BinClientService();

  List<BinClient> clients = [];

  @override
  void initState() {
    super.initState();
    loadClients();
  }

  Future<void> loadClients() async {

    final data = await service.getClients();

    setState(() {
      clients = data;
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Clientes de Bins"),
      ),

      body: clients.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {

                final client = clients[index];

                return ListTile(
                  title: Text(client.nombre),
                  subtitle: Text(client.telefono),
                );

              },
            ),

    );

  }

}