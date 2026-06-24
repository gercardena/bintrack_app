import 'dart:convert';

import '../../../core/services/api_service.dart';
import '../models/payment_model.dart';

class PaymentsService {
  Future<List<Payment>> getPayments() async {
    final response = await ApiService.get(
      "/pagos/",
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Error cargando pagos: ${response.body}",
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        "Respuesta inválida al cargar pagos",
      );
    }

    return decoded
        .map(
          (item) => Payment.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}