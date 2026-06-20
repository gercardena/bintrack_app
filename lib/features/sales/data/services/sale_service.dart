import 'dart:convert';
import '../models/sale_model.dart';
import '../../../../core/services/api_service.dart';

class SalesService {

  // =========================================
  // 🔥 GET SALES
  // =========================================
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

  // =========================================
  // 🔥 CREAR VENTA
  // =========================================
  Future<int> createSale({
    required int clienteId,
  }) async {

    final response = await ApiService.post(
      "/ventas/sales/",
      body: {
        "cliente": clienteId,
      },
    );

    print("CREATE SALE STATUS: ${response.statusCode}");
    print("CREATE SALE BODY: ${response.body}");

    if (response.statusCode == 201 || response.statusCode == 200) {

      final data = jsonDecode(response.body);

      return data["id"];
    }

    throw Exception("Error creando venta");
  }

  // =========================================
  // 🔥 AGREGAR ITEM
  // =========================================
  Future<void> addItemToSale({
    required int saleId,
    required int productId,
    required int binId,
    required int cantidad,
    required double precio,
  }) async {

    final response = await ApiService.post(
      "/ventas/items/",
      body: {
        "sale": saleId,
        "product": productId,
        "bin": binId,
        "cantidad": cantidad,
        "bins_cantidad": cantidad,
        "precio_unitario": precio,
      },
    );

    print("ADD ITEM STATUS: ${response.statusCode}");
    print("ADD ITEM BODY: ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Error al agregar item a la venta");
    }
  }

  // =========================================
  // 🔥 CONFIRMAR
  // =========================================
  Future<void> confirmSale(int id) async {
    final response = await ApiService.post("/ventas/sales/$id/confirm/");

    print("CONFIRM SALE STATUS: ${response.statusCode}");
    print("CONFIRM SALE BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Error al confirmar venta");
    }
  }

  // =========================================
  // 🔥 PAGAR
  // =========================================
  Future<void> paySale(int id) async {
    final response = await ApiService.post("/ventas/sales/$id/pay/");

    print("PAY SALE STATUS: ${response.statusCode}");
    print("PAY SALE BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Error al pagar venta");
    }
  }

  // =========================================
  // 🔥 FACTURAR
  // =========================================
  Future<void> generateInvoice(int saleId) async {

    final response = await ApiService.post(
      "/facturas/$saleId/generar/",
    );

    print("INVOICE STATUS: ${response.statusCode}");
    print("INVOICE BODY: ${response.body}");

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return;
    }

    try {

      final data = jsonDecode(response.body);

      throw Exception(
        data["error"] ?? "Error generando factura",
      );

    } catch (_) {

      throw Exception(
        "Error generando factura",
      );
    }
  }
}