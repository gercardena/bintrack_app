import 'package:flutter/material.dart';

import '../../clientes/data/clients_service.dart';
import '../../clientes/models/client_model.dart';

import '../data/sales_service.dart';

import 'sale_detail_page.dart';

class CreateSalePage extends StatefulWidget {
  const CreateSalePage({super.key});

  @override
  State<CreateSalePage> createState() => _CreateSalePageState();
}

class _CreateSalePageState extends State<CreateSalePage> {

  final SalesService _salesService = SalesService();
  final ClientsService _clientsService = ClientsService();

  List<Cliente> clientes = [];

  Cliente? clienteSeleccionado;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarClientes();
  }

  // =========================================
  // 🔥 CARGAR CLIENTES
  // =========================================

  Future<void> cargarClientes() async {

    try {

      final data = await _clientsService.getClients();

      if (!mounted) return;

      setState(() {
        clientes = data;
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

  // =========================================
  // 🔥 CREAR VENTA
  // =========================================

  Future<void> crearVenta() async {

    if (clienteSeleccionado == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecciona un cliente"),
        ),
      );

      return;
    }

    try {

      final saleId = await _salesService.createSale(
        clienteId: clienteSeleccionado!.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Venta #$saleId creada"),
        ),
      );

      Navigator.push(

        context,

        MaterialPageRoute(

          builder: (_) => SaleDetailPage(
            saleId: saleId,
          ),
        ),
      );

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

    return Scaffold(

      appBar: AppBar(
        title: const Text("Nueva Venta"),
      ),

      body: loading

          ? const Center(
              child: CircularProgressIndicator(),
            )

          : Padding(

              padding: const EdgeInsets.all(16),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

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

                    items: clientes.map((cliente) {

                      return DropdownMenuItem<Cliente>(

                        value: cliente,

                        child: Text(cliente.nombre),
                      );

                    }).toList(),

                    onChanged: (value) {

                      setState(() {
                        clienteSeleccionado = value;
                      });
                    },

                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(

                    width: double.infinity,

                    child: ElevatedButton(

                      onPressed: crearVenta,

                      child: const Text("Crear Venta"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}