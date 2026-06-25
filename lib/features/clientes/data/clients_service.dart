import '../models/cliente.dart';
import 'clientes_api.dart';

class ClientsService {
  Future<List<Cliente>> getClients() async {
    return ClientesApi.getClientes();
  }

  Future<Cliente> createClient(Cliente cliente) async {
    final ok = await ClientesApi.crearCliente(
      nombre: cliente.nombre,
      rut: cliente.rut,
      email: cliente.email,
      telefono: cliente.telefono,
      direccion: cliente.direccion,
    );

    if (!ok) {
      throw Exception("Error creando cliente");
    }

    final clientes = await ClientesApi.getClientes();

    return clientes.firstWhere(
      (item) => item.rut == cliente.rut,
      orElse: () => cliente,
    );
  }
}