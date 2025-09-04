class PlayerModel {
  final int id;
  final int? userId;
  final int? teamId;
  final String name;
  final String surname;
  final String birthDay;
  final String position;
  final String dominantFoot;
  final int height;
  final int weight;
  final String phone;
  final int jerseyNumber;
  final String? medicalNotes;
  final String? avatarUrl;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  PlayerModel({
    required this.id,
    this.userId,
    this.teamId,
    required this.name,
    required this.surname,
    required this.birthDay,
    required this.position,
    required this.dominantFoot,
    required this.height,
    required this.weight,
    required this.phone,
    required this.jerseyNumber,
    this.medicalNotes,
    this.avatarUrl,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'],
      userId: json['user_id'],
      teamId: json['team_id'],
      name: json['name'],
      surname: json['surname'],
      birthDay: json['birth_day'],
      position: json['position'],
      dominantFoot: json['dominant_foot'],
      height: json['height'] is String ? int.parse(json['height']) : json['height'],
      weight: json['weight'] is String ? int.parse(json['weight']) : json['weight'],
      phone: json['phone'],
      jerseyNumber: json['jersey_number'] is String ? int.parse(json['jersey_number']) : json['jersey_number'],
      medicalNotes: json['medical_notes'],
      avatarUrl: json['avatar_url'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'team_id': teamId,
      'name': name,
      'surname': surname,
      'birth_day': birthDay,
      'position': position,
      'dominant_foot': dominantFoot,
      'height': height,
      'weight': weight,
      'phone': phone,
      'jersey_number': jerseyNumber,
      'medical_notes': medicalNotes,
      'avatar_url': avatarUrl,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
