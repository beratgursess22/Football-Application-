import 'package:football_app/models/user_model.dart';
import 'package:football_app/service/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future<UserModel?> login({
    required String name,
    required String password,
    required String role,
  }) {
    return _authService.login(name: name, password: password, role: role);
  }

  Future<bool> register({
    required String name,
    required String password,
    required String role,
  }) {
    return _authService.register(name: name, password: password);
  }
}

