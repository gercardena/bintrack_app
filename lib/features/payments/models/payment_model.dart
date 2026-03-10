class Payment {

  final int id;
  final int factura;
  final String monto;
  final String metodo;
  final String fecha;

  Payment({
    required this.id,
    required this.factura,
    required this.monto,
    required this.metodo,
    required this.fecha,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {

    return Payment(
      id: json['id'],
      factura: json['factura'],
      monto: json['monto'].toString(),
      metodo: json['metodo'] ?? "",
      fecha: json['fecha'] ?? "",
    );

  }
}