import 'dart:convert';
import 'package:http/http.dart' as http;

import 'token_storage.dart';
import '../../../core/auth/user_controller.dart';

class AuthApi {

  // ⭐ URL BASE BACKEND DJANGO
  static const String _baseUrl = 'http://192.168.11.215:8000';

  /// 🔥 LOGIN
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {

    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    print("LOGIN STATUS: ${response.statusCode}");
    print("LOGIN BODY: ${response.body}");

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      // ✅ Guardar tokens
      await TokenStorage.saveTokens(
        access: data['access'],
        refresh: data['refresh'],
      );

      // ⭐ Cargar usuario
      await UserController().loadUser();

      return data;

    } else {

      throw Exception(
        'Login failed (${response.statusCode}) ${response.body}',
      );

    }
  }

  /// 🔥 REFRESH TOKEN (CLAVE DEL SISTEMA)
  static Future<String?> refreshToken() async {

    final refresh = await TokenStorage.getRefreshToken();

    if (refresh == null) {
      return null;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/refresh/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'refresh': refresh,
      }),
    );

    print("REFRESH STATUS: ${response.statusCode}");
    print("REFRESH BODY: ${response.body}");

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      final newAccess = data['access'];

      // ✅ Guardar nuevo access
      await TokenStorage.saveTokens(
        access: newAccess,
        refresh: refresh,
      );

      return newAccess;

    } else {

      // ❌ sesión inválida
      await TokenStorage.clearTokens();

      return null;

    }
  }
}