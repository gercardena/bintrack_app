import 'package:flutter/material.dart';

import '../../auth/presentation/logout.dart';
import '../../clientes/presentation/clientes_page.dart';
import '../../products/presentation/products_page.dart';
import '../../inventory/presentation/pages/inventory_page.dart';
import '../../warehouses/presentation/warehouses_page.dart';
import '../../sales/presentation/sales_page.dart';
import '../../sales/presentation/create_sale_page.dart';
import '../../invoices/presentation/invoices_page.dart';
import '../../payments/presentation/payments_page.dart';
import 'user_guide_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);

  void abrir(
    BuildContext context,
    Widget page,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  Future<void> confirmarLogout(
    BuildContext context,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF172033),
          title: const Text(
            "Cerrar sesión",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: const Text(
            "¿Quieres cerrar tu sesión en este dispositivo?",
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text("Cancelar"),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text("Cerrar sesión"),
            ),
          ],
        );
      },
    );

    if (confirm == true && context.mounted) {
      await Logout.execute(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text("BINTRACK"),
        centerTitle: true,
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: "Cerrar sesión",
            icon: const Icon(Icons.logout),
            onPressed: () => confirmarLogout(
              context,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _welcomeCard(),
          const SizedBox(height: 16),
          _primaryAction(
            context,
            title: "Nueva venta",
            subtitle: "Crea una venta para un cliente activo.",
            icon: Icons.add_shopping_cart,
            color: const Color(0xFF2563EB),
            onTap: () => abrir(
              context,
              const CreateSalePage(),
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle("Primeros pasos"),
          _menuGrid(
            children: [
              _menuButton(
                context,
                title: "Guía de usuario",
                subtitle: "Aprende el flujo",
                icon: Icons.route,
                color: Colors.cyan,
                page: const UserGuidePage(),
                highlighted: true,
              ),
              _menuButton(
                context,
                title: "Clientes",
                subtitle: "Registra compradores",
                icon: Icons.people,
                color: Colors.indigo,
                page: const ClientesPage(),
              ),
              _menuButton(
                context,
                title: "Envases",
                subtitle: "Tipos y movimientos",
                icon: Icons.warehouse,
                color: Colors.brown,
                page: const WarehousesPage(),
              ),
              _menuButton(
                context,
                title: "Productos",
                subtitle: "Presentaciones y stock",
                icon: Icons.inventory_2,
                color: Colors.green,
                page: const ProductsPage(),
              ),
              _menuButton(
                context,
                title: "Inventario",
                subtitle: "Disponibles y llenos",
                icon: Icons.storage,
                color: Colors.orange,
                page: const InventoryPage(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _sectionTitle("Operación diaria"),
          _menuGrid(
            children: [
              _menuButton(
                context,
                title: "Ventas",
                subtitle: "Borradores y estados",
                icon: Icons.point_of_sale,
                color: Colors.blue,
                page: const SalesPage(),
              ),
              _menuButton(
                context,
                title: "Pagos",
                subtitle: "Ventas pagadas",
                icon: Icons.payments,
                color: Colors.teal,
                page: const PaymentsPage(),
              ),
              _menuButton(
                context,
                title: "Comprobantes",
                subtitle: "Respaldos internos",
                icon: Icons.receipt_long,
                color: Colors.deepPurple,
                page: const InvoicesPage(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _helpCard(),
        ],
      ),
    );
  }

  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1D4ED8),
            Color(0xFF0EA5E9),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(
              alpha: 0.22,
            ),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gestiona tu operación",
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Clientes, envases, productos, ventas, pagos "
            "e inventario conectados en un solo flujo.",
            style: TextStyle(
              color: Colors.white70,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryAction(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(
                alpha: 0.35,
              ),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 42,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _menuGrid({
    required List<Widget> children,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.10,
      children: children,
    );
  }

  Widget _menuButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget page,
    bool highlighted = false,
  }) {
    final cardColor = highlighted
        ? color.withValues(alpha: 0.18)
        : card;

    final borderColor = highlighted
        ? color.withValues(alpha: 0.45)
        : Colors.white.withValues(alpha: 0.06);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => abrir(
        context,
        page,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(
                  alpha: 0.18,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _helpCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.amber.withValues(
            alpha: 0.35,
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Colors.amber,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Consejo: antes de crear productos con stock, "
              "registra una entrada de envases. Así el inventario "
              "sabrá cuántos envases físicos hay disponibles.",
              style: TextStyle(
                color: Colors.white,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}