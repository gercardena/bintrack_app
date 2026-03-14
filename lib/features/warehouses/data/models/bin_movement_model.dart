class BinMovement {

  final int id;
  final int cliente;
  final int binType;
  final String tipoMovimiento;
  final int cantidad;
  final String depositoPagado;
  final String fecha;

  BinMovement({
    required this.id,
    required this.cliente,
    required this.binType,
    required this.tipoMovimiento,
    required this.cantidad,
    required this.depositoPagado,
    required this.fecha,
  });

  factory BinMovement.fromJson(Map<String, dynamic> json) {

    return BinMovement(
      id: json['id'],
      cliente: json['cliente'],
      binType: json['bin_type'],
      tipoMovimiento: json['tipo_movimiento'],
      cantidad: json['cantidad'],
      depositoPagado: json['deposito_pagado'],
      fecha: json['fecha'],
    );
  }

}