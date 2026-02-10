import 'package:http/http.dart' as http;
import '../../features/auth/data/token_storage.dart';
import '../auth/auth_controller.dart';

class HttpClient {

  static const String _baseUrl = "http://192.168.11.215:8000";

  /// 🔥 GET protegido
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

  /// 🔥 POST protegido
  static Future<http.Response> post(
    String endpoint, {
    Map<String,String>? headers,
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

  /// 🔥 Interceptor 401
  static void _handleAuth(http.Response response) {

    if (response.statusCode == 401) {

      TokenStorage.clearTokens();

      AuthController().forceLogout();
    }
  }
}
