class ProductPresentation {
  final int id;
  final int productId;
  final String productNombre;

  final int binTypeId;
  final String binNombre;

  final double precio;
  final bool activo;

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
    required this.stockId,
    required this.stockCantidad,
  });

  factory ProductPresentation.fromJson(
    Map<String, dynamic> json,
  ) {
    final stock = json["stock"];

    return ProductPresentation(
      id: json["id"] as int,
      productId: json["product"] as int,
      productNombre: json["product_nombre"]?.toString() ?? "",
      binTypeId: json["bin_type"] as int,
      binNombre: json["bin_nombre"]?.toString() ?? "",
      precio: double.tryParse(
            json["precio"].toString(),
          ) ??
          0,
      activo: json["activo"] == true,
      stockId: stock is Map<String, dynamic>
          ? stock["id"] as int?
          : null,
      stockCantidad: stock is Map<String, dynamic>
          ? stock["cantidad"] as int? ?? 0
          : 0,
    );
  }
}