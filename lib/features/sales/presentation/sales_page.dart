import 'package:flutter/material.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_section_title.dart';
import '../../../core/widgets/primary_button.dart';

import '../../auth/presentation/protected_page.dart';

import '../data/models/sale_model.dart';
import '../data/services/sale_service.dart';

import 'create_sale_page.dart';
import 'sale_detail_page.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() =>
      _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final SalesService _service = SalesService();

  List<Sale> sales = [];

  bool loading = true;
  int? processingSaleId;

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

  Future<void> abrirBorrador(Sale sale) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SaleDetailPage(
          saleId: sale.id,
        ),
      ),
    );

    if (!mounted) return;

    await cargarVentas();
  }

  Future<void> eliminarBorrador(
    Sale sale,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Eliminar venta borrador",
          ),
          content: Text(
            "¿Quieres eliminar la venta "
            "#${sale.numero}?\n\n"
            "También se eliminarán sus artículos.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text("Volver"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    setState(() {
      processingSaleId = sale.id;
    });

    try {
      await _service.deleteDraftSale(
        sale.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Venta borrador eliminada",
          ),
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
    } finally {
      if (mounted) {
        setState(() {
          processingSaleId = null;
        });
      }
    }
  }
  Future<void> cancelarVenta(Sale sale) async {
  final confirmar = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          "Cancelar venta",
        ),
        content: Text(
          "¿Quieres cancelar la venta "
          "#${sale.numero}?\n\n"
          "Se restaurará el stock y se registrará "
          "la devolución de los envases.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                false,
              );
            },
            child: const Text("Volver"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                true,
              );
            },
            child: const Text(
              "Cancelar venta",
            ),
          ),
        ],
      );
    },
  );

  if (confirmar != true || !mounted) return;

  setState(() {
    processingSaleId = sale.id;
  });

  try {
    await _service.cancelSale(sale.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Venta cancelada correctamente",
        ),
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
  } finally {
    if (mounted) {
      setState(() {
        processingSaleId = null;
      });
    }
  }
}

  Future<void> registrarPago(Sale sale) async {
    setState(() {
      processingSaleId = sale.id;
    });

    try {
      await _service.paySale(sale.id);

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
    } finally {
      if (mounted) {
        setState(() {
          processingSaleId = null;
        });
      }
    }
  }

  Future<void> generarFactura(Sale sale) async {
    setState(() {
      processingSaleId = sale.id;
    });

    try {
      await _service.generateInvoice(
        sale.id,
      );

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
    } finally {
      if (mounted) {
        setState(() {
          processingSaleId = null;
        });
      }
    }
  }

  String etiquetaEstado(String estado) {
    switch (estado) {
      case "draft":
        return "Borrador";
      case "confirmed":
        return "Confirmada";
      case "paid":
        return "Pagada";
      case "cancelled":
        return "Cancelada";
      default:
        return estado;
    }
  }

  String precioFormateado(double precio) {
    return precio.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return ProtectedPage(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Ventas"),
        ),
        floatingActionButton:
            FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const CreateSalePage(),
              ),
            );

            if (!mounted) return;

            await cargarVentas();
          },
          child: const Icon(Icons.add),
        ),
        body: loading
            ? const AppLoader()
            : RefreshIndicator(
                onRefresh: cargarVentas,
                child: SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(
                    AppSpacing.screenPadding,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const AppSectionTitle(
                        title: "Ventas",
                        subtitle:
                            "Gestiona ventas, pagos y facturación.",
                      ),
                      const SizedBox(
                        height: AppSpacing.lg,
                      ),
                      if (sales.isEmpty)
                        const AppEmptyState(
                          title:
                              "No hay ventas registradas",
                          message:
                              "Las ventas aparecerán aquí.",
                          icon:
                              Icons.point_of_sale,
                        )
                      else
                        Column(
                          children: sales.map((sale) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(
                                bottom:
                                    AppSpacing.md,
                              ),
                              child:
                                  construirTarjeta(
                                sale,
                              ),
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

  Widget construirTarjeta(Sale sale) {
    final processing =
        processingSaleId == sale.id;

    return AppCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Venta #${sale.numero}",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                ),
              ),
              Chip(
                label: Text(
                  etiquetaEstado(sale.estado),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: AppSpacing.md,
          ),
          Text(
            "Cliente: "
            "${sale.clienteNombre ?? "Sin cliente"}",
          ),
          const SizedBox(
            height: AppSpacing.sm,
          ),
          Text(
            "Artículos: ${sale.items.length}",
          ),
          const SizedBox(
            height: AppSpacing.sm,
          ),
          Text(
            "Total: "
            "\$${precioFormateado(sale.total)}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: AppSpacing.lg,
          ),
          if (sale.estado == "draft") ...[
            PrimaryButton(
              text: "Continuar borrador",
              loading: processing,
              onPressed: processing
                  ? null
                  : () {
                      abrirBorrador(sale);
                    },
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: processing
                    ? null
                    : () {
                        eliminarBorrador(sale);
                      },
                icon: const Icon(
                  Icons.delete_outline,
                ),
                label: const Text(
                  "Eliminar borrador",
                ),
              ),
            ),
          ],
          if (sale.estado == "confirmed") ...[
            PrimaryButton(
              text: "Registrar pago",
              loading: processing,
              onPressed: processing
                  ? null
                  : () {
                      registrarPago(sale);
                    },
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: processing
                    ? null
                    : () {
                        cancelarVenta(sale);
                      },
                icon: const Icon(
                  Icons.cancel_outlined,
                ),
                label: const Text(
                  "Cancelar venta",
                ),
              ),
            ),
          ],
          if (sale.estado == "paid")
            PrimaryButton(
              text: "Generar factura",
              loading: processing,
              onPressed: processing
                  ? null
                  : () {
                      generarFactura(sale);
                    },
            ),
          if (sale.estado == "cancelled")
            const Text(
              "Esta venta fue cancelada.",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }
}