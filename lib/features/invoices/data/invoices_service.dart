import 'dart:convert';

import '../../../core/services/api_service.dart';
import '../models/invoice_model.dart';

class InvoicesService {
  Future<Invoice> editar(
    Invoice invoice, {
    required String nombre,
    required String direccion,
    required String observaciones,
  }) async {
    final response = await ApiService.post(
      '/facturas/${invoice.id}/editar/',
      body: {
        'version': invoice.version,
        'cliente_nombre': nombre,
        'cliente_direccion': direccion,
        'observaciones': observaciones,
      },
    );
    if (response.statusCode == 409) {
      throw Exception(
        'Otra persona modificó este comprobante. Vuelve al listado, actualiza y ábrelo nuevamente.',
      );
    }
    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo guardar el comprobante. Revisa los datos e inténtalo nuevamente.',
      );
    }
    return Invoice.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> historial(int invoiceId) async {
    final response = await ApiService.get('/facturas/$invoiceId/historial/');
    if (response.statusCode != 200) {
      throw Exception('No se pudo cargar el historial.');
    }
    return (jsonDecode(response.body) as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();
  }

  Future<List<Invoice>> getInvoices() async {
    final response = await ApiService.get("/facturas/");

    if (response.statusCode != 200) {
      throw Exception("Error cargando comprobantes: ${response.body}");
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception("Respuesta inválida al cargar comprobantes");
    }

    return decoded
        .map((item) => Invoice.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
