import 'dart:convert';

import '../../../core/services/api_service.dart';
import '../models/cliente.dart';

class ClientesApi {
  static Future<List<Cliente>> getClientes() async {
    final response = await ApiService.get(
      "/clientes/",
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Error cargando clientes: ${response.body}",
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        "Respuesta inválida al cargar clientes",
      );
    }

    return decoded
        .map(
          (item) => Cliente.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  static Future<bool> crearCliente({
    required String nombre,
    required String rut,
    String? email,
    String? telefono,
    String? direccion,
  }) async {
    final response = await ApiService.post(
      "/clientes/",
      body: {
        "nombre": nombre,
        "rut": rut,
        "email": email,
        "telefono": telefono,
        "direccion": direccion,
        "activo": true,
      },
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return true;
    }

    throw Exception(
      "Error al crear cliente: ${response.body}",
    );
  }

  static Future<bool> actualizarCliente(
    int id, {
    required String nombre,
    required String rut,
    String? email,
    String? telefono,
    String? direccion,
    bool activo = true,
  }) async {
    final response = await ApiService.put(
      "/clientes/$id/",
      body: {
        "nombre": nombre,
        "rut": rut,
        "email": email,
        "telefono": telefono,
        "direccion": direccion,
        "activo": activo,
      },
    );

    if (response.statusCode == 200) {
      return true;
    }

    throw Exception(
      "Error al actualizar cliente: ${response.body}",
    );
  }

  static Future<bool> eliminarCliente(int id) async {
    final response = await ApiService.delete(
      "/clientes/$id/",
    );

    if (response.statusCode == 200 ||
        response.statusCode == 204) {
      return true;
    }

    throw Exception(
      "Error al eliminar cliente: ${response.body}",
    );
  }
}