import 'dart:convert';
import '../../../core/http/http_client.dart';

class UserApi {

  /// Endpoint protegido de prueba
  /// Debe requerir JWT en el backend
  static Future<Map<String, dynamic>> getProfile() async {

    final response = await HttpClient.get(
      '/api/accounts/user/profile/', // ⚠️ ajusta según tu endpoint real
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Error loading profile (${response.statusCode}) ${response.body}',
      );
    }
  }
}
