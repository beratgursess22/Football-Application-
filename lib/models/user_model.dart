
class UserModel {
  final int id;
  final String name;
  final String role;
  final String token;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'role': role, 'token': token};
  }
}
