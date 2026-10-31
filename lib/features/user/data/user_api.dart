import 'dart:convert';

import '../../../core/services/api_service.dart';

class UserApi {
  static Future<Map<String, dynamic>> getProfile() async {
    // ApiService refreshes an expired access token before retrying. The profile
    // drives the home and subscription state, so it must not use a separate
    // HTTP path that logs the user out prematurely.
    final response = await ApiService.get('/accounts/user/profile/');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('No se pudo actualizar el perfil.');
  }
}
