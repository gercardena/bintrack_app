class Product {

  final int id;
  final String name;
  final String price;
  final String sku;
  final String? description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.sku,
    this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {

    return Product(
      id: json['id'],
      name: json['nombre'] ?? '',
      price: json['precio'].toString(),
      sku: json['id'].toString(), // 👈 puedes cambiar después
      description: json['descripcion'],
    );
  }
}