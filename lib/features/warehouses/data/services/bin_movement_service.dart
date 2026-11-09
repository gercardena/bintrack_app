import 'dart:convert';
import '../../../../core/api/subscription_response.dart';

import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../../auth/data/token_storage.dart';
import '../models/bin_movement_model.dart';

class BinMovementService {
  final String baseUrl = ApiConfig.apiBaseUrl;

  Future<List<BinMovement>> getMovements() async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse("$baseUrl/bins/movements/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    checkSubscriptionResponse(response);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => BinMovement.fromJson(e)).toList();
    }

    throw Exception("Error loading movements");
  }

  Future<bool> createMovement({
    int? cliente,
    required int binType,
    required String tipoMovimiento,
    required int cantidad,
    required double depositoPagado,
    required double depositoDevuelto,
    String? referencia,
  }) async {
    final token = await TokenStorage.getAccessToken();

    final body = {
      "cliente": cliente,
      "bin_type": binType,
      "tipo_movimiento": tipoMovimiento,
      "cantidad": cantidad,
      "deposito_pagado": depositoPagado,
      "deposito_devuelto": depositoDevuelto,
      "referencia": referencia ?? "",
    };

    final response = await http.post(
      Uri.parse("$baseUrl/bins/movements/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );
    checkSubscriptionResponse(response);

    return response.statusCode == 201;
  }
}
