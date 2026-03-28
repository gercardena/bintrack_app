import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/bin_movement_model.dart';
import '../../../auth/data/token_storage.dart';

class BinMovementService {

  final String baseUrl = "http://192.168.11.215:8000/api";

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

      List data = jsonDecode(response.body);

      return data.map((e) => BinMovement.fromJson(e)).toList();

    } else {

      throw Exception("Error loading movements");

    }

  }

}