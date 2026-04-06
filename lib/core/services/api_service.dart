import 'package:http/http.dart' as http;

import '../../features/auth/data/token_storage.dart';
import '../../features/auth/data/auth_api.dart';

class ApiService {

  static const String baseUrl = "http://192.168.11.215:8000/api";

  // 🔥 GET CON MANEJO PRO
  static Future<http.Response> get(String endpoint) async {

    String? token = await TokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    // 🔥 TOKEN EXPIRADO
    if (response.statusCode == 401) {

      print("TOKEN EXPIRADO → REFRESH GLOBAL");

      final newToken = await AuthApi.refreshToken();

      // ❗ SI FALLA REFRESH
      if (newToken == null) {

        print("REFRESH FALLÓ → LOGOUT");

        await TokenStorage.clearTokens(); // 🔥 CLAVE

        throw Exception("Sesión expirada");
      }

      // 🔁 REINTENTO CON TOKEN NUEVO
      final retry = await http.get(
        Uri.parse("$baseUrl$endpoint"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $newToken",
        },
      );

      return retry;
    }

    return response;
  }
}