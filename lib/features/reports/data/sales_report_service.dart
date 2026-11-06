import 'dart:convert';

import '../../../core/services/api_service.dart';
import '../models/sales_report_model.dart';

class SalesReportService {
  Future<SalesReport> getReport({
    required String periodo,
    DateTime? desde,
    DateTime? hasta,
  }) async {
    final query = <String, String>{
      'periodo': periodo,
      if (desde != null) 'desde': _apiDate(desde),
      if (hasta != null) 'hasta': _apiDate(hasta),
    };
    final response = await ApiService.get(
      "/ventas/sales/reporte/?${Uri(queryParameters: query).query}",
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

  String _apiDate(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}
