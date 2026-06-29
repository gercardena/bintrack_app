import 'package:http/http.dart' as http;

import '../../features/auth/data/token_storage.dart';
import '../auth/auth_controller.dart';
import '../config/api_config.dart';

class HttpClient {
  static const String _baseUrl = ApiConfig.host;

  static Future<http.Response> get(String endpoint) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    _handleAuth(response);

    return response;
  }

  static Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      },
      body: body,
    );

    _handleAuth(response);

    return response;
  }

  static void _handleAuth(http.Response response) {
    if (response.statusCode == 401) {
      TokenStorage.clearTokens();

      AuthController().forceLogout();
    }
  }
}