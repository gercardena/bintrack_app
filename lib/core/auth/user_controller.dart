import 'package:flutter/foundation.dart';

import '../../features/user/data/user_api.dart';

class UserController {
  static final UserController _instance =
      UserController._internal();

  factory UserController() => _instance;

  UserController._internal();

  Map<String, dynamic>? _user;

  Map<String, dynamic>? get user => _user;

  bool get isLogged => _user != null;

  Future<void> loadUser() async {
    try {
      final data = await UserApi.getProfile();
      _user = data;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error loading user profile");
      }

      _user = null;
    }
  }

  void clear() {
    _user = null;
  }
}