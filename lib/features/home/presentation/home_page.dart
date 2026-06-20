import 'package:flutter/material.dart';

import '../../clientes/presentation/clientes_page.dart';
import '../../products/presentation/products_page.dart';
import '../../inventory/presentation/pages/inventory_page.dart';
import '../../warehouses/presentation/warehouses_page.dart';
import '../../sales/presentation/sales_page.dart';
import '../../sales/presentation/create_sale_page.dart';
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
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // NUEVA VENTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateSalePage(),
                    ),
                  );
                },
                child: const Text("➕ Nueva Venta"),
              ),
            ),

            const SizedBox(height: 10),

            // INVENTARIO RÁPIDO
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.orange,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InventoryPage(),
                    ),
                  );
                },
                child: const Text("📦 Inventario"),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,

                children: [

                  // ① TIPOS DE ENVASE
                  _menuButton(
                    context,
                    "① Tipos de Envase",
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

                  // ② PRODUCTOS
                  _menuButton(
                    context,
                    "② Productos",
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

                  // ③ INVENTARIO
                  _menuButton(
                    context,
                    "③ Inventario",
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

                  // ④ CLIENTES
                  _menuButton(
                    context,
                    "④ Clientes",
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

                  // ⑤ VENTAS
                  _menuButton(
                    context,
                    "⑤ Ventas",
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

                  // ⑥ FACTURAS
                  _menuButton(
                    context,
                    "⑥ Facturas",
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

                  // ⑦ PAGOS
                  _menuButton(
                    context,
                    "⑦ Pagos",
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
          ],
        ),
      ),
    );
  }

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
              textAlign: TextAlign.center,
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