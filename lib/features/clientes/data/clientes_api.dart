import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../auth/data/token_storage.dart';
import '../models/cliente.dart';

class ClientesApi {

  static const String _baseUrl = 'http://192.168.11.215:8000';

  // 🔥 GET CLIENTES
  static Future<List<Cliente>> getClientes() async {

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/clientes/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("CLIENTES STATUS: ${response.statusCode}");
    print("CLIENTES BODY: ${response.body}");

    if (response.statusCode == 200) {

      final List data = jsonDecode(response.body);

      return data.map((e) => Cliente.fromJson(e)).toList();

    } else {
      throw Exception('Error cargando clientes');
    }
  }

  // 🔥 CREAR CLIENTE
  static Future<bool> crearCliente({
    required String nombre,
    required String rut,
    String? email,
    String? telefono,
    String? direccion,
  }) async {

    final token = await TokenStorage.getAccessToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/clientes/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "nombre": nombre,
        "rut": rut,
        "email": email,
        "telefono": telefono,
        "direccion": direccion,
      }),
    );

    print("CREATE CLIENT STATUS: ${response.statusCode}");
    print("CREATE CLIENT BODY: ${response.body}");

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    }

    throw Exception('Error al crear cliente');
  }

  // 🔥 ACTUALIZAR CLIENTE
  static Future<bool> actualizarCliente(
    int id, {
    required String nombre,
    required String rut,
    String? email,
    String? telefono,
    String? direccion,
  }) async {

    final token = await TokenStorage.getAccessToken();

    final response = await http.put(
      Uri.parse('$_baseUrl/api/clientes/$id/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "nombre": nombre,
        "rut": rut,
        "email": email,
        "telefono": telefono,
        "direccion": direccion,
      }),
    );

    print("UPDATE CLIENT STATUS: ${response.statusCode}");
    print("UPDATE CLIENT BODY: ${response.body}");

    if (response.statusCode == 200) return true;

    throw Exception('Error al actualizar cliente');
  }

  // 🔥 ELIMINAR CLIENTE
  static Future<bool> eliminarCliente(int id) async {

    final token = await TokenStorage.getAccessToken();

    final response = await http.delete(
      Uri.parse('$_baseUrl/api/clientes/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print("DELETE CLIENT STATUS: ${response.statusCode}");

    if (response.statusCode == 204 || response.statusCode == 200) {
      return true;
    }

    throw Exception('Error al eliminar cliente');
  }
}