class Sale {
  final int id;
  final int? clienteId; // 🔥 ID del cliente
  final double total;
  final String estado;

  Sale({
    required this.id,
    required this.total,
    required this.estado,
    this.clienteId,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      clienteId: json['cliente'], // 🔥 ahora es int
      total: double.parse(json['total'].toString()),
      estado: json['estado'] ?? '',
    );
  }
}