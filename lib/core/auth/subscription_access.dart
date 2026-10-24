class SubscriptionAccess {
  final String state;
  final bool canOperate;
  final String? endDate, graceEnd;

  const SubscriptionAccess({
    required this.state,
    required this.canOperate,
    this.endDate,
    this.graceEnd,
  });

  factory SubscriptionAccess.fromProfile(Map<String, dynamic>? profile) {
    final data = profile?['suscripcion_acceso'];
    if (data is Map<String, dynamic>) {
      return SubscriptionAccess(
        state: data['estado']?.toString() ?? 'desconocida',
        canOperate: data['puede_operar'] == true,
        endDate: data['fecha_fin']?.toString(),
        graceEnd: data['gracia_hasta']?.toString(),
      );
    }
    return SubscriptionAccess(
      state: profile?['suscripcion_estado']?.toString() ?? 'desconocida',
      canOperate: profile?['suscripcion_activa'] == true,
      endDate: profile?['suscripcion_fecha_fin']?.toString(),
    );
  }

  String get title => switch (state) {
    'activa' => 'Suscripción activa',
    'en_gracia' => 'Suscripción en período de gracia',
    'desconocida' => 'No se pudo verificar la suscripción',
    _ => 'Modo solo lectura',
  };

  String description({required bool isOwner}) {
    final next = isOwner
        ? 'Puedes gestionar tu cuenta en Usuarios y suscripción.'
        : 'Contacta al principal para regularizar la suscripción.';
    if (state == 'activa') {
      return 'Puedes registrar y consultar operaciones.';
    }
    if (state == 'en_gracia') {
      return 'Tienes acceso completo durante los tres días de gracia. Al terminar, la cuenta pasará a solo lectura. $next';
    }
    if (state == 'desconocida') {
      return 'Actualiza el estado o revisa la conexión antes de operar.';
    }
    return 'Puedes consultar los datos existentes, pero no registrar, editar ni eliminar operaciones. $next';
  }
}
