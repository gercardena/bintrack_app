import 'dart:convert';

import '../../../core/services/api_service.dart';

class Product {
  final int id;
  final String nombre;
  final double precio;

  Product({
    required this.id,
    required this.nombre,
    required this.precio,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"],
      nombre: json["nombre"],
      precio: double.parse(json["precio"].toString()),
    );
  }
}

class ProductsService {
  Future<List<Product>> getProducts() async {
    final response = await ApiService.get("/productos/");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => Product.fromJson(e)).toList();
    }

    throw Exception("Error cargando productos");
  }
}