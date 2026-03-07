import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../auth/data/token_storage.dart';
import '../models/cliente.dart';

class ClientesApi {

  static const String _baseUrl = 'http://192.168.11.215:8000';

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
}