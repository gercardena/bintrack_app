import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/auth/subscription_access.dart';
import '../../../core/widgets/subscription_status_card.dart';

import '../../../core/auth/user_controller.dart';
import '../../../core/theme/theme_controller.dart';
import '../../auth/presentation/logout.dart';
import '../../clientes/presentation/clientes_page.dart';
import '../../products/presentation/products_page.dart';
import '../../inventory/presentation/pages/inventory_page.dart';
import '../../warehouses/presentation/warehouses_page.dart';
import '../../sales/presentation/sales_page.dart';
import '../../sales/presentation/create_sale_page.dart';
import '../../invoices/presentation/invoices_page.dart';
import '../../payments/presentation/payments_page.dart';
import '../../reports/presentation/sales_report_page.dart';
import 'user_guide_page.dart';
import 'privacy_policy_page.dart';
import '../../account/presentation/account_shortcut.dart';
import '../../account/presentation/account_page.dart';
import '../../auth/presentation/change_password_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  Timer? _timer;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    UserController().addListener(_profileChanged);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed &&
          ModalRoute.of(context)?.isCurrent == true) {
        _refresh();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refresh();
    });
  }

  void _profileChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _refresh() async {
    if (_refreshing || !mounted) return;
    _refreshing = true;
    try {
      await UserController().loadUser();
    } finally {
      _refreshing = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    UserController().removeListener(_profileChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);

  Future<void> abrir(BuildContext context, Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) await _refresh();
  }

  Future<void> confirmarLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF172033),
          title: const Text(
            "Cerrar sesión",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "¿Quieres cerrar tu sesión en este dispositivo?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Cancelar"),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
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
    final canOperate = SubscriptionAccess.fromProfile(
      UserController().user,
    ).canOperate;
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
            tooltip: 'Actualizar suscripción',
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
          IconButton(
            tooltip: 'Cambiar contraseña',
            icon: const Icon(Icons.lock_reset_outlined),
            onPressed: () => abrir(context, const ChangePasswordPage()),
          ),
          IconButton(
            tooltip: "Cerrar sesión",
            icon: const Icon(Icons.logout),
            onPressed: () => confirmarLogout(context),
          ),
        ],
      ),
      drawer: _moduleDrawer(context),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _welcomeCard(),
          const SizedBox(height: 12),
          _subscriptionCard(),
          AccountShortcut(profile: UserController().user),
          const SizedBox(height: 16),
          _primaryAction(
            context,
            title: "Nueva venta",
            subtitle: canOperate
                ? "Crea una venta para un cliente activo."
                : "Solo lectura: no puedes crear ventas.",
            icon: Icons.add_shopping_cart,
            color: canOperate ? const Color(0xFF2563EB) : Colors.blueGrey,
            onTap: canOperate
                ? () => abrir(context, const CreateSalePage())
                : null,
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
                title: "Privacidad",
                subtitle: "Uso de datos",
                icon: Icons.privacy_tip,
                color: Colors.blueGrey,
                page: const PrivacyPolicyPage(),
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
                title: "Clientes",
                subtitle: "Registra compradores",
                icon: Icons.people,
                color: Colors.indigo,
                page: const ClientesPage(),
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
              _menuButton(
                context,
                title: "Reportes",
                subtitle: "Ventas y crédito",
                icon: Icons.analytics_outlined,
                color: Colors.lightGreen,
                page: const SalesReportPage(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _helpCard(),
        ],
      ),
    );
  }

  Widget _subscriptionCard() =>
      SubscriptionStatusCard(profile: UserController().user);

  Widget _moduleDrawer(BuildContext context) {
    final canManageAccount =
        UserController().user?['puede_gestionar_cuenta'] == true;

    return Drawer(
      backgroundColor: const Color(0xFF0F172A),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.apps_outlined, color: Colors.cyanAccent, size: 30),
                  SizedBox(height: 10),
                  Text(
                    'Módulos BINTRACK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Accede a cada módulo sin recorrer el Inicio.',
                    style: TextStyle(color: Colors.white60),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            _drawerSection('Operación'),
            _drawerItem(
              context,
              title: 'Nueva venta',
              icon: Icons.add_shopping_cart,
              color: Colors.blueAccent,
              page: const CreateSalePage(),
              enabled: SubscriptionAccess.fromProfile(
                UserController().user,
              ).canOperate,
            ),
            _drawerItem(
              context,
              title: 'Ventas',
              icon: Icons.point_of_sale,
              color: Colors.blue,
              page: const SalesPage(),
            ),
            _drawerItem(
              context,
              title: 'Pagos',
              icon: Icons.payments,
              color: Colors.teal,
              page: const PaymentsPage(),
            ),
            _drawerItem(
              context,
              title: 'Comprobantes',
              icon: Icons.receipt_long,
              color: Colors.deepPurpleAccent,
              page: const InvoicesPage(),
            ),
            _drawerItem(
              context,
              title: 'Reportes',
              icon: Icons.analytics_outlined,
              color: Colors.lightGreen,
              page: const SalesReportPage(),
            ),
            const Divider(color: Colors.white24),
            _drawerSection('Catálogo y bodega'),
            _drawerItem(
              context,
              title: 'Clientes',
              icon: Icons.people,
              color: Colors.indigoAccent,
              page: const ClientesPage(),
            ),
            _drawerItem(
              context,
              title: 'Productos',
              icon: Icons.inventory_2,
              color: Colors.green,
              page: const ProductsPage(),
            ),
            _drawerItem(
              context,
              title: 'Inventario',
              icon: Icons.storage,
              color: Colors.orangeAccent,
              page: const InventoryPage(),
            ),
            _drawerItem(
              context,
              title: 'Envases y bins',
              icon: Icons.warehouse,
              color: Colors.brown,
              page: const WarehousesPage(),
            ),
            const Divider(color: Colors.white24),
            _drawerSection('Ayuda y cuenta'),
            _drawerItem(
              context,
              title: 'Guía de usuario',
              icon: Icons.route,
              color: Colors.cyan,
              page: const UserGuidePage(),
            ),
            _drawerItem(
              context,
              title: 'Privacidad',
              icon: Icons.privacy_tip_outlined,
              color: Colors.blueGrey,
              page: const PrivacyPolicyPage(),
            ),
            if (canManageAccount)
              _drawerItem(
                context,
                title: 'Usuarios y suscripción',
                icon: Icons.manage_accounts_outlined,
                color: Colors.cyanAccent,
                page: const AccountPage(),
              ),
            const Divider(color: Colors.white24),
            SwitchListTile(
              secondary: Icon(
                ThemeController.instance.isDarkMode
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                color: Colors.amberAccent,
              ),
              title: Text(
                ThemeController.instance.isDarkMode
                    ? 'Modo oscuro'
                    : 'Modo claro',
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'La preferencia queda guardada.',
                style: TextStyle(color: Colors.white60),
              ),
              activeThumbColor: Colors.cyanAccent,
              value: ThemeController.instance.isDarkMode,
              onChanged: ThemeController.instance.setDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerSection(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
    child: Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: Colors.white54,
        fontWeight: FontWeight.w700,
        fontSize: 12,
        letterSpacing: 0.6,
      ),
    ),
  );

  Widget _drawerItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget page,
    bool enabled = true,
  }) {
    return ListTile(
      enabled: enabled,
      leading: Icon(icon, color: enabled ? color : Colors.white30),
      title: Text(
        title,
        style: TextStyle(color: enabled ? Colors.white : Colors.white38),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: enabled ? Colors.white54 : Colors.white24,
      ),
      onTap: enabled
          ? () {
              Navigator.pop(context);
              abrir(context, page);
            }
          : null,
    );
  }

  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF0EA5E9)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.22),
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
            style: TextStyle(color: Colors.white70, height: 1.35),
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
    required VoidCallback? onTap,
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
              color: color.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 42),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(subtitle, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
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

  Widget _menuGrid({required List<Widget> children}) {
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
    final cardColor = highlighted ? color.withValues(alpha: 0.18) : card;

    final borderColor = highlighted
        ? color.withValues(alpha: 0.45)
        : Colors.white.withValues(alpha: 0.06);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => abrir(context, page),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
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
              style: const TextStyle(fontSize: 12, color: Colors.white60),
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
              "Consejo: antes de crear productos con stock, "
              "registra una entrada de envases. Así el inventario "
              "sabrá cuántos envases físicos hay disponibles.",
              style: TextStyle(color: Colors.white, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
