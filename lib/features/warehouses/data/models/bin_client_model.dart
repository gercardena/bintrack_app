class BinClient {

  final int id;
  final String nombre;
  final String telefono;

  BinClient({
    required this.id,
    required this.nombre,
    required this.telefono,
  });

  factory BinClient.fromJson(Map<String, dynamic> json) {

    return BinClient(
      id: json['id'],
      nombre: json['nombre'],
      telefono: json['telefono'] ?? '',
    );
  }

}