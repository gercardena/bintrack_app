import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../auth/data/token_storage.dart';
import '../models/product.dart';

class ProductsApi {

  static const String _baseUrl = 'http://192.168.11.215:8000';

  // 🔹 OBTENER PRODUCTOS
  static Future<List<Product>> getProducts() async {

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/productos/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("PRODUCTS STATUS: ${response.statusCode}");
    print("PRODUCTS BODY: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    }

    throw Exception('Error cargando productos');
  }

  // 🔥 CREAR PRODUCTO
  static Future<bool> crearProducto({
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

    print("CREATE PRODUCT STATUS: ${response.statusCode}");
    print("CREATE PRODUCT BODY: ${response.body}");

    return response.statusCode == 201;
  }

  // 🔥 ELIMINAR PRODUCTO
  static Future<bool> eliminarProducto(int id) async {

    final token = await TokenStorage.getAccessToken();

    final response = await http.delete(
      Uri.parse('$_baseUrl/api/productos/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print("DELETE PRODUCT STATUS: ${response.statusCode}");

    return response.statusCode == 204;
  }

  // 🔥 ACTUALIZAR PRODUCTO
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

    print("UPDATE PRODUCT STATUS: ${response.statusCode}");
    print("UPDATE PRODUCT BODY: ${response.body}");

    return response.statusCode == 200;
  }
}