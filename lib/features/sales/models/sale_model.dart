class Sale {

  final int id;
  final String numero; // 🔥 IMPORTANTE
  final int? clienteId;
  final String? clienteNombre;
  final double total;
  final String estado;
  final List<SaleItem> items;

  Sale({
    required this.id,
    required this.numero,
    required this.total,
    required this.estado,
    required this.items,
    this.clienteId,
    this.clienteNombre,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {

    final itemsJson = json['items'];

    return Sale(
      id: json['id'] as int,

      // 🔥 SOLUCIONA TU ERROR ACTUAL
      numero: (json['numero'] ?? '').toString(),

      clienteId: json['cliente'] as int?,
      clienteNombre: json['cliente_nombre']?.toString(),

      // 🔥 PROTEGIDO
      total: double.tryParse(json['total'].toString()) ?? 0.0,

      estado: (json['estado'] ?? '').toString(),

      // 🔥 PROTECCIÓN TOTAL
      items: itemsJson is List
          ? itemsJson.map((e) => SaleItem.fromJson(e)).toList()
          : [],
    );
  }
}

/////////////////////////////////////////////////////////

class SaleItem {

  final String productNombre;
  final String binNombre;
  final int cantidad;
  final int binsCantidad;

  SaleItem({
    required this.productNombre,
    required this.binNombre,
    required this.cantidad,
    required this.binsCantidad,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {

    return SaleItem(
      productNombre: (json['product_nombre'] ?? '').toString(),
      binNombre: (json['bin_nombre'] ?? '').toString(),

      cantidad: json['cantidad'] ?? 0,

      // 🔥 CLAVE PARA BINS
      binsCantidad: json['bins_cantidad'] ?? 0,
    );
  }
}