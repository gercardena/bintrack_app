class Inventory {

  final int binTypeId;
  final String binNombre;

  final int entradas;
  final int prestamos;
  final int devoluciones;
  final int bajas;

  final int disponible;

  Inventory({
    required this.binTypeId,
    required this.binNombre,
    required this.entradas,
    required this.prestamos,
    required this.devoluciones,
    required this.bajas,
    required this.disponible,
  });

  factory Inventory.fromJson(
    Map<String, dynamic> json,
  ) {

    return Inventory(
      binTypeId: json["bin_type_id"],
      binNombre: json["bin_nombre"],

      entradas: json["entradas"],
      prestamos: json["prestamos"],
      devoluciones: json["devoluciones"],
      bajas: json["bajas"],

      disponible: json["disponible"],
    );

  }

}