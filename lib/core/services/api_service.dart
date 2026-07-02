import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../features/auth/data/auth_api.dart';
import '../../features/auth/data/token_storage.dart';
import '../config/api_config.dart';

class ApiService {
  static const String baseUrl = ApiConfig.apiBaseUrl;

  static const Duration _timeout = Duration(
    seconds: 15,
  );

  static const String connectionErrorMessage =
      "No pudimos conectar con el servidor. "
      "Revisa tu conexión o intenta nuevamente.";

  // ==========================
  // MÉTODO BASE
  // ==========================

  static Future<http.Response> _request({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    final token = await TokenStorage.getAccessToken();

    final url = Uri.parse("$baseUrl$endpoint");

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    try {
      final response = await _sendRequest(
        method: method,
        url: url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 401) {
        return await _retryWithRefresh(
          method: method,
          url: url,
          body: body,
        );
      }

      return response;
    } on TimeoutException {
      throw Exception(
        "El servidor tardó demasiado en responder. "
        "Intenta nuevamente.",
      );
    } on SocketException {
      throw Exception(connectionErrorMessage);
    } on http.ClientException {
      throw Exception(connectionErrorMessage);
    }
  }

  static Future<http.Response> _sendRequest({
    required String method,
    required Uri url,
    required Map<String, String> headers,
    Map<String, dynamic>? body,
  }) async {
    switch (method) {
      case "POST":
        return await http
            .post(
              url,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(_timeout);

      case "PUT":
        return await http
            .put(
              url,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(_timeout);

      case "DELETE":
        return await http
            .delete(
              url,
              headers: headers,
            )
            .timeout(_timeout);

      default:
        return await http
            .get(
              url,
              headers: headers,
            )
            .timeout(_timeout);
    }
  }

  static Future<http.Response> _retryWithRefresh({
    required String method,
    required Uri url,
    Map<String, dynamic>? body,
  }) async {
    final newToken = await AuthApi.refreshToken();

    if (newToken == null) {
      await TokenStorage.clearTokens();
      throw Exception("Sesión expirada. Inicia sesión nuevamente.");
    }

    final retryHeaders = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $newToken",
    };

    return await _sendRequest(
      method: method,
      url: url,
      headers: retryHeaders,
      body: body,
    );
  }

  // ==========================
  // MÉTODOS PÚBLICOS
  // ==========================

  static Future<http.Response> get(String endpoint) {
    return _request(
      method: "GET",
      endpoint: endpoint,
    );
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