class ProductPresentation {
  final int id;
  final int productId;
  final String productNombre;

  final int binTypeId;
  final String binNombre;

  final double precio;
  final bool activo;

  final String? unidadMedida;
  final double? cantidadPorEnvase;
  final int? envaseContenidoId;
  final String? envaseContenidoNombre;
  final double? cantidadEnvaseContenido;

  final int? stockId;
  final int stockCantidad;

  const ProductPresentation({
    required this.id,
    required this.productId,
    required this.productNombre,
    required this.binTypeId,
    required this.binNombre,
    required this.precio,
    required this.activo,
    required this.unidadMedida,
    required this.cantidadPorEnvase,
    required this.envaseContenidoId,
    required this.envaseContenidoNombre,
    required this.cantidadEnvaseContenido,
    required this.stockId,
    required this.stockCantidad,
  });

  factory ProductPresentation.fromJson(
    Map<String, dynamic> json,
  ) {
    final stock = json["stock"];

    return ProductPresentation(
      id: parseInt(json["id"]),
      productId: parseInt(json["product"]),
      productNombre: json["product_nombre"]?.toString() ?? "",
      binTypeId: parseInt(json["bin_type"]),
      binNombre: json["bin_nombre"]?.toString() ?? "",
      precio: parseDouble(json["precio"]),
      activo: json["activo"] == true,
      unidadMedida: emptyToNull(json["unidad_medida"]),
      cantidadPorEnvase: parseNullableDouble(
        json["cantidad_por_envase"],
      ),
      envaseContenidoId: parseNullableInt(
        json["envase_contenido"],
      ),
      envaseContenidoNombre: emptyToNull(
        json["envase_contenido_nombre"],
      ),
      cantidadEnvaseContenido: parseNullableDouble(
        json["cantidad_envase_contenido"],
      ),
      stockId: stock is Map<String, dynamic>
          ? parseNullableInt(stock["id"])
          : null,
      stockCantidad: stock is Map<String, dynamic>
          ? parseInt(stock["cantidad"])
          : 0,
    );
  }

  bool get tieneCapacidad {
    return cantidadPorEnvase != null &&
        unidadMedida != null &&
        unidadMedida!.trim().isNotEmpty;
  }

  bool get tieneContenido {
    return cantidadEnvaseContenido != null &&
        envaseContenidoNombre != null &&
        envaseContenidoNombre!.trim().isNotEmpty;
  }

  String? get capacidadDescripcion {
    if (!tieneCapacidad) return null;

    return "${cantidadPorEnvase!.toStringAsFixed(2)} "
        "${unidadMedida!}";
  }

  String? get contenidoDescripcion {
    if (!tieneContenido) return null;

    return "${cantidadEnvaseContenido!.toStringAsFixed(2)} "
        "${envaseContenidoNombre!}";
  }

  static int parseInt(dynamic value) {
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? parseNullableInt(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    if (text.isEmpty || text == "null") {
      return null;
    }

    return int.tryParse(text);
  }

  static double parseDouble(dynamic value) {
    return double.tryParse(value.toString()) ?? 0;
  }

  static double? parseNullableDouble(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    if (text.isEmpty || text == "null") {
      return null;
    }

    return double.tryParse(text);
  }

  static String? emptyToNull(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    if (text.isEmpty || text == "null") {
      return null;
    }

    return text;
  }
}