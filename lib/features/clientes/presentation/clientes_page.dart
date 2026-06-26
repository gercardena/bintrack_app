import 'package:flutter/material.dart';

import '../data/clientes_api.dart';
import '../models/cliente.dart';

import 'crear_cliente_page.dart';
import 'editar_cliente_page.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() =>
      _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);

  List<Cliente> clientes = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    cargarClientes();
  }

  Future<void> cargarClientes() async {
    if (mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }

    try {
      final data = await ClientesApi.getClientes();

      if (!mounted) return;

      setState(() {
        clientes = data;
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

  Future<void> abrirCrearCliente() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CrearClientePage(),
      ),
    );

    if (result == true && mounted) {
      await cargarClientes();
    }
  }

  Future<void> abrirEditarCliente(
    Cliente cliente,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditarClientePage(
          cliente: cliente,
        ),
      ),
    );

    if (result == true && mounted) {
      await cargarClientes();
    }
  }

  Future<void> _confirmarDesactivar(
    Cliente cliente,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Desactivar cliente"),
        content: Text(
          "¿Quieres desactivar a ${cliente.nombre}?\n\n"
          "Un cliente inactivo no aparecerá para nuevas ventas, "
          "pero se conserva su historial.",
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () =>
                Navigator.pop(context, true),
            child: const Text("Desactivar"),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await ClientesApi.eliminarCliente(cliente.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${cliente.nombre} fue desactivado.",
          ),
        ),
      );

      await cargarClientes();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activos = clientes
        .where(
          (cliente) => cliente.activo,
        )
        .length;

    final inactivos = clientes.length - activos;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text("Clientes"),
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
              : RefreshIndicator(
                  onRefresh: cargarClientes,
                  child: clientes.isEmpty
                      ? _emptyState()
                      : ListView(
                          padding:
                              const EdgeInsets.all(16),
                          children: [
                            _headerCard(
                              activos: activos,
                              inactivos: inactivos,
                            ),
                            const SizedBox(height: 14),
                            ...clientes.map(
                              _clienteCard,
                            ),
                          ],
                        ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        onPressed: abrirCrearCliente,
        icon: const Icon(Icons.person_add),
        label: const Text("Nuevo cliente"),
      ),
    );
  }

  Widget _headerCard({
    required int activos,
    required int inactivos,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.withValues(
          alpha: 0.16,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.indigoAccent.withValues(
            alpha: 0.30,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.people,
                color: Colors.indigoAccent,
                size: 30,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Administra tus clientes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Los clientes activos pueden usarse en nuevas ventas. "
            "Los inactivos conservan su historial, pero no se recomiendan "
            "para operaciones nuevas.",
            style: TextStyle(
              color: Colors.white70,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _summaryChip(
                label: "Activos",
                value: "$activos",
                color: Colors.greenAccent,
              ),
              const SizedBox(width: 10),
              _summaryChip(
                label: "Inactivos",
                value: "$inactivos",
                color: Colors.orangeAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.28),
          ),
        ),
        child: Row(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _clienteCard(
    Cliente cliente,
  ) {
    final statusColor =
        cliente.activo ? Colors.greenAccent : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.22),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => abrirEditarCliente(cliente),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: cliente.activo
                    ? const Color(0xFF4F46E5)
                    : Colors.grey,
                child: Text(
                  cliente.nombre.isNotEmpty
                      ? cliente.nombre[0].toUpperCase()
                      : "?",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            cliente.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _statusPill(cliente.activo),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "RUT: ${cliente.rut}",
                      style: const TextStyle(
                        color: Colors.white60,
                      ),
                    ),

                    const SizedBox(height: 8),

                    if (cliente.telefono != null &&
                        cliente.telefono!.isNotEmpty)
                      _infoLine(
                        Icons.phone,
                        cliente.telefono!,
                      ),

                    if (cliente.email != null &&
                        cliente.email!.isNotEmpty)
                      _infoLine(
                        Icons.email_outlined,
                        cliente.email!,
                      ),

                    if (cliente.direccion != null &&
                        cliente.direccion!.isNotEmpty)
                      _infoLine(
                        Icons.location_on_outlined,
                        cliente.direccion!,
                      ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          style:
                              OutlinedButton.styleFrom(
                            foregroundColor:
                                Colors.cyanAccent,
                            side: BorderSide(
                              color: Colors.cyanAccent
                                  .withValues(
                                alpha: 0.40,
                              ),
                            ),
                          ),
                          onPressed: () =>
                              abrirEditarCliente(cliente),
                          icon: const Icon(
                            Icons.edit,
                            size: 18,
                          ),
                          label: const Text("Editar"),
                        ),
                        if (cliente.activo)
                          OutlinedButton.icon(
                            style:
                                OutlinedButton.styleFrom(
                              foregroundColor:
                                  Colors.redAccent,
                              side: BorderSide(
                                color: Colors.redAccent
                                    .withValues(
                                  alpha: 0.45,
                                ),
                              ),
                            ),
                            onPressed: () =>
                                _confirmarDesactivar(
                              cliente,
                            ),
                            icon: const Icon(
                              Icons.block,
                              size: 18,
                            ),
                            label:
                                const Text("Desactivar"),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusPill(bool activo) {
    final color =
        activo ? Colors.greenAccent : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.30),
        ),
      ),
      child: Text(
        activo ? "Activo" : "Inactivo",
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoLine(
    IconData icon,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 3,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white54,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
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
            "Todavía no hay clientes",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Crea tu primer cliente para poder iniciar ventas, "
          "registrar envases y mantener historial comercial.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white60,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: abrirCrearCliente,
          icon: const Icon(Icons.person_add),
          label: const Text("Crear cliente"),
        ),
      ],
    );
  }

  Widget _errorState() {
    return RefreshIndicator(
      onRefresh: cargarClientes,
      child: ListView(
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
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: cargarClientes,
            icon: const Icon(Icons.refresh),
            label: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }
}