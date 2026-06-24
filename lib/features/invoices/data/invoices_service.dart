import 'dart:convert';

import '../../../core/services/api_service.dart';
import '../models/invoice_model.dart';

class InvoicesService {
  Future<List<Invoice>> getInvoices() async {
    final response = await ApiService.get(
      "/facturas/",
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Error cargando facturas: ${response.body}",
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        "Respuesta inválida al cargar facturas",
      );
    }

    return decoded
        .map(
          (item) => Invoice.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}