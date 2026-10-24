import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/user_controller.dart';

class SubscriptionReadOnlyException implements Exception {
  static const message =
      'La cuenta está en modo solo lectura. Puedes consultar tus datos, '
      'pero no registrar ni modificar operaciones. El principal debe regularizar la suscripción.';
  @override
  String toString() => message;
}

http.Response checkSubscriptionResponse(http.Response response) {
  if (response.statusCode != 403) return response;
  try {
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (data is Map && data['code'] == 'subscription_read_only') {
      UserController().markSubscriptionReadOnly(
        data['estado']?.toString() ?? 'vencida',
      );
      throw SubscriptionReadOnlyException();
    }
  } on FormatException {
    // Keep unrelated permission failures and HTML responses with their caller.
  }
  return response;
}
