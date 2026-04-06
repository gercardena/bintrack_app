import 'package:flutter/material.dart';
import '../data/clientes_api.dart';
import '../models/cliente.dart';
import 'crear_cliente_page.dart';
import 'editar_cliente_page.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {

  List<Cliente> clientes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarClientes();
  }

  Future<void> cargarClientes() async {
    setState(() => loading = true);

    try {

      final data = await ClientesApi.getClientes();

      setState(() {
        clientes = data;
        loading = false;
      });

    } catch (e) {

      print("ERROR CLIENTES: $e");

      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Clientes"),
        elevation: 0,
      ),

      body: RefreshIndicator(
        onRefresh: cargarClientes,

        child: loading
            ? const Center(child: CircularProgressIndicator())
            : clientes.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: clientes.length,
                    itemBuilder: (context, index) {

                      final cliente = clientes[index];

                      return _clienteCard(cliente);
                    },
                  ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),

        onPressed: () async {

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CrearClientePage(),
            ),
          );

          if (result == true) {
            cargarClientes();
          }
        },
      ),
    );
  }

  // 🔥 CARD CLIENTE
  Widget _clienteCard(Cliente cliente) {

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.all(12),

        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            cliente.nombre.isNotEmpty
                ? cliente.nombre[0].toUpperCase()
                : "?",
            style: const TextStyle(color: Colors.white),
          ),
        ),

        title: Text(
          cliente.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            if (cliente.telefono != null && cliente.telefono!.isNotEmpty)
              Text("📞 ${cliente.telefono}"),

            if (cliente.email != null && cliente.email!.isNotEmpty)
              Text("✉️ ${cliente.email}"),

            if (cliente.direccion != null && cliente.direccion!.isNotEmpty)
              Text("📍 ${cliente.direccion}"),
          ],
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmarEliminar(cliente),
            ),

            const Icon(Icons.chevron_right),
          ],
        ),

        onTap: () async {

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditarClientePage(cliente: cliente),
            ),
          );

          if (result == true) {
            cargarClientes();
          }
        },
      ),
    );
  }

  // 🔥 CONFIRMAR ELIMINAR
  Future<void> _confirmarEliminar(Cliente cliente) async {

    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar cliente"),
        content: Text("¿Eliminar a ${cliente.nombre}?"),
        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),

          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.red),
            ),
          ),

        ],
      ),
    );

    if (confirm == true) {

      try {

        await ClientesApi.eliminarCliente(cliente.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cliente eliminado")),
        );

        cargarClientes();

      } catch (e) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  // 🔥 EMPTY STATE
  Widget _emptyState() {

    return ListView(
      children: const [

        SizedBox(height: 100),

        Icon(Icons.people_outline, size: 80, color: Colors.grey),

        SizedBox(height: 16),

        Center(
          child: Text(
            "No hay clientes",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}