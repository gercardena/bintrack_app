import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../auth/data/token_storage.dart';
import '../models/sale_model.dart';

class SalesService {

  final String baseUrl = 'http://192.168.11.215:8000/api';

  Future<List<Sale>> getSales() async {

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse('$baseUrl/ventas/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("SALES STATUS: ${response.statusCode}");
    print("SALES BODY: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Sale.fromJson(e)).toList();
    }

    throw Exception('Error al cargar ventas');
  }

  Future<void> generateInvoice(int saleId) async {

    final token = await TokenStorage.getAccessToken();

    final response = await http.post(
      Uri.parse('$baseUrl/facturas/$saleId/generar/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 400) {
      final data = jsonDecode(response.body);
      throw Exception(data['error']);
    }

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error al generar factura');
    }
  }
}