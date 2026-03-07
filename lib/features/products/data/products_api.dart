import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../auth/data/token_storage.dart';
import '../models/product.dart';

class ProductsApi {

  static const String _baseUrl = 'http://192.168.11.215:8000';

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

    } else {

      throw Exception('Error cargando productos');

    }
  }
}