import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/auth/user_controller.dart';
import '../../../core/config/api_config.dart';
import 'token_storage.dart';

class AuthApi {
  static const String _baseUrl = ApiConfig.host;

  static const Duration _timeout = Duration(
    seconds: 15,
  );

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/auth/login/'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(_timeout);

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
        'No se pudo iniciar sesión. '
        'Verifica tus datos e intenta nuevamente.',
      );
    } on TimeoutException {
      throw Exception(
        'El servidor tardó demasiado en responder. '
        'Intenta nuevamente.',
      );
    } on SocketException {
      throw Exception(
        'No pudimos conectar con el servidor. '
        'Revisa tu conexión o intenta nuevamente.',
      );
    } on http.ClientException {
      throw Exception(
        'No pudimos conectar con el servidor. '
        'Revisa tu conexión o intenta nuevamente.',
      );
    }
  }

  static Future<String?> refreshToken() async {
    final refresh = await TokenStorage.getRefreshToken();

    if (refresh == null) {
      return null;
    }

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/auth/refresh/'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'refresh': refresh,
            }),
          )
          .timeout(_timeout);

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
    } on TimeoutException {
      await TokenStorage.clearTokens();
      return null;
    } on SocketException {
      await TokenStorage.clearTokens();
      return null;
    } on http.ClientException {
      await TokenStorage.clearTokens();
      return null;
    }
  }
}