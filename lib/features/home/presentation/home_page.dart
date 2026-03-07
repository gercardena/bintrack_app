import 'package:flutter/material.dart';

import '../../clientes/presentation/clientes_page.dart';
import '../../products/presentation/products_page.dart';
import '../../inventory/presentation/inventory_page.dart';
import '../../warehouses/presentation/warehouses_page.dart';
import '../../sales/presentation/sales_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,

          children: [

            /// CLIENTES
            _menuButton(
              context,
              "Clientes",
              Icons.people,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ClientesPage(),
                  ),
                );
              },
            ),

            /// PRODUCTOS
            _menuButton(
              context,
              "Productos",
              Icons.inventory,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductsPage(),
                  ),
                );
              },
            ),

            /// INVENTARIO
            _menuButton(
              context,
              "Inventario",
              Icons.storage,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InventoryPage(),
                  ),
                );
              },
            ),

            /// BINS / WAREHOUSES
            _menuButton(
              context,
              "Bins",
              Icons.warehouse,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WarehousesPage(),
                  ),
                );
              },
            ),

            /// VENTAS
            _menuButton(
               context,
                "Ventas",
                Icons.point_of_sale,
               () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SalesPage(),
                    ),
                 );
              },
            ),

            /// FACTURAS
            _menuButton(
              context,
              "Facturas",
              Icons.receipt_long,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Pantalla Facturas próximamente"),
                  ),
                );
              },
            ),

            /// PAGOS
            _menuButton(
              context,
              "Pagos",
              Icons.payments,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Pantalla Pagos próximamente"),
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }

  /// Botón reutilizable
  Widget _menuButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {

    return GestureDetector(
      onTap: onTap,

      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),

          ],
        ),
      ),
    );
  }
}