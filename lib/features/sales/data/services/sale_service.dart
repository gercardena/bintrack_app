import 'dart:convert';

import '../../../../core/services/api_service.dart';
import '../models/sale_model.dart';

class SalesService {
  Future<List<Sale>> getSales() async {
    final response = await ApiService.get(
      "/ventas/sales/",
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Error cargando ventas: ${response.body}",
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        "Respuesta inválida al cargar ventas",
      );
    }

    return decoded
        .map(
          (item) => Sale.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<Sale> getSale(int id) async {
    final response = await ApiService.get(
      "/ventas/sales/$id/",
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Error cargando venta: ${response.body}",
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        "Respuesta inválida al cargar la venta",
      );
    }

    return Sale.fromJson(decoded);
  }

  Future<int> createSale({
    required int clienteId,
  }) async {
    final response = await ApiService.post(
      "/ventas/sales/",
      body: {
        "cliente": clienteId,
      },
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        "Error creando venta: ${response.body}",
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic> ||
        decoded["id"] is! int) {
      throw Exception(
        "Respuesta inválida al crear la venta",
      );
    }

    return decoded["id"] as int;
  }

  Future<void> addItemToSale({
    required int saleId,
    required int productId,
    required int binId,
    required int cantidad,
  }) async {
    if (cantidad <= 0) {
      throw Exception(
        "La cantidad debe ser mayor que cero",
      );
    }

    final response = await ApiService.post(
      "/ventas/items/",
      body: {
        "sale": saleId,
        "product": productId,
        "bin": binId,
        "cantidad": cantidad,
      },
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        "Error agregando producto: ${response.body}",
      );
    }
  }

  Future<void> deleteSaleItem(int itemId) async {
    final response = await ApiService.delete(
      "/ventas/items/$itemId/",
    );

    if (response.statusCode != 204) {
      throw Exception(
        "Error eliminando producto: ${response.body}",
      );
    }
  }

  Future<void> confirmSale(int id) async {
    final response = await ApiService.post(
      "/ventas/sales/$id/confirm/",
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Error confirmando venta: ${response.body}",
      );
    }
  }

  Future<void> paySale(int id) async {
    final response = await ApiService.post(
      "/ventas/sales/$id/pay/",
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Error pagando venta: ${response.body}",
      );
    }
  }

  Future<void> generateInvoice(int saleId) async {
    final response = await ApiService.post(
      "/facturas/$saleId/generar/",
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        "Error generando factura: ${response.body}",
      );
    }
  }
}