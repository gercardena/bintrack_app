class Invoice {

  final int id;
  final String cliente;
  final String total;
  final String fecha;

  Invoice({
    required this.id,
    required this.cliente,
    required this.total,
    required this.fecha,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {

    return Invoice(
      id: json['id'],
      cliente: json['cliente_nombre'] ?? "Cliente",
      total: json['total'].toString(),
      fecha: json['fecha_creacion'] ?? "",
    );

  }
}