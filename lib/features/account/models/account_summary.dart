String clp(int amount) =>
    '\$${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';

class SecondaryUser {
  final int id;
  final String username, email, firstName, lastName, phone;
  final bool active;

  SecondaryUser.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      username = json['username'] as String,
      email = (json['email'] ?? '') as String,
      firstName = (json['first_name'] ?? '') as String,
      lastName = (json['last_name'] ?? '') as String,
      phone = (json['telefono'] ?? '') as String,
      active = json['activo'] == true;
}

class MonthlyPlan {
  final int secondaryCount, price;
  MonthlyPlan.fromJson(Map<String, dynamic> json)
    : secondaryCount = json['secundarios'] as int,
      price = json['precio_final_clp'] as int;
}

class AccountSummary {
  final String owner;
  final int activeCount, maxCount, additionPrice;
  final bool canAdd, needsReview, subscriptionActive;
  final String? endDate;
  final MonthlyPlan? selectedPlan;
  final List<MonthlyPlan> plans;
  final List<SecondaryUser> users;
  final Map<String, dynamic>? subscriptionAccess;

  AccountSummary.fromJson(Map<String, dynamic> json)
    : subscriptionAccess = json['suscripcion_acceso'] as Map<String, dynamic>?,
      owner = json['titular']['username'] as String,
      activeCount = json['secundarios_activos'] as int,
      maxCount = json['max_secundarios'] as int,
      additionPrice = json['adicional_alta_clp'] as int,
      canAdd = json['puede_agregar'] == true,
      needsReview = json['requiere_revision'] == true,
      subscriptionActive = json['suscripcion_vigente'] == true,
      endDate = json['fecha_fin'] as String?,
      selectedPlan = json['plan_segun_usuarios'] == null
          ? null
          : MonthlyPlan.fromJson(json['plan_segun_usuarios']),
      plans = (json['planes'] as List)
          .map((item) => MonthlyPlan.fromJson(item))
          .toList(),
      users = (json['usuarios'] as List)
          .map((item) => SecondaryUser.fromJson(item))
          .toList();
}
