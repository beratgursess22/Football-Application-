import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  final String baseUrl = 'http://172.20.10.5:3000/api';

  Future<UserModel?> login({
    required String name,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'password': password, 'role': role}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserModel.fromJson(data);
      } else {
        print('Login failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<bool> register({
    required String name,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'password': password,
          'role': 'player',
        }),
      );
      if (response.statusCode == 201) {
        return true;
      } else {
        print("Register Failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Register error: $e");
      return false;
    }
  }
}
