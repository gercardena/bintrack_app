class BinType {

  final int id;
  final String nombre;
  final String material;
  final String valorDeposito;

  BinType({
    required this.id,
    required this.nombre,
    required this.material,
    required this.valorDeposito,
  });

  factory BinType.fromJson(Map<String, dynamic> json) {

    return BinType(
      id: json['id'],
      nombre: json['nombre'],
      material: json['material'],
      valorDeposito: json['valor_deposito'],
    );
  }

}