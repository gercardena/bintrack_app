import 'dart:convert';

import '../../../core/services/api_service.dart';
import 'models/product_presentation_model.dart';

class ProductPresentationsService {
  Future<List<ProductPresentation>> getAll() async {
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
        .toList();
  }

  Future<List<ProductPresentation>> getByProduct(
    int productId,
  ) async {
    final presentations = await getAll();

    return presentations
        .where(
          (presentation) =>
              presentation.productId == productId,
        )
        .toList();
  }

  Future<ProductPresentation> createPresentation({
    required int productId,
    required int binTypeId,
    required double precio,
    String? unidadMedida,
    double? cantidadPorEnvase,
    int? envaseContenidoId,
    double? cantidadEnvaseContenido,
  }) async {
    final body = <String, dynamic>{
      "product": productId,
      "bin_type": binTypeId,
      "precio": precio.toStringAsFixed(2),
      "activo": true,
    };

    if (unidadMedida != null && unidadMedida.trim().isNotEmpty) {
      body["unidad_medida"] = unidadMedida.trim();
    }

    if (cantidadPorEnvase != null && cantidadPorEnvase > 0) {
      body["cantidad_por_envase"] = cantidadPorEnvase;
    }

    if (envaseContenidoId != null) {
      body["envase_contenido"] = envaseContenidoId;
    }

    if (cantidadEnvaseContenido != null &&
        cantidadEnvaseContenido > 0) {
      body["cantidad_envase_contenido"] =
          cantidadEnvaseContenido;
    }

    final response = await ApiService.post(
      "/productos/presentations/",
      body: body,
    );

    if (response.statusCode != 201) {
      throw Exception(
        "Error creando presentación: ${response.body}",
      );
    }

    final data = jsonDecode(response.body);

    return ProductPresentation.fromJson(
      data as Map<String, dynamic>,
    );
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
        "unidad_medida": presentation.unidadMedida ?? "",
        "cantidad_por_envase": presentation.cantidadPorEnvase,
        "envase_contenido": presentation.envaseContenidoId,
        "cantidad_envase_contenido":
            presentation.cantidadEnvaseContenido,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Error guardando precio: ${response.body}",
      );
    }
  }

  Future<void> saveMetadata({
    required ProductPresentation presentation,
    String? unidadMedida,
    double? cantidadPorEnvase,
    int? envaseContenidoId,
    double? cantidadEnvaseContenido,
  }) async {
    final body = <String, dynamic>{
      "product": presentation.productId,
      "bin_type": presentation.binTypeId,
      "precio": presentation.precio.toStringAsFixed(2),
      "activo": presentation.activo,
      "unidad_medida": unidadMedida?.trim() ?? "",
      "cantidad_por_envase": cantidadPorEnvase,
      "envase_contenido": envaseContenidoId,
      "cantidad_envase_contenido": cantidadEnvaseContenido,
    };

    final response = await ApiService.put(
      "/productos/presentations/${presentation.id}/",
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Error guardando detalle: ${response.body}",
      );
    }
  }

  Future<void> saveActive({
    required ProductPresentation presentation,
    required bool activo,
  }) async {
    final response = await ApiService.put(
      "/productos/presentations/${presentation.id}/",
      body: {
        "product": presentation.productId,
        "bin_type": presentation.binTypeId,
        "precio": presentation.precio.toStringAsFixed(2),
        "activo": activo,
        "unidad_medida": presentation.unidadMedida ?? "",
        "cantidad_por_envase": presentation.cantidadPorEnvase,
        "envase_contenido": presentation.envaseContenidoId,
        "cantidad_envase_contenido":
            presentation.cantidadEnvaseContenido,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Error cambiando estado: ${response.body}",
      );
    }
  }

  Future<void> deletePresentation(
    int presentationId,
  ) async {
    final response = await ApiService.delete(
      "/productos/presentations/$presentationId/",
    );

    if (response.statusCode != 204) {
      throw Exception(
        "Error eliminando presentación incompleta",
      );
    }
  }
}



