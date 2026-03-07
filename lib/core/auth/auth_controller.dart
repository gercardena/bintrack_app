import 'dart:async';

class AuthController {
  static final AuthController _instance = AuthController._internal();
  factory AuthController() => _instance;
  AuthController._internal();

  final StreamController<void> _logoutController =
      StreamController<void>.broadcast();

  Stream<void> get onLogout => _logoutController.stream;

  // 🔑 TOKEN JWT
  String? _token;

  String? get token => _token;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  void forceLogout() {
    _token = null;
    _logoutController.add(null);
  }

  void dispose() {
    _logoutController.close();
  }
}
