import 'package:flutter/material.dart';

import '../../clientes/data/clients_service.dart';
import '../../clientes/models/cliente.dart';

import '../data/services/sale_service.dart';

import 'sale_detail_page.dart';

class CreateSalePage extends StatefulWidget {
  const CreateSalePage({super.key});

  @override
  State<CreateSalePage> createState() =>
      _CreateSalePageState();
}

class _CreateSalePageState
    extends State<CreateSalePage> {
  final SalesService _salesService =
      SalesService();

  final ClientsService _clientsService =
      ClientsService();

  List<Cliente> clientes = [];

  Cliente? clienteSeleccionado;

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    cargarClientes();
  }

  Future<void> cargarClientes() async {
    try {
      final data =
          await _clientsService.getClients();

      if (!mounted) return;

      setState(() {
          clientes = data
            .where(
              (cliente) => cliente.activo,
            )
            .toList();
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

  Future<void> crearVenta() async {
    final cliente = clienteSeleccionado;

    if (cliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Selecciona un cliente",
          ),
        ),
      );

      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final saleId =
          await _salesService.createSale(
        clienteId: cliente.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Venta #$saleId creada",
          ),
        ),
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SaleDetailPage(
            saleId: saleId,
          ),
        ),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Nueva venta"),
    ),
    body: loading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : clientes.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    "No hay clientes activos para crear una venta.",
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Cliente",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<Cliente>(
                      value: clienteSeleccionado,
                      isExpanded: true,
                      items: clientes.map((cliente) {
                        return DropdownMenuItem<Cliente>(
                          value: cliente,
                          child: Text(
                            cliente.nombre,
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: saving
                          ? null
                          : (value) {
                              setState(() {
                                clienteSeleccionado =
                                    value;
                              });
                            },
                      decoration:
                          const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Cliente",
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            saving ? null : crearVenta,
                        child: saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Crear venta",
                              ),
                      ),
                    ),
                  ],
                ),
              ),
  );
}
}