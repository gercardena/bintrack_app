class BinBalance {
  final int clienteId;
  final String clienteNombre;
  final int entregados;
  final int devueltos;
  final int saldo;
  final String depositoPendiente;

  BinBalance({
    required this.clienteId,
    required this.clienteNombre,
    required this.entregados,
    required this.devueltos,
    required this.saldo,
    required this.depositoPendiente,
  });

  factory BinBalance.fromJson(Map<String, dynamic> json) {
    return BinBalance(
      clienteId: json['cliente_id'],
      clienteNombre: json['cliente_nombre'],
      entregados: json['entregados'],
      devueltos: json['devueltos'],
      saldo: json['saldo'],
      depositoPendiente: json['deposito_pendiente'].toString(),
    );
  }
}