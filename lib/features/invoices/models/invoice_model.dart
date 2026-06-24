class Invoice {
  final int id;
  final int saleId;
  final String saleNumero;
  final String saleEstado;
  final String numero;
  final String clienteNombre;
  final String clienteRut;
  final String? clienteDireccion;
  final double subtotal;
  final double iva;
  final double total;
  final String fechaEmision;

  Invoice({
    required this.id,
    required this.saleId,
    required this.saleNumero,
    required this.saleEstado,
    required this.numero,
    required this.clienteNombre,
    required this.clienteRut,
    required this.clienteDireccion,
    required this.subtotal,
    required this.iva,
    required this.total,
    required this.fechaEmision,
  });

  factory Invoice.fromJson(
    Map<String, dynamic> json,
  ) {
    return Invoice(
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
      saleEstado:
          (json["sale_estado"] ?? "").toString(),
      numero:
          (json["numero"] ?? "").toString(),
      clienteNombre:
          (json["cliente_nombre"] ?? "").toString(),
      clienteRut:
          (json["cliente_rut"] ?? "").toString(),
      clienteDireccion:
          json["cliente_direccion"]?.toString(),
      subtotal: double.tryParse(
            json["subtotal"].toString(),
          ) ??
          0,
      iva: double.tryParse(
            json["iva"].toString(),
          ) ??
          0,
      total: double.tryParse(
            json["total"].toString(),
          ) ??
          0,
      fechaEmision:
          (json["fecha_emision"] ?? "").toString(),
    );
  }
}