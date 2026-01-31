import 'dart:convert';
import 'package:http/http.dart' as http;

import 'token_storage.dart';

class AuthApi {
  static const String baseUrl = 'http://192.168.11.215:8000';

  static Future<void> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/login/');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    print('STATUS CODE: ${response.statusCode}');
    print('RESPONSE BODY: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final accessToken = data['access'];
      final refreshToken = data['refresh'];

      await TokenStorage.saveTokens(
        access: accessToken,
        refresh: refreshToken,
      );

      print('TOKENS GUARDADOS CORRECTAMENTE');
    } else {
      throw Exception('Error en login');
    }
  }
}
