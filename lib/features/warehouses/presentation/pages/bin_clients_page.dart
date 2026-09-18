import 'package:flutter/material.dart';

import '../../data/services/bin_client_service.dart';
import '../../data/models/bin_client_model.dart';

import 'create_client_page.dart';
import 'edit_client_page.dart';

class BinClientsPage extends StatefulWidget {
  const BinClientsPage({super.key});

  @override
  State<BinClientsPage> createState() =>
      _BinClientsPageState();
}

class _BinClientsPageState extends State<BinClientsPage> {
  final BinClientService service = BinClientService();
  final TextEditingController buscarController =
      TextEditingController();

  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);

  List<BinClient> clients = [];

  bool loading = true;
  String? errorMessage;

  List<BinClient> get clientesFiltrados {
    final query = buscarController.text
        .trim()
        .toLowerCase();

    if (query.isEmpty) {
      return clients;
    }

    return clients.where((client) {
      final estado =
          client.activo ? "activo" : "inactivo";

      final texto = [
        client.nombre,
        client.rut,
        client.email,
        client.telefono,
        client.direccion,
        estado,
      ].join(" ").toLowerCase();

      return texto.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    loadClients();
  }

  @override
  void dispose() {
    buscarController.dispose();
    super.dispose();
  }

  Future<void> loadClients() async {
    if (mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }

    try {
      final data = await service.getClients();

      if (!mounted) return;

      setState(() {
        clients = data;
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

  Future<void> crearCliente() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateClientPage(),
      ),
    );

    if (result == true && mounted) {
      await loadClients();
    }
  }

  Future<void> editarCliente(
    BinClient client,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditClientPage(
          client: client,
        ),
      ),
    );

    if (result == true && mounted) {
      await loadClients();
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibles = clientesFiltrados;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text("Clientes con envases"),
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
                  onRefresh: loadClients,
                  child: clients.isEmpty
                      ? _emptyState()
                      : ListView(
                          padding:
                              const EdgeInsets.all(16),
                          children: [
                            _introCard(),
                            const SizedBox(height: 14),
                            _searchCard(),
                            const SizedBox(height: 14),
                            if (visibles.isEmpty)
                              _emptySearchState()
                            else
                              ...visibles.map(
                                _clientCard,
                              ),
                          ],
                        ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        onPressed: crearCliente,
        icon: const Icon(Icons.person_add),
        label: const Text("Nuevo cliente"),
      ),
    );
  }

  Widget _introCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.greenAccent.withValues(alpha: 0.28),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.people,
            color: Colors.greenAccent,
            size: 30,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Aquí ves los clientes disponibles para movimientos "
              "de envases. Desde esta pantalla puedes revisar o editar "
              "sus datos.",
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

  Widget _searchCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.greenAccent.withValues(
            alpha: 0.22,
          ),
        ),
      ),
      child: TextField(
        controller: buscarController,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(
          color: Colors.white,
        ),
        cursorColor: Colors.greenAccent,
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.greenAccent,
          ),
          suffixIcon: buscarController.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    buscarController.clear();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.white70,
                  ),
                ),
          labelText: "Buscar cliente",
          hintText:
              "Nombre, RUT, teléfono, email, dirección o estado",
          labelStyle: const TextStyle(
            color: Colors.white70,
          ),
          hintStyle: const TextStyle(
            color: Colors.white38,
          ),
          filled: true,
          fillColor: Colors.black.withValues(
            alpha: 0.18,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withValues(
                alpha: 0.12,
              ),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.greenAccent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _clientCard(
    BinClient client,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
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
        onTap: () => editarCliente(client),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    const Color(0xFF22C55E),
                child: Text(
                  client.nombre.isNotEmpty
                      ? client.nombre[0].toUpperCase()
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
                            client.nombre,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _statusPill(client.activo),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _infoLine(
                      Icons.badge_outlined,
                      "RUT: ${client.rut}",
                    ),
                    if (client.telefono.isNotEmpty)
                      _infoLine(
                        Icons.phone,
                        client.telefono,
                      ),
                    if (client.email.isNotEmpty)
                      _infoLine(
                        Icons.email_outlined,
                        client.email,
                      ),
                    if (client.direccion.isNotEmpty)
                      _infoLine(
                        Icons.location_on_outlined,
                        client.direccion,
                      ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              Colors.cyanAccent,
                          side: BorderSide(
                            color: Colors.cyanAccent
                                .withValues(
                              alpha: 0.45,
                            ),
                          ),
                        ),
                        onPressed: () =>
                            editarCliente(client),
                        icon: const Icon(
                          Icons.edit,
                          size: 18,
                        ),
                        label: const Text("Editar"),
                      ),
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
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white54,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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

  Widget _emptySearchState() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.10,
          ),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 52,
            color: Colors.white.withValues(
              alpha: 0.45,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "No encontramos clientes",
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Prueba buscar por nombre, RUT, teléfono, email, dirección, activo o inactivo.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white60,
              height: 1.35,
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
            "No hay clientes disponibles",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Crea un cliente para registrar préstamos, devoluciones "
          "y balances de envases.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white60,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: crearCliente,
          icon: const Icon(Icons.person_add),
          label: const Text("Crear cliente"),
        ),
      ],
    );
  }

  Widget _errorState() {
    return RefreshIndicator(
      onRefresh: loadClients,
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
            onPressed: loadClients,
            icon: const Icon(Icons.refresh),
            label: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }
}