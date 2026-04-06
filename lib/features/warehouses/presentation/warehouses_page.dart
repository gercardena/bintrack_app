import 'package:flutter/material.dart';
import 'pages/bin_types_page.dart';
import 'pages/bin_clients_page.dart';
import 'pages/bin_movements_page.dart';
import 'pages/bin_balance_page.dart';

class WarehousesPage extends StatelessWidget {
  const WarehousesPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text('Bins / Warehouses'),
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),

        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [

            _buildCard(
              context,
              title: "Tipos de envase",
              icon: Icons.inventory_2,
              color: Colors.blue,
              page: const BinTypesPage(),
            ),

            _buildCard(
              context,
              title: "Clientes",
              icon: Icons.people,
              color: Colors.green,
              page: const BinClientsPage(),
            ),

            _buildCard(
              context,
              title: "Movimientos",
              icon: Icons.swap_horiz,
              color: Colors.orange,
              page: const BinMovementsPage(),
            ),

            _buildCard(
              context,
              title: "Balance",
              icon: Icons.assessment,
              color: Colors.deepPurple,
              page: const BinBalancePage(),
            ),

          ],
        ),
      ),
    );
  }

  // 🔥 CARD REUTILIZABLE
  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget page,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },

      borderRadius: BorderRadius.circular(16),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // 🔵 ICONO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),

            const SizedBox(height: 12),

            // 📄 TEXTO
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

          ],
        ),
      ),
    );
  }
}