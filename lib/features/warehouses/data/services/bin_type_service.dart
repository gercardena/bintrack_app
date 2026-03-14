import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/bin_type_model.dart';
import '../../../auth/data/token_storage.dart';

class BinTypeService {

  final String baseUrl = "http://192.168.11.215:8000/api";

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

      List data = jsonDecode(response.body);

      return data.map((e) => BinType.fromJson(e)).toList();

    } else {

      throw Exception("Error loading bin types");

    }

  }
}