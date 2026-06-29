import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../../auth/data/token_storage.dart';
import '../models/bin_movement_model.dart';

class BinMovementService {
  final String baseUrl = ApiConfig.apiBaseUrl;

  Future<List<BinMovement>> getMovements() async {
    final token = await TokenStorage.getAccessToken();

    print("TOKEN MOVEMENTS: $token");

    final response = await http.get(
      Uri.parse("$baseUrl/bins/movements/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("STATUS MOVEMENTS: ${response.statusCode}");
    print("BODY MOVEMENTS: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => BinMovement.fromJson(e)).toList();
    }

    throw Exception("Error loading movements");
  }

  Future<bool> createMovement({
    required int cliente,
    required int binType,
    required String tipoMovimiento,
    required int cantidad,
    required double depositoPagado,
    String? referencia,
  }) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.post(
      Uri.parse("$baseUrl/bins/movements/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "cliente": cliente,
        "bin_type": binType,
        "tipo_movimiento": tipoMovimiento,
        "cantidad": cantidad,
        "deposito_pagado": depositoPagado,
        "referencia": referencia ?? "",
      }),
    );

    print("CREATE MOVEMENT STATUS: ${response.statusCode}");
    print("CREATE MOVEMENT BODY: ${response.body}");

    return response.statusCode == 201;
  }
}