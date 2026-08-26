class BinType {
  final int id;
  final String nombre;
  final String tipo;
  final String material;
  final String valorDeposito;

  BinType({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.material,
    required this.valorDeposito,
  });

  factory BinType.fromJson(Map<String, dynamic> json) {
    return BinType(
      id: json['id'] ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? 'BIN',
      material: json['material']?.toString() ?? '',
      valorDeposito:
          json['valor_deposito']?.toString() ?? '0',
    );
  }

  String get tipoNombre {
    switch (tipo) {
      case 'BIN':
        return 'Bin';
      case 'PALLET':
        return 'Pallet';
      case 'CAJA':
        return 'Caja';
      case 'GAMELA':
        return 'Gamela';
      case 'BANDEJA':
        return 'Bandeja';
      case 'SACO':
        return 'Saco';
      case 'BOLSA':
        return 'Bolsa';
      case 'OTRO':
        return 'Otro';
      default:
        return tipo;
    }
  }
}