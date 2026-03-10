import 'package:flutter/material.dart';

import '../../clientes/presentation/clientes_page.dart';
import '../../products/presentation/products_page.dart';
import '../../inventory/presentation/inventory_page.dart';
import '../../warehouses/presentation/warehouses_page.dart';
import '../../sales/presentation/sales_page.dart';
import '../../invoices/presentation/invoices_page.dart';
import '../../payments/presentation/payments_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("BINTRACK"),
        centerTitle: true,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InvoicesPage(),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaymentsPage(),
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }

  /// BOTÓN REUTILIZABLE DEL DASHBOARD
  Widget _menuButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),

          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              size: 42,
              color: Colors.blue,
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

          ],
        ),
      ),
    );
  }
}