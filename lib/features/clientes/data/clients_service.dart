import 'dart:convert';
import '../../../core/services/api_service.dart';
import '../models/client_model.dart';

class ClientsService {

  // =========================================
  // 🔹 GET CLIENTES
  // =========================================

  Future<List<Cliente>> getClients() async {

    final response = await ApiService.get("/clientes/");

    print("CLIENTES STATUS: ${response.statusCode}");
    print("CLIENTES BODY: ${response.body}");

    if (response.statusCode == 200) {

      final decoded = jsonDecode(response.body);

      // 🔥 PROTECCIÓN TOTAL
      if (decoded is List) {
        return decoded
            .map((e) => Cliente.fromJson(e))
            .toList();
      } else {
        return [];
      }

    } else {
      throw Exception("Error cargando clientes (${response.statusCode})");
    }
  }

  // =========================================
  // 🔹 CREAR CLIENTE (te va a servir después)
  // =========================================

  Future<Cliente> createClient(Cliente cliente) async {

    final response = await ApiService.post(
      "/clientes/",
      body: cliente.toJson(),
    );

    print("CREATE CLIENT STATUS: ${response.statusCode}");
    print("CREATE CLIENT BODY: ${response.body}");

    if (response.statusCode == 201) {

      final data = jsonDecode(response.body);

      return Cliente.fromJson(data);

    } else {
      throw Exception("Error creando cliente");
    }
  }
}