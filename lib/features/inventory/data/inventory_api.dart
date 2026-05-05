import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../auth/data/token_storage.dart';

class InventoryApi {

  static const String _baseUrl = 'http://192.168.11.215:8000';

  // 🔹 OBTENER INVENTARIO
  static Future<List<dynamic>> getInventory() async {

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/inventario/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("INVENTORY STATUS: ${response.statusCode}");
    print("INVENTORY BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Error cargando inventario');
  }

  // 🔥 AJUSTAR STOCK
  static Future<bool> ajustarStock({
    required int productId,
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
        "product": productId, // ✅ CLAVE CORRECTA
        "cantidad": cantidad,
      }),
    );

    print("AJUSTAR STOCK STATUS: ${response.statusCode}");
    print("AJUSTAR STOCK BODY: ${response.body}");

    return response.statusCode == 200 || response.statusCode == 201;
  }
}