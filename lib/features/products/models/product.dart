class Product {

  final int id;
  final String name;
  final String sku;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {

    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
    );
  }

}