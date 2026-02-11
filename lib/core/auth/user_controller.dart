import '../../features/user/data/user_api.dart';

class UserController {

  // Singleton
  static final UserController _instance = UserController._internal();
  factory UserController() => _instance;
  UserController._internal();

  Map<String, dynamic>? _user;

  Map<String, dynamic>? get user => _user;

  bool get isLogged => _user != null;

  // ------------------------------
  // Cargar usuario desde backend
  // ------------------------------
  Future<void> loadUser() async {
    try {
      final data = await UserApi.getProfile();
      _user = data;
      print("USER LOADED: $data");
    } catch (e) {
      print("ERROR loading user: $e");
      _user = null;
    }
  }

  // ------------------------------
  // Limpiar usuario
  // ------------------------------
  void clear() {
    _user = null;
  }
}
