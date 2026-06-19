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
    );
  }
}