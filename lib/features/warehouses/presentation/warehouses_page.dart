import 'package:flutter/material.dart';
import 'pages/bin_types_page.dart';
import 'pages/bin_clients_page.dart';
import 'pages/bin_movements_page.dart';

class WarehousesPage extends StatelessWidget {
  const WarehousesPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bins / Warehouses'),
      ),

      body: ListView(
        children: [

          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text("Tipos de envase"),
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BinTypesPage(),
                ),
              );

            },
          ),

          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Clientes"),
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BinClientsPage(),
                ),
              );

            },
          ),

          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text("Movimientos"),
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BinMovementsPage(),
                ),
              );

            },
          ),

        ],
      ),
    );
  }
}
