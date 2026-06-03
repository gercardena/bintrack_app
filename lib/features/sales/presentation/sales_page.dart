import 'package:flutter/material.dart';

import '../../../core/theme/spacing.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_section_title.dart';
import '../../../core/widgets/primary_button.dart';

import '../../auth/presentation/protected_page.dart';

import '../data/sales_service.dart';
import '../models/sale_model.dart';

import 'create_sale_page.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final SalesService _service = SalesService();

  List<Sale> sales = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarVentas();
  }

  Future<void> cargarVentas() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    try {
      final data = await _service.getSales();

      if (!mounted) return;

      setState(() {
        sales = data;
        loading = false;
      });
    } catch (e) {
      print("ERROR SALES: $e");

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  // =========================================
  // 🔥 CONFIRMAR
  // =========================================

  Future<void> _confirm(int id) async {
    try {
      await _service.confirmSale(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Venta confirmada"),
        ),
      );

      await cargarVentas();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  // =========================================
  // 🔥 PAGAR
  // =========================================

  Future<void> _pay(int id) async {
    try {
      await _service.paySale(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Venta pagada"),
        ),
      );

      await cargarVentas();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  // =========================================
  // 🔥 FACTURAR
  // =========================================

  Future<void> _invoice(int id) async {
    try {
      await _service.generateInvoice(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Factura generada"),
        ),
      );

      await cargarVentas();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  // =========================================
  // 🔥 UI
  // =========================================

  @override
  Widget build(BuildContext context) {
    return ProtectedPage(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Ventas"),
        ),

        // =====================================
        // FAB
        // =====================================

        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateSalePage(),
              ),
            );

            if (result == true) {
              cargarVentas();
            }
          },
          child: const Icon(Icons.add),
        ),

        // =====================================
        // BODY
        // =====================================

        body: loading
            ? const AppLoader()
            : RefreshIndicator(
                onRefresh: cargarVentas,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(
                    AppSpacing.screenPadding,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // =================================
                      // HEADER
                      // =================================

                      const AppSectionTitle(
                        title: "Ventas",
                        subtitle:
                            "Gestiona ventas, pagos y facturación.",
                      ),

                      const SizedBox(
                        height: AppSpacing.lg,
                      ),

                      // =================================
                      // EMPTY STATE
                      // =================================

                      if (sales.isEmpty)
                        const AppEmptyState(
                          title:
                              "No hay ventas registradas",
                          message:
                              "Las ventas aparecerán aquí.",
                          icon: Icons.point_of_sale,
                        )

                      // =================================
                      // LISTADO
                      // =================================

                      else
                        Column(
                          children: sales.map((sale) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: _saleCard(sale),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // =========================================
  // 🔥 CARD VENTA
  // =========================================

  Widget _saleCard(Sale sale) {
    return AppCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ===================================
          // NUMERO
          // ===================================

          Text(
            "Venta #${sale.numero}",
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          // ===================================
          // INFO
          // ===================================

          Text(
            "Cliente: ${sale.clienteNombre ?? ''}",
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          Text(
            "Estado: ${sale.estado}",
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          Text(
            "Total: \$${sale.total}",
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          // ===================================
          // ACTIONS
          // ===================================

          if (sale.estado == "draft")
            PrimaryButton(
              text: "Confirmar Venta",
              onPressed: () => _confirm(sale.id),
            ),

          if (sale.estado == "confirmed")
            PrimaryButton(
              text: "Registrar Pago",
              onPressed: () => _pay(sale.id),
            ),

          if (sale.estado == "paid")
            PrimaryButton(
              text: "Generar Factura",
              onPressed: () => _invoice(sale.id),
            ),
        ],
      ),
    );
  }
}