class Sale {
  final int id;
  final String? cliente;
  final double total;
  final String estado;

  Sale({
    required this.id,
    required this.total,
    required this.estado,
    this.cliente,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      cliente: json['cliente']?['nombre'],
      total: double.parse(json['total'].toString()),
      estado: json['estado'] ?? '',
    );
  }
}