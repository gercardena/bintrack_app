import 'dart:convert';

import '../../../core/services/api_service.dart';
import 'models/product_presentation_model.dart';

class ProductPresentationsService {
  Future<List<ProductPresentation>> getByProduct(
    int productId,
  ) async {
    final response = await ApiService.get(
      "/productos/presentations/",
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Error cargando presentaciones "
        "(${response.statusCode})",
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        "Respuesta inválida al cargar presentaciones",
      );
    }

    return decoded
        .map(
          (item) => ProductPresentation.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .where(
          (presentation) =>
              presentation.productId == productId,
        )
        .toList();
  }

  Future<void> saveStock({
    required ProductPresentation presentation,
    required int cantidad,
  }) async {
    if (cantidad < 0) {
      throw Exception(
        "La cantidad no puede ser negativa",
      );
    }

    final body = {
      "product": presentation.productId,
      "bin": presentation.binTypeId,
      "cantidad": cantidad,
    };

    final response = presentation.stockId == null
        ? await ApiService.post(
            "/inventario/stock/",
            body: body,
          )
        : await ApiService.put(
            "/inventario/stock/${presentation.stockId}/",
            body: body,
          );

    final success = response.statusCode == 200 ||
        response.statusCode == 201;

    if (!success) {
      throw Exception(
        "Error guardando stock: ${response.body}",
      );
    }
  }

  Future<void> savePrice({
    required ProductPresentation presentation,
    required double precio,
  }) async {
    if (precio <= 0) {
      throw Exception(
        "El precio debe ser mayor que cero",
      );
    }

    final response = await ApiService.put(
      "/productos/presentations/${presentation.id}/",
      body: {
        "product": presentation.productId,
        "bin_type": presentation.binTypeId,
        "precio": precio.toStringAsFixed(2),
        "activo": presentation.activo,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Error guardando precio: ${response.body}",
      );
    }
  }
}