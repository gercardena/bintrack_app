class Cliente {

  final int id;
  final String nombre;
  final String rut;
  final String? email;
  final String? telefono;
  final String? direccion;
  final bool activo;

  Cliente({
    required this.id,
    required this.nombre,
    required this.rut,
    this.email,
    this.telefono,
    this.direccion,
    required this.activo,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {

    return Cliente(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      rut: json['rut'] ?? '',
      email: json['email'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      activo: json['activo'] ?? true,
    );

  }

}