import 'package:flutter/material.dart';
import '../../data/services/bin_client_service.dart';
import '../../data/models/bin_client_model.dart';

import 'create_client_page.dart';
import 'edit_client_page.dart';

class BinClientsPage extends StatefulWidget {

const BinClientsPage({super.key});

@override
State createState() => _BinClientsPageState();
}

class _BinClientsPageState extends State {

final BinClientService service = BinClientService();

List<BinClient> clients = [];

@override
void initState() {
super.initState();
loadClients();
}

Future<void> loadClients() async {

  final List<BinClient> data =
      await service.getClients();

  setState(() {
    clients = data;
  });

}

@override
Widget build(BuildContext context) {

return Scaffold(

  appBar: AppBar(

    title: const Text("Clientes de Bins"),

    actions: [

      IconButton(

        icon: const Icon(Icons.add),

        onPressed: () async {

          final result = await Navigator.push(

            context,

            MaterialPageRoute(
              builder: (_) =>
                  const CreateClientPage(),
            ),
          );

          if (result == true) {
            loadClients();
          }
        },
      ),
    ],
  ),

  body: clients.isEmpty
      ? const Center(
          child: CircularProgressIndicator(),
        )
      : ListView.builder(

          itemCount: clients.length,

          itemBuilder: (context, index) {

            final client = clients[index];

            return Card(

              margin: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),

              child: ListTile(

                 onTap: () async {

                   final result =
                       await Navigator.push(

                     context,

                      MaterialPageRoute(
                         builder: (_) => EditClientPage(
                           client: client,
                        ),
                      ),
               );

    if (result == true) {
      loadClients();
    }
  },

  title: Text(client.nombre),

  subtitle: Text(
    "${client.rut}\n${client.telefono}",
  ),

  isThreeLine: true,

  trailing: const Icon(
    Icons.edit,
  ),
),
            );
          },
        ),
);

}
}