import 'package:flutter/foundation.dart';

import '../../features/user/data/user_api.dart';

class UserController extends ChangeNotifier {
  static final UserController _instance = UserController._internal();

  factory UserController() => _instance;

  UserController._internal();

  Map<String, dynamic>? _user;
  int _loadVersion = 0;

  Map<String, dynamic>? get user => _user;

  bool get isLogged => _user != null;

  Future<void> loadUser({
    Future<Map<String, dynamic>> Function()? loader,
  }) async {
    final version = ++_loadVersion;
    try {
      final data = await (loader ?? UserApi.getProfile)();
      if (version != _loadVersion) return;
      _user = data;
      notifyListeners();
    } catch (e) {
      if (version != _loadVersion) return;
      if (kDebugMode) {
        debugPrint("Error loading user profile");
      }

      _user = null;
      notifyListeners();
    }
  }

  void clear() {
    _loadVersion++;
    _user = null;
    notifyListeners();
  }

  void markSubscriptionReadOnly(String state) {
    if (_user == null) return;
    _loadVersion++;
    final previous = _user!['suscripcion_acceso'];
    _user = {
      ..._user!,
      'suscripcion_estado': state,
      'suscripcion_activa': false,
      'suscripcion_acceso': {
        if (previous is Map<String, dynamic>) ...previous,
        'estado': state,
        'puede_operar': false,
        'solo_lectura': true,
      },
    };
    notifyListeners();
  }
}
