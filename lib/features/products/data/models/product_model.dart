class Product {

  final int id;

  final String nombre;

  final String descripcion;

  final String precio;

  final bool activo;

  Product({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.activo,
  });


  factory Product.fromJson(
    Map<String, dynamic> json,
  ) {

    return Product(
      id: json["id"],

      nombre: json["nombre"] ?? "",

      descripcion:
          json["descripcion"] ?? "",

      precio:
          json["precio"].toString(),

      activo:
          json["activo"] ?? true,
    );

  }

}