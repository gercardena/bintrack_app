import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../auth/data/token_storage.dart';

class InventoryApi {
  static const String _baseUrl = ApiConfig.host;

  static Future<List<dynamic>> getInventory() async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/inventario/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Error cargando inventario');
  }

  static Future<bool> crearInventario({
    required int productId,
    required int binId,
    required int cantidad,
  }) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/inventario/crear/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "product": productId,
        "bin": binId,
        "cantidad": cantidad,
      }),
    );

    return response.statusCode == 201;
  }

  static Future<bool> ajustarStock({
    required int productId,
    required int binId,
    required int cantidad,
  }) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/inventario/ajustar/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "product": productId,
        "bin": binId,
        "cantidad": cantidad,
      }),
    );

    return response.statusCode == 200;
  }
}