import 'dart:convert';

import '../../../core/services/api_service.dart';
import '../models/sales_report_model.dart';

class SalesReportService {
  Future<SalesReport> getReport({
    required String periodo,
  }) async {
    final response = await ApiService.get(
      "/ventas/sales/reporte/?periodo=$periodo",
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Error cargando reporte de ventas: ${response.body}",
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        "Respuesta inválida al cargar reporte de ventas",
      );
    }

    return SalesReport.fromJson(decoded);
  }
}