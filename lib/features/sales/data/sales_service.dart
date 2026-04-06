import 'dart:convert';
import '../models/sale_model.dart';
import '../../../core/services/api_service.dart';

class SalesService {

  Future<List<Sale>> getSales() async {

    final response = await ApiService.get("/ventas/sales/");

    print("SALES STATUS: ${response.statusCode}");
    print("SALES BODY: ${response.body}");

    if (response.statusCode == 200) {

      final List data = jsonDecode(response.body);

      return data.map((e) => Sale.fromJson(e)).toList();

    } else {

      throw Exception("Error cargando ventas");

    }
  }

  Future<void> generateInvoice(int saleId) async {

    final response = await ApiService.get("/facturas/$saleId/generar/");

    print("INVOICE GENERATE STATUS: ${response.statusCode}");
    print("INVOICE GENERATE BODY: ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Error al generar factura");
    }
  }
}