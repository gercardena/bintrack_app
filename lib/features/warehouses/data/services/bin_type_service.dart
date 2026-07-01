import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../../auth/data/token_storage.dart';
import '../models/bin_type_model.dart';

class BinTypeService {
  final String baseUrl = ApiConfig.apiBaseUrl;

  Future<List<BinType>> getBinTypes() async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse("$baseUrl/bins/types/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => BinType.fromJson(e)).toList();
    }

    throw Exception("Error loading bin types");
  }

  Future<void> createBinType({
    required String nombre,
    required String tipo,
    required String material,
    required double valorDeposito,
  }) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.post(
      Uri.parse("$baseUrl/bins/types/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "nombre": nombre,
        "tipo": tipo,
        "material": material,
        "valor_deposito": valorDeposito,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Error creando tipo de envase");
    }
  }
}