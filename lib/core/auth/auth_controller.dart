import 'dart:async';

class AuthController {
  static final AuthController _instance = AuthController._internal();
  factory AuthController() => _instance;
  AuthController._internal();

  final StreamController<void> _logoutController =
      StreamController<void>.broadcast();

  Stream<void> get onLogout => _logoutController.stream;

  void forceLogout() {
    _logoutController.add(null);
  }

  void dispose() {
    _logoutController.close();
  }
}
