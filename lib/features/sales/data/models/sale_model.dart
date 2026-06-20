class Sale {

  final int id;
  final String numero;
  final int? clienteId;
  final String? clienteNombre;
  final double subtotal;
  final double iva;
  final double total;
  final String estado;
  final List<SaleItem> items;

  Sale({
    required this.id,
    required this.numero,
    required this.subtotal,
    required this.iva,
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
      numero: (json['numero'] ?? '').toString(),
      clienteId: json['cliente'] as int?,
      clienteNombre: json['cliente_nombre']?.toString(),
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0.0,
      iva: double.tryParse(json['iva'].toString()) ?? 0.0,
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      estado: (json['estado'] ?? '').toString(),
      items: itemsJson is List
          ? itemsJson.map((e) => SaleItem.fromJson(e)).toList()
          : [],
    );
  }
}

/////////////////////////////////////////////////////////

class SaleItem {

  final int id;
  final int saleId;
  final int productId;
  final String productNombre;
  final int binId;
  final String binNombre;
  final int cantidad;
  final int binsCantidad;
  final double precioUnitario;
  final double subtotal;

  SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productNombre,
    required this.binId,
    required this.binNombre,
    required this.cantidad,
    required this.binsCantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {

    return SaleItem(
      id: json['id'] ?? 0,
      saleId: json['sale'] ?? 0,
      productId: json['product'] ?? 0,
      productNombre: (json['product_nombre'] ?? '').toString(),
      binId: json['bin'] ?? 0,
      binNombre: (json['bin_nombre'] ?? '').toString(),
      cantidad: json['cantidad'] ?? 0,
      binsCantidad: json['bins_cantidad'] ?? 0,
      precioUnitario: double.tryParse(json['precio_unitario'].toString()) ?? 0.0,
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0.0,
    );
  }
}