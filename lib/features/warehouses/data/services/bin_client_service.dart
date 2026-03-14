import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/bin_client_model.dart';
import '../../../auth/data/token_storage.dart';

class BinClientService {

  final String baseUrl = "http://192.168.11.215:8000/api";

  Future<List<BinClient>> getClients() async {

    final token = await TokenStorage.getAccessToken();

    print("TOKEN BINS: $token");

    final response = await http.get(
      Uri.parse("$baseUrl/bins/clientes/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("STATUS CLIENTES BINS: ${response.statusCode}");
    print("BODY CLIENTES BINS: ${response.body}");

    if (response.statusCode == 200) {

      List data = jsonDecode(response.body);

      return data.map((e) => BinClient.fromJson(e)).toList();

    } else {

      throw Exception("Error loading clients");

    }

  }

}