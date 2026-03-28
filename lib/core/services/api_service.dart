import 'package:http/http.dart' as http;

import '../../features/auth/data/token_storage.dart';
import '../../features/auth/data/auth_api.dart';

class ApiService {

  static const String baseUrl = "http://192.168.11.215:8000/api";

  // 🔥 GET GENÉRICO CON REFRESH AUTOMÁTICO
  static Future<http.Response> get(String endpoint) async {

    String? token = await TokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    // 🔥 SI EXPIRÓ
    if (response.statusCode == 401) {

      print("TOKEN EXPIRADO → REFRESH GLOBAL");

      token = await AuthApi.refreshToken();

      if (token == null) {
        throw Exception("Sesión expirada");
      }

      // 🔁 REINTENTO
      final retry = await http.get(
        Uri.parse("$baseUrl$endpoint"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      return retry;
    }

    return response;
  }
}