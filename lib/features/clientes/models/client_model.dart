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
      id: json['id'] as int,
      nombre: (json['nombre'] ?? '').toString(),
      rut: (json['rut'] ?? '').toString(),
      email: json['email']?.toString(),
      telefono: json['telefono']?.toString(),
      direccion: json['direccion']?.toString(),
      activo: json['activo'] ?? true,
    );
  }

  // 🔥 NECESARIO PARA POST/PUT
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nombre": nombre,
      "rut": rut,
      "email": email,
      "telefono": telefono,
      "direccion": direccion,
      "activo": activo,
    };
  }
}