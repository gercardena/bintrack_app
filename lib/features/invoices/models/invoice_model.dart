class InvoiceItem {
  final String productNombre;
  final String binNombre;
  final int cantidad;
  final int binsCantidad;
  final String tipoCobro;
  final double? kilosPesados;
  final double precioUnitario;
  final double subtotal;

  InvoiceItem({
    required this.productNombre,
    required this.binNombre,
    required this.cantidad,
    required this.binsCantidad,
    required this.tipoCobro,
    required this.kilosPesados,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory InvoiceItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return InvoiceItem(
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
  final List<InvoiceItem> items;

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
    required this.items,
  });

  factory Invoice.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawItems = json["items"];

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
      items: rawItems is List
          ? rawItems
              .map(
                (item) => InvoiceItem.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList()
          : const [],
    );
  }
}