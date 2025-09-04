import 'dart:async';

import 'package:flutter/material.dart';
import 'package:football_app/controllers/aut_controller.dart';
import 'package:football_app/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthController _authController = AuthController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = 'player';

  UserModel? _user;
  UserModel? get user => _user;
  String? _token;
  String? get token => _token;

  bool _isloading = false;
  bool get isloading => _isloading;

  void setRole(String role) {
    selectedRole = role;
    notifyListeners();
  }

  Future<bool> login() async {
    _isloading = true;
    notifyListeners();

    final name = nameController.text.trim();
    final password = passwordController.text.trim();

    final result = await _authController.login(
      name: name,
      password: password,
      role: selectedRole,
    );
    _isloading = false;
    if (result != null) {
      _user = result;
      _token = result.token;
      notifyListeners();
      return true;
    } else {
      debugPrint("Login failed. Invalid credentials or role.");
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerPlayer(String name, String password) async {
    _isloading = true;
    notifyListeners();
    final result = await _authController.register(
      name: name,
      password: password,
      role: 'player',
    );
    _isloading = false;
    notifyListeners();
    return result;
  }

  void logOut() async {
    _user = null;
    nameController.clear();
    passwordController.clear();
    selectedRole = 'player';
    notifyListeners();
  }

  void clears() {
    nameController.clear();
    passwordController.clear();
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
