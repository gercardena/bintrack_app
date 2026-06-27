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
  final SalesService _salesService = SalesService();

  final ClientsService _clientsService = ClientsService();

  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);

  List<Cliente> clientes = [];

  Cliente? clienteSeleccionado;

  bool loading = true;
  bool saving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    cargarClientes();
  }

  Future<void> cargarClientes() async {
    try {
      final data = await _clientsService.getClients();

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
        errorMessage = e.toString();
      });
    }
  }

  Future<void> crearVenta() async {
    final cliente = clienteSeleccionado;

    if (cliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Selecciona un cliente activo para crear la venta.",
          ),
        ),
      );

      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final saleId = await _salesService.createSale(
        clienteId: cliente.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Venta #$saleId creada.",
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
          content: Text(
            "No fue posible crear la venta: $e",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.06),
          labelStyle: const TextStyle(
            color: Colors.white70,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.blueAccent,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.redAccent,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.redAccent,
            ),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: const Text("Nueva venta"),
          centerTitle: true,
          backgroundColor: background,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : errorMessage != null
                ? _errorState()
                : clientes.isEmpty
                    ? _emptyState()
                    : ListView(
                        padding:
                            const EdgeInsets.all(16),
                        children: [
                          _introCard(),
                          const SizedBox(height: 16),
                          _sectionCard(
                            title: "Cliente",
                            icon: Icons.person_outline,
                            color: Colors.blueAccent,
                            children: [
                              DropdownButtonFormField<Cliente>(
                                initialValue:
                                    clienteSeleccionado,
                                isExpanded: true,
                                dropdownColor: card,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                items: clientes.map(
                                  (cliente) {
                                    return DropdownMenuItem<
                                        Cliente>(
                                      value: cliente,
                                      child: Text(
                                        cliente.nombre,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                      ),
                                    );
                                  },
                                ).toList(),
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
                                  labelText:
                                      "Cliente activo",
                                ),
                              ),
                              const SizedBox(height: 10),
                              _smallHelp(
                                "Solo aparecen clientes activos. "
                                "Si no encuentras uno, revisa el módulo Clientes.",
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _sectionCard(
                            title: "Flujo de venta",
                            icon: Icons.route,
                            color: Colors.cyanAccent,
                            children: const [
                              _StepText(
                                number: "1",
                                text:
                                    "Se crea una venta en borrador.",
                              ),
                              SizedBox(height: 8),
                              _StepText(
                                number: "2",
                                text:
                                    "Luego agregas productos y cantidades.",
                              ),
                              SizedBox(height: 8),
                              _StepText(
                                number: "3",
                                text:
                                    "Al confirmar, se descuenta stock y se registran envases.",
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed:
                                  saving ? null : crearVenta,
                              icon: saving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.add),
                              label: const Text(
                                "Crear venta",
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
      ),
    );
  }

  Widget _introCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
            color: Colors.blue.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.add_shopping_cart,
            color: Colors.white,
            size: 32,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Crea una venta seleccionando primero el cliente. "
              "Después podrás agregar productos, confirmar, registrar "
              "pago y generar comprobante.",
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

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _smallHelp(String text) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.info_outline,
          size: 18,
          color: Colors.white54,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white60,
              height: 1.3,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 90),
        Icon(
          Icons.people_outline,
          size: 82,
          color: Colors.white.withValues(alpha: 0.35),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            "No hay clientes activos",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Para crear una venta primero necesitas un cliente activo.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white60,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _errorState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 90),
        const Icon(
          Icons.error_outline,
          size: 72,
          color: Colors.redAccent,
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            "No pudimos cargar los clientes",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          errorMessage ?? "",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white60,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _StepText extends StatelessWidget {
  final String number;
  final String text;

  const _StepText({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor:
              Colors.cyanAccent.withValues(alpha: 0.18),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}