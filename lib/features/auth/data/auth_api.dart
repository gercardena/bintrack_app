import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApi {
  static const String _baseUrl = 'http://192.168.11.215:8000'; // <- Cambia a tu backend real

  /// Login devuelve un Map con 'access' y 'refresh'
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/login'); // Endpoint de login
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      // Validar que venga access y refresh
      if (body['access'] != null && body['refresh'] != null) {
        return body;
      } else {
        throw Exception('Tokens no encontrados en la respuesta');
      }
    } else {
      throw Exception('Login fallido: ${response.statusCode}');
    }
  }
}
