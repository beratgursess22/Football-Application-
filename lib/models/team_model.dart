 class TeamModel {
  final int id;
  final String name;

  TeamModel({required this.id, required this.name});

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
