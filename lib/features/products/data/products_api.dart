import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../auth/data/token_storage.dart';
import 'models/product_model.dart';

class ProductsApi {
  static const String _baseUrl = ApiConfig.host;

  static Future<List<Product>> getProducts() async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/productos/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => Product.fromJson(e)).toList();
    }

    throw Exception('Error cargando productos');
  }

  static Future<Map<String, dynamic>?> crearProducto({
    required String nombre,
    required String precio,
    String? descripcion,
  }) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/productos/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "nombre": nombre,
        "precio": precio,
        "descripcion": descripcion ?? "",
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    return null;
  }

  static Future<bool> eliminarProducto(int id) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.delete(
      Uri.parse('$_baseUrl/api/productos/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 204;
  }

  static Future<bool> actualizarProducto({
    required int id,
    required String nombre,
    required String precio,
    String? descripcion,
  }) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.put(
      Uri.parse('$_baseUrl/api/productos/$id/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "nombre": nombre,
        "precio": precio,
        "descripcion": descripcion ?? "",
      }),
    );

    return response.statusCode == 200;
  }
}