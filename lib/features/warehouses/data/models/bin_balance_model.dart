class BinBalance {

  final int clienteId;
  final String clienteNombre;

  final int binTypeId;
  final String binNombre;

  final String valorDeposito;

  final int entregados;
  final int devueltos;
  final int saldo;

  final String depositoPendiente;
  final String depositoRecibido;
  final String depositoDevuelto;
  final String depositoRetenido;

  BinBalance({
    required this.clienteId,
    required this.clienteNombre,

    required this.binTypeId,
    required this.binNombre,

    required this.valorDeposito,

    required this.entregados,
    required this.devueltos,
    required this.saldo,

    required this.depositoPendiente,
    required this.depositoRecibido,
    required this.depositoDevuelto,
    required this.depositoRetenido,
  });

  factory BinBalance.fromJson(
    Map<String, dynamic> json,
  ) {

    return BinBalance(

      clienteId: json["cliente_id"],
      clienteNombre: json["cliente_nombre"],

      binTypeId: json["bin_type_id"],
      binNombre: json["bin_nombre"],

      valorDeposito:
          json["valor_deposito"].toString(),

      entregados: json["entregados"],
      devueltos: json["devueltos"],
      saldo: json["saldo"],

      depositoPendiente:
          json["deposito_pendiente"].toString(),
      depositoRecibido:
          (json["deposito_recibido"] ?? "0").toString(),
      depositoDevuelto:
          (json["deposito_devuelto"] ?? "0").toString(),
      depositoRetenido:
          (json["deposito_retenido"] ?? "0").toString(),
    );
  }
}
