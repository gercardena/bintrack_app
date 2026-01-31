import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://192.168.11.215:8000/api';

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: jsonEncode(body),
    );

    return response;
  }
}