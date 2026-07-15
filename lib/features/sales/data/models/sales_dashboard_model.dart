class SalesDashboard {
  final int ventasHoy;
  final double ingresosHoy;
  final int ventasMes;
  final double ingresosMes;
  final int ventasConfirmadas;
  final int ventasPagadas;
  final int ventasDraft;
  final int ventasCanceladas;

  const SalesDashboard({
    required this.ventasHoy,
    required this.ingresosHoy,
    required this.ventasMes,
    required this.ingresosMes,
    required this.ventasConfirmadas,
    required this.ventasPagadas,
    required this.ventasDraft,
    required this.ventasCanceladas,
  });

  factory SalesDashboard.fromJson(
    Map<String, dynamic> json,
  ) {
    return SalesDashboard(
      ventasHoy: _toInt(json["ventas_hoy"]),
      ingresosHoy: _toDouble(json["ingresos_hoy"]),
      ventasMes: _toInt(json["ventas_mes"]),
      ingresosMes: _toDouble(json["ingresos_mes"]),
      ventasConfirmadas:
          _toInt(json["ventas_confirmadas"]),
      ventasPagadas: _toInt(json["ventas_pagadas"]),
      ventasDraft: _toInt(json["ventas_draft"]),
      ventasCanceladas:
          _toInt(json["ventas_canceladas"]),
    );
  }

  static int _toInt(dynamic value) {
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    return double.tryParse(value.toString()) ?? 0;
  }
}