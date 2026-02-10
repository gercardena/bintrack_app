import 'dart:convert';
import 'package:http/http.dart' as http;

import 'token_storage.dart';

class AuthApi {

  static const String _baseUrl = 'http://192.168.11.215:8000';

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {

    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      // ✅ Guardar tokens reales
      await TokenStorage.saveTokens(
        access: data['access'],
        refresh: data['refresh'],
      );

      return data;

    } else {

      throw Exception(
        'Login failed (${response.statusCode}) ${response.body}',
      );

    }
  }
}
