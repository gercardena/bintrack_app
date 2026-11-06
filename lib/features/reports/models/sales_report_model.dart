class SalesReportItem {
  final String productNombre;
  final String binNombre;
  final int cantidad;
  final int binsCantidad;
  final String tipoCobro;
  final double? kilosPesados;
  final double precioUnitario;
  final double subtotal;

  SalesReportItem({
    required this.productNombre,
    required this.binNombre,
    required this.cantidad,
    required this.binsCantidad,
    required this.tipoCobro,
    required this.kilosPesados,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory SalesReportItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return SalesReportItem(
      productNombre:
          (json["product_nombre"] ?? "").toString(),
      binNombre:
          (json["bin_nombre"] ?? "").toString(),
      cantidad: int.tryParse(
            json["cantidad"].toString(),
          ) ??
          0,
      binsCantidad: int.tryParse(
            json["bins_cantidad"].toString(),
          ) ??
          0,
      tipoCobro:
          (json["tipo_cobro"] ?? "envase").toString(),
      kilosPesados: json["kilos_pesados"] == null
          ? null
          : double.tryParse(
              json["kilos_pesados"].toString(),
            ),
      precioUnitario: double.tryParse(
            json["precio_unitario"].toString(),
          ) ??
          0,
      subtotal: double.tryParse(
            json["subtotal"].toString(),
          ) ??
          0,
    );
  }

  bool get esPorKilo => tipoCobro == "kilo";
}


class SalesReportSale {
  final int id;
  final String numero;
  final String fecha;
  final int clienteId;
  final String clienteNombre;
  final String estado;
  final String tipoReporte;
  final double total;
  final double totalPagado;
  final double saldoPendiente;
  final List<SalesReportItem> items;

  SalesReportSale({
    required this.id,
    required this.numero,
    required this.fecha,
    required this.clienteId,
    required this.clienteNombre,
    required this.estado,
    required this.tipoReporte,
    required this.total,
    required this.totalPagado,
    required this.saldoPendiente,
    required this.items,
  });

  factory SalesReportSale.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawItems = json["items"];

    return SalesReportSale(
      id: int.tryParse(
            json["id"].toString(),
          ) ??
          0,
      numero:
          (json["numero"] ?? "").toString(),
      fecha:
          (json["fecha"] ?? "").toString(),
      clienteId: int.tryParse(
            json["cliente_id"].toString(),
          ) ??
          0,
      clienteNombre:
          (json["cliente_nombre"] ?? "").toString(),
      estado:
          (json["estado"] ?? "").toString(),
      tipoReporte:
          (json["tipo_reporte"] ?? "").toString(),
      total: double.tryParse(
            json["total"].toString(),
          ) ??
          0,
      totalPagado: double.tryParse(
            json["total_pagado"].toString(),
          ) ??
          0,
      saldoPendiente: double.tryParse(
            json["saldo_pendiente"].toString(),
          ) ??
          0,
      items: rawItems is List
          ? rawItems
              .map(
                (item) => SalesReportItem.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList()
          : const [],
    );
  }

  bool get esPagada => tipoReporte == "pagada";
  bool get esAbonada => tipoReporte == "abonada";
}


class SalesReport {
  final String periodo;
  final String desde;
  final String hasta;

  final double totalVendido;
  final double totalAbonado;
  final double totalPendiente;
  final double totalContado;
  final double totalCredito;

  final int cantidadVentas;
  final int cantidadVentasContado;
  final int cantidadVentasCredito;
  final int cantidadVentasPagadas;
  final int cantidadVentasPendientes;

  final int cantidadClientesPagados;
  final int cantidadClientesCredito;

  final List<SalesReportSale> ventas;

  SalesReport({
    required this.periodo,
    required this.desde,
    required this.hasta,
    required this.totalVendido,
    required this.totalAbonado,
    required this.totalPendiente,
    required this.totalContado,
    required this.totalCredito,
    required this.cantidadVentas,
    required this.cantidadVentasContado,
    required this.cantidadVentasCredito,
    required this.cantidadVentasPagadas,
    required this.cantidadVentasPendientes,
    required this.cantidadClientesPagados,
    required this.cantidadClientesCredito,
    required this.ventas,
  });

  factory SalesReport.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawVentas = json["ventas"];

    return SalesReport(
      periodo:
          (json["periodo"] ?? "").toString(),
      desde:
          (json["desde"] ?? "").toString(),
      hasta:
          (json["hasta"] ?? "").toString(),
      totalVendido: double.tryParse(
            json["total_vendido"].toString(),
          ) ??
          0,
      totalAbonado: double.tryParse(
            json["total_abonado"].toString(),
          ) ??
          double.tryParse(json["total_contado"].toString()) ??
          0,
      totalPendiente: double.tryParse(
            json["total_pendiente"].toString(),
          ) ??
          double.tryParse(json["total_credito"].toString()) ??
          0,
      totalContado: double.tryParse(
            json["total_contado"].toString(),
          ) ??
          0,
      totalCredito: double.tryParse(
            json["total_credito"].toString(),
          ) ??
          0,
      cantidadVentas: int.tryParse(
            json["cantidad_ventas"].toString(),
          ) ??
          0,
      cantidadVentasContado: int.tryParse(
            json["cantidad_ventas_contado"].toString(),
          ) ??
          0,
      cantidadVentasCredito: int.tryParse(
            json["cantidad_ventas_credito"].toString(),
          ) ??
          0,
      cantidadVentasPagadas: int.tryParse(
            json["cantidad_ventas_pagadas"].toString(),
          ) ??
          int.tryParse(json["cantidad_ventas_contado"].toString()) ??
          0,
      cantidadVentasPendientes: int.tryParse(
            json["cantidad_ventas_pendientes"].toString(),
          ) ??
          int.tryParse(json["cantidad_ventas_credito"].toString()) ??
          0,
      cantidadClientesPagados: int.tryParse(
            json["cantidad_clientes_pagados"].toString(),
          ) ??
          0,
      cantidadClientesCredito: int.tryParse(
            json["cantidad_clientes_credito"].toString(),
          ) ??
          0,
      ventas: rawVentas is List
          ? rawVentas
              .map(
                (venta) => SalesReportSale.fromJson(
                  venta as Map<String, dynamic>,
                ),
              )
              .toList()
          : const [],
    );
  }
}
