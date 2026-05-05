import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../features/auth/data/token_storage.dart';
import '../../features/auth/data/auth_api.dart';

class ApiService {

  static const String baseUrl = "http://192.168.11.215:8000/api";

  // ==========================
  // 🔹 MÉTODO BASE
  // ==========================

  static Future<http.Response> _request({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {

    String? token = await TokenStorage.getAccessToken();

    final url = Uri.parse("$baseUrl$endpoint");

    Map<String, String> headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    http.Response response;

    switch (method) {
      case "POST":
        response = await http.post(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;

      case "PUT":
        response = await http.put(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;

      case "DELETE":
        response = await http.delete(
          url,
          headers: headers,
        );
        break;

      default: // GET
        response = await http.get(
          url,
          headers: headers,
        );
    }

    // ==========================
    // 🔥 TOKEN EXPIRADO
    // ==========================
    if (response.statusCode == 401) {

      print("🔁 TOKEN EXPIRADO → REFRESH");

      final newToken = await AuthApi.refreshToken();

      if (newToken == null) {

        print("❌ REFRESH FALLÓ → LOGOUT");

        await TokenStorage.clearTokens();
        throw Exception("Sesión expirada");
      }

      final retryHeaders = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $newToken",
      };

      switch (method) {
        case "POST":
          return await http.post(
            url,
            headers: retryHeaders,
            body: body != null ? jsonEncode(body) : null,
          );

        case "PUT":
          return await http.put(
            url,
            headers: retryHeaders,
            body: body != null ? jsonEncode(body) : null,
          );

        case "DELETE":
          return await http.delete(
            url,
            headers: retryHeaders,
          );

        default:
          return await http.get(
            url,
            headers: retryHeaders,
          );
      }
    }

    return response;
  }

  // ==========================
  // 🔹 MÉTODOS PÚBLICOS
  // ==========================

  static Future<http.Response> get(String endpoint) {
    return _request(method: "GET", endpoint: endpoint);
  }

  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) {
    return _request(
      method: "POST",
      endpoint: endpoint,
      body: body,
    );
  }

  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) {
    return _request(
      method: "PUT",
      endpoint: endpoint,
      body: body,
    );
  }

  static Future<http.Response> delete(String endpoint) {
    return _request(
      method: "DELETE",
      endpoint: endpoint,
    );
  }
}