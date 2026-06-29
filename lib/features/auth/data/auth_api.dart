import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/auth/user_controller.dart';
import '../../../core/config/api_config.dart';
import 'token_storage.dart';

class AuthApi {
  static const String _baseUrl = ApiConfig.host;

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

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      await TokenStorage.saveTokens(
        access: data['access'],
        refresh: data['refresh'],
      );

      await UserController().loadUser();

      return data;
    }

    throw Exception(
      'No se pudo iniciar sesión. Verifica tus datos e intenta nuevamente.',
    );
  }

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

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final newAccess = data['access'];

      await TokenStorage.saveTokens(
        access: newAccess,
        refresh: refresh,
      );

      return newAccess;
    }

    await TokenStorage.clearTokens();

    return null;
  }
}