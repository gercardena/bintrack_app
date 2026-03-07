import 'package:flutter/material.dart';
import '../data/clientes_api.dart';
import '../models/cliente.dart';

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
    try {

      final data = await ClientesApi.getClientes();

      setState(() {
        clientes = data;
        loading = false;
      });

    } catch (e) {

      print(e);

      setState(() {
        loading = false;
      });

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Clientes"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: clientes.length,
              itemBuilder: (context, index) {

                final cliente = clientes[index];

                return ListTile(
                  title: Text(cliente.nombre),
                  subtitle: Text(cliente.email ?? ''),
                );
              },
            ),
    );
  }
}