import 'package:flutter/material.dart';
import '../../../core/widgets/subscription_status_card.dart';
import '../data/account_service.dart';
import '../models/account_summary.dart';
import 'secondary_form_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key, this.service});
  final AccountService? service;
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late final AccountService _service;
  late Future<AccountSummary> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? AccountService();
    _future = _service.load();
  }

  Future<void> _reload() async {
    final future = _service.load();
    setState(() {
      _future = future;
    });
    try {
      await future;
    } catch (_) {
      /* FutureBuilder displays a retry action. */
    }
  }

  String _date(String? value) {
    final date = value == null ? null : DateTime.tryParse(value)?.toLocal();
    if (date == null) return 'Sin período asignado';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<bool> _confirm(String title, String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Text(message, style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continuar'),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _edit(AccountSummary summary, [SecondaryUser? user]) async {
    if (_busy) return;
    if (user == null) {
      final confirmed = await _confirm(
        'Agregar secundario',
        'El adicional tiene un valor de ${clp(summary.additionPrice)} completo, sin prorrateo, y comparte el vencimiento del principal: ${_date(summary.endDate)}.\n\nEn esta etapa de pruebas no se realizará ningún cobro ni se renovará la suscripción.',
      );
      if (!confirmed || !mounted) return;
    }
    if (!mounted) return;
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SecondaryFormPage(service: _service, user: user),
      ),
    );
    if (saved == true && mounted) await _reload();
  }

  Future<void> _toggle(AccountSummary summary, SecondaryUser user) async {
    if (_busy) return;
    final confirmed = await _confirm(
      user.active ? 'Desactivar secundario' : 'Reactivar secundario',
      user.active
          ? '${user.username} perderá el acceso. Su cuenta y su historial se conservarán. No se generarán devoluciones ni cambios al período vigente.'
          : 'Se habilitará el acceso de ${user.username}, con el vencimiento del principal: ${_date(summary.endDate)}. El adicional es de ${clp(summary.additionPrice)}, sin prorrateo. En esta etapa no se realizarán cobros.',
    );
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    try {
      await _service.update(user.id, {'activo': !user.active});
      if (!mounted) return;
      await _reload();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: ThemeData.dark(useMaterial3: true),
    child: Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(title: const Text('Usuarios y suscripción')),
      body: FutureBuilder<AccountSummary>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _reload,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }
          final summary = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (summary.subscriptionAccess != null) ...[
                  SubscriptionStatusCard(
                    profile: {
                      'suscripcion_acceso': summary.subscriptionAccess,
                      'puede_gestionar_cuenta': true,
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Principal: ${summary.owner}',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${summary.activeCount} de ${summary.maxCount} secundarios activos',
                        ),
                        const SizedBox(height: 12),
                        Text(
                          summary.selectedPlan == null
                              ? 'Revisar configuración de la cuenta'
                              : '${clp(summary.selectedPlan!.price)} CLP / mes',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.cyanAccent,
                          ),
                        ),
                        const Text(
                          'Referencia mensual según usuarios activos. Precio final.',
                        ),
                        const SizedBox(height: 12),
                        Text('Vencimiento actual: ${_date(summary.endDate)}'),
                        if (summary.subscriptionAccess == null)
                          Text(
                            summary.subscriptionActive
                                ? 'Suscripción vigente'
                                : 'Suscripción pendiente o vencida',
                          ),
                        const SizedBox(height: 12),
                        const Text(
                          'Configuración local. No se realizan cobros ni se modifica el período vigente al gestionar usuarios.',
                          style: TextStyle(color: Colors.amberAccent),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Planes mensuales',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                for (final plan in summary.plans)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      plan.secondaryCount == 0
                          ? 'Solo principal'
                          : 'Principal + ${plan.secondaryCount} secundario(s)',
                    ),
                    trailing: Text(clp(plan.price)),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Usuarios secundarios',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Mismos permisos operativos. Solo el principal administra usuarios y suscripción.',
                ),
                if (summary.needsReview)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Esta cuenta requiere revisión. Se conservaron sus usuarios existentes.',
                      style: TextStyle(color: Colors.amberAccent),
                    ),
                  ),
                if (summary.users.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Todavía no hay usuarios secundarios.'),
                  ),
                for (final user in summary.users)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.username,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('${user.firstName} ${user.lastName}'.trim()),
                          Text(user.email),
                          Text(
                            user.active ? 'Activo' : 'Inactivo',
                            style: TextStyle(
                              color: user.active
                                  ? Colors.greenAccent
                                  : Colors.amberAccent,
                            ),
                          ),
                          Wrap(
                            spacing: 12,
                            children: [
                              TextButton.icon(
                                onPressed: _busy
                                    ? null
                                    : () => _edit(summary, user),
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Editar'),
                              ),
                              TextButton.icon(
                                onPressed:
                                    _busy || (!user.active && !summary.canAdd)
                                    ? null
                                    : () => _toggle(summary, user),
                                icon: Icon(
                                  user.active
                                      ? Icons.block
                                      : Icons.person_add_alt,
                                ),
                                label: Text(
                                  user.active ? 'Desactivar' : 'Reactivar',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: !_busy && summary.canAdd
                      ? () => _edit(summary)
                      : null,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Agregar secundario'),
                ),
                if (!summary.canAdd)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Se alcanzó el máximo de dos secundarios activos.',
                    ),
                  ),
                if (_busy) const LinearProgressIndicator(),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    ),
  );
}
