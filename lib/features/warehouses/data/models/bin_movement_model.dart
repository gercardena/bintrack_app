class BinMovement {
  final int id;
  final int cliente;
  final String clienteNombre;
  final int binType;
  final String binNombre;
  final String tipoMovimiento;
  final int cantidad;
  final String depositoPagado;
  final String referencia;
  final String fecha;

  BinMovement({
    required this.id,
    required this.cliente,
    required this.clienteNombre,
    required this.binType,
    required this.binNombre,
    required this.tipoMovimiento,
    required this.cantidad,
    required this.depositoPagado,
    required this.referencia,
    required this.fecha,
  });

  factory BinMovement.fromJson(
    Map<String, dynamic> json,
  ) {
    return BinMovement(
      id: json['id'] ?? 0,
      cliente: json['cliente'] ?? 0,
      clienteNombre:
          (json['cliente_nombre'] ?? 'Sin cliente').toString(),
      binType: json['bin_type'] ?? 0,
      binNombre:
          (json['bin_nombre'] ?? 'Sin envase').toString(),
      tipoMovimiento:
          (json['tipo_movimiento'] ?? '').toString(),
      cantidad: json['cantidad'] ?? 0,
      depositoPagado:
          (json['deposito_pagado'] ?? '0').toString(),
      referencia:
          (json['referencia'] ?? '').toString(),
      fecha: (json['fecha'] ?? '').toString(),
    );
  }
}