import 'package:flutter/material.dart';

import 'pages/bin_types_page.dart';
import 'pages/bin_movements_page.dart';
import 'pages/bin_balance_page.dart';

class WarehousesPage extends StatelessWidget {
  const WarehousesPage({super.key});

  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);

  void abrir(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text("Envases"),
        centerTitle: true,
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _introCard(),

          const SizedBox(height: 18),

          _sectionTitle("Qué necesitas hacer"),

          _actionTile(
            context,
            title: "Prestar o recibir bins",
            subtitle: "Préstamo, devolución, entrada o baja",
            icon: Icons.swap_horiz,
            color: Colors.orangeAccent,
            page: const BinMovementsPage(),
            highlighted: true,
          ),
          _actionTile(
            context,
            title: "Bins por devolver",
            subtitle: "Ver quién tiene envases pendientes",
            icon: Icons.assessment,
            color: Colors.deepPurpleAccent,
            page: const BinBalancePage(initialOnlyPending: true),
          ),
          _actionTile(
            context,
            title: "Garantías retenidas",
            subtitle: "Dinero recibido aún pendiente",
            icon: Icons.savings_outlined,
            color: Colors.greenAccent,
            page: const BinBalancePage(initialOnlyDepositRetained: true),
          ),
          _actionTile(
            context,
            title: "Historial de movimientos",
            subtitle: "Buscar préstamos, devoluciones y entradas",
            icon: Icons.history,
            color: Colors.cyanAccent,
            page: const BinMovementsPage(historyOnly: true),
          ),

          const SizedBox(height: 20),

          _sectionTitle("Configuración"),
          _settingsLink(context),

          const SizedBox(height: 20),

          _helpCard(),
        ],
      ),
    );
  }

  Widget _introCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF92400E), Color(0xFFEA580C)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warehouse, color: Colors.white, size: 34),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Presta bins, recibe devoluciones y revisa rápidamente "
              "quién debe envases o tiene una garantía retenida.",
              style: TextStyle(color: Colors.white, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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

  Widget _settingsLink(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => abrir(context, const BinTypesPage()),
      icon: const Icon(Icons.inventory_2),
      label: const Text("Tipos de bins y envases"),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        foregroundColor: Colors.blueAccent,
        padding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget page,
    bool highlighted = false,
  }) {
    final cardColor = highlighted ? color.withValues(alpha: 0.16) : card;

    final borderColor = highlighted
        ? color.withValues(alpha: 0.42)
        : Colors.white.withValues(alpha: 0.06);

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => abrir(context, page),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _helpCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.35)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.amber),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Consejo: una venta con envase crea el préstamo del bin "
              "automáticamente. Usa esta sección para movimientos "
              "realizados fuera de una venta.",
              style: TextStyle(color: Colors.white, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
