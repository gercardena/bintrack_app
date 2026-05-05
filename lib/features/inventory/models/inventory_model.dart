class Inventory {
  final int id;
  final int productId;
  final String productNombre;
  final int binId;
  final String binNombre;
  final int cantidad;
  final String fechaCreacion;
  final String fechaActualizacion;

  Inventory({
    required this.id,
    required this.productId,
    required this.productNombre,
    required this.binId,
    required this.binNombre,
    required this.cantidad,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'],
      productId: json['product'],
      productNombre: json['product_nombre'] ?? "Producto",
      binId: json['bin'],
      binNombre: json['bin_nombre'] ?? "Bin",
      cantidad: json['cantidad'] ?? 0,
      fechaCreacion: json['fecha_creacion'] ?? "",
      fechaActualizacion: json['fecha_actualizacion'] ?? "",
    );
  }
}