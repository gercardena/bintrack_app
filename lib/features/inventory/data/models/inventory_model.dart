class Inventory {
  final int binTypeId;
  final String binNombre;

  final int entradas;
  final int prestamos;
  final int devoluciones;
  final int bajas;

  final int enClientes;
  final int llenos;
  final int disponible;

  Inventory({
    required this.binTypeId,
    required this.binNombre,
    required this.entradas,
    required this.prestamos,
    required this.devoluciones,
    required this.bajas,
    required this.enClientes,
    required this.llenos,
    required this.disponible,
  });

  factory Inventory.fromJson(
    Map<String, dynamic> json,
  ) {
    int parseInt(dynamic value) {
      return int.tryParse(value.toString()) ?? 0;
    }

    return Inventory(
      binTypeId: parseInt(json["bin_type_id"]),
      binNombre:
          (json["bin_nombre"] ?? "").toString(),
      entradas: parseInt(json["entradas"]),
      prestamos: parseInt(json["prestamos"]),
      devoluciones: parseInt(
        json["devoluciones"],
      ),
      bajas: parseInt(json["bajas"]),
      enClientes: parseInt(json["en_clientes"]),
      llenos: parseInt(json["llenos"]),
      disponible: parseInt(json["disponible"]),
    );
  }
}