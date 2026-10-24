import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/api_service.dart';
import '../models/account_summary.dart';

class AccountService {
  Map<String, dynamic> _read(http.Response response, int expected) {
    if (response.statusCode == expected) {
      return jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
    }
    if (response.statusCode == 403) {
      throw Exception(
        'Solo el principal puede administrar usuarios y suscripción.',
      );
    }
    if (response.statusCode == 400) {
      try {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is Map) {
          final messages = data.entries
              .map((entry) {
                final value = entry.value is List
                    ? (entry.value as List).join(' ')
                    : entry.value.toString();
                return entry.key == 'detail' ? value : '${entry.key}: $value';
              })
              .join('\n');
          throw AccountValidationException(messages);
        }
      } on FormatException {
        // Do not expose HTML error pages or server internals.
      }
    }
    throw Exception(
      'No se pudo completar la operación. Revisa la conexión e inténtalo nuevamente.',
    );
  }

  Future<AccountSummary> load() async => AccountSummary.fromJson(
    _read(await ApiService.get('/accounts/cuenta/'), 200),
  );

  Future<void> create(Map<String, dynamic> fields) async {
    _read(await ApiService.post('/accounts/cuenta/', body: fields), 201);
  }

  Future<void> update(int id, Map<String, dynamic> fields) async {
    _read(
      await ApiService.put('/accounts/cuenta/usuarios/$id/', body: fields),
      200,
    );
  }
}

class AccountValidationException implements Exception {
  final String message;
  AccountValidationException(this.message);
  @override
  String toString() => message;
}
