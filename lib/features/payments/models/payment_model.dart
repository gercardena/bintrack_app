class Payment {
  final int id;
  final int saleId;
  final String saleNumero;
  final String clienteNombre;
  final double monto;
  final String metodo;
  final String? referencia;
  final String fecha;

  Payment({
    required this.id,
    required this.saleId,
    required this.saleNumero,
    required this.clienteNombre,
    required this.monto,
    required this.metodo,
    required this.referencia,
    required this.fecha,
  });

  factory Payment.fromJson(
    Map<String, dynamic> json,
  ) {
    return Payment(
      id: int.tryParse(
            json["id"].toString(),
          ) ??
          0,
      saleId: int.tryParse(
            json["sale"].toString(),
          ) ??
          0,
      saleNumero:
          (json["sale_numero"] ?? "").toString(),
      clienteNombre:
          (json["cliente_nombre"] ?? "").toString(),
      monto: double.tryParse(
            json["monto"].toString(),
          ) ??
          0,
      metodo:
          (json["metodo"] ?? "").toString(),
      referencia:
          json["referencia"]?.toString(),
      fecha: (json["fecha"] ?? "").toString(),
    );
  }
}