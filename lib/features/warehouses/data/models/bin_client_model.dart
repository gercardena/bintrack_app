class BinClient {

  final int id;
  final String nombre;
  final String rut;
  final String email;
  final String telefono;
  final String direccion;
  final bool activo;

  BinClient({
    required this.id,
    required this.nombre,
    required this.rut,
    required this.email,
    required this.telefono,
    required this.direccion,
    required this.activo,
  });

  factory BinClient.fromJson(Map<String, dynamic> json) {

    return BinClient(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      rut: json['rut'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      direccion: json['direccion'] ?? '',
      activo: json['activo'] ?? true,
    );
  }
}