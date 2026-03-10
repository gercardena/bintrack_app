import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../auth/data/token_storage.dart';
import '../models/payment_model.dart';

class PaymentsService {

  final String baseUrl = 'http://192.168.11.215:8000/api';

  Future<List<Payment>> getPayments() async {

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse('$baseUrl/pagos/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("PAYMENTS STATUS: ${response.statusCode}");
    print("PAYMENTS BODY: ${response.body}");

    if (response.statusCode == 200) {

      final List data = jsonDecode(response.body);

      return data.map((e) => Payment.fromJson(e)).toList();

    }

    throw Exception('Error cargando pagos');
  }
}