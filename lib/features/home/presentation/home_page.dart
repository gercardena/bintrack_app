import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/auth/subscription_access.dart';
import '../../../core/widgets/subscription_status_card.dart';

import '../../../core/auth/user_controller.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
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

  Future<void> abrir(BuildContext context, Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) await _refresh();
  }

  Future<void> confirmarLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          backgroundColor: scheme.surface,
          title: Text(
            "Cerrar sesión",
            style: TextStyle(color: scheme.onSurface),
          ),
          content: Text(
            "¿Quieres cerrar tu sesión en este dispositivo?",
            style: TextStyle(color: scheme.onSurfaceVariant),
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
    final scheme = Theme.of(context).colorScheme;
    final canOperate = SubscriptionAccess.fromProfile(
      UserController().user,
    ).canOperate;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("BINTRACK"),
        centerTitle: true,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
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
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
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
            color: canOperate ? AppColors.primary : Colors.blueGrey,
            onTap: canOperate
                ? () => abrir(context, const CreateSalePage())
                : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          _quickAccess(context),
          const SizedBox(height: AppSpacing.lg),
          _helpCard(context),
        ],
      ),
    );
  }

  Widget _subscriptionCard() =>
      SubscriptionStatusCard(profile: UserController().user);

  Widget _moduleDrawer(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;
    final canManageAccount =
        UserController().user?['puede_gestionar_cuenta'] == true;

    return Drawer(
      backgroundColor: scheme.surface,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.apps_outlined,
                    color: Colors.cyanAccent,
                    size: 30,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Módulos BINTRACK',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Accede a cada módulo sin recorrer el Inicio.',
                    style: TextStyle(color: muted),
                  ),
                ],
              ),
            ),
            Divider(color: scheme.outlineVariant),
            _drawerSection(context, 'Operación'),
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
            Divider(color: scheme.outlineVariant),
            _drawerSection(context, 'Catálogo y bodega'),
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
            Divider(color: scheme.outlineVariant),
            _drawerSection(context, 'Ayuda y cuenta'),
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
            Divider(color: scheme.outlineVariant),
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
                style: TextStyle(color: scheme.onSurface),
              ),
              subtitle: Text(
                'La preferencia queda guardada.',
                style: TextStyle(color: muted),
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

  Widget _drawerSection(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
    child: Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      enabled: enabled,
      leading: Icon(icon, color: enabled ? color : scheme.outline),
      title: Text(
        title,
        style: TextStyle(color: enabled ? scheme.onSurface : scheme.outline),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: enabled ? scheme.onSurfaceVariant : scheme.outline,
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

  Widget _quickAccess(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accesos frecuentes',
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _quickLink(
                context,
                title: 'Ventas',
                icon: Icons.point_of_sale,
                page: const SalesPage(),
              ),
              _quickLink(
                context,
                title: 'Inventario',
                icon: Icons.storage,
                page: const InventoryPage(),
              ),
              _quickLink(
                context,
                title: 'Envases',
                icon: Icons.warehouse,
                page: const WarehousesPage(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Para todos los módulos, abre el menú ☰ de la parte superior.',
            style: TextStyle(color: scheme.onSurfaceVariant, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _quickLink(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget page,
  }) {
    return OutlinedButton.icon(
      onPressed: () => abrir(context, page),
      icon: Icon(icon, size: 18),
      label: Text(title),
    );
  }

  Widget _helpCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Consejo: antes de crear productos con stock, "
              "registra una entrada de envases. Así el inventario "
              "sabrá cuántos envases físicos hay disponibles.",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
