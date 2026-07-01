import 'dart:convert';

import '../../../../core/services/api_service.dart';
import '../models/bin_client_model.dart';

class BinClientService {
  Future<List<BinClient>> getClients() async {
    final response = await ApiService.get(
      "/bins/clientes/",
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map(
            (e) => BinClient.fromJson(e),
          )
          .cast<BinClient>()
          .toList();
    }

    throw Exception(
      "Error loading clients",
    );
  }

  Future createClient({
    required String nombre,
    required String rut,
    required String email,
    required String telefono,
    required String direccion,
  }) async {
    final response = await ApiService.post(
      "/bins/clientes/",
      body: {
        "nombre": nombre,
        "rut": rut,
        "email": email,
        "telefono": telefono,
        "direccion": direccion,
        "activo": true,
      },
    );

    if (response.statusCode != 201) {
      throw Exception(
        "Error creando cliente",
      );
    }
  }

  Future updateClient({
    required int id,
    required String nombre,
    required String rut,
    required String email,
    required String telefono,
    required String direccion,
    required bool activo,
  }) async {
    final response = await ApiService.put(
      "/bins/clientes/$id/",
      body: {
        "nombre": nombre,
        "rut": rut,
        "email": email,
        "telefono": telefono,
        "direccion": direccion,
        "activo": activo,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Error actualizando cliente",
      );
    }
  }

  Future deleteClient(
    int id,
  ) async {
    final response = await ApiService.delete(
      "/bins/clientes/$id/",
    );

    if (response.statusCode != 204) {
      throw Exception(
        "Error eliminando cliente",
      );
    }
  }
}