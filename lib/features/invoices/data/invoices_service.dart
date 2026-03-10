import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../auth/data/token_storage.dart';
import '../models/invoice_model.dart';

class InvoicesService {

  final String baseUrl = 'http://192.168.11.215:8000/api';

  Future<List<Invoice>> getInvoices() async {

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse('$baseUrl/facturas/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("INVOICES STATUS: ${response.statusCode}");
    print("INVOICES BODY: ${response.body}");

    if (response.statusCode == 200) {

      final List data = jsonDecode(response.body);

      return data.map((e) => Invoice.fromJson(e)).toList();

    }

    throw Exception('Error cargando facturas');
  }
}