
class CalenderModel {
  final int id;
  final int coachId;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final String? location;
  final String? createdAt;
  final String? updatedAt;

  CalenderModel({
    required this.id,
    required this.coachId,
    required this.title,
    this.description,
    required this.startDate,
    this.endDate,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory CalenderModel.fromJson(Map<String, dynamic> json) {
    return CalenderModel(
      id: json['id'],
      coachId: json['coach_id'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['start_time']),
      endDate: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      location: json['location'],
      createdAt: json['createdat'],
      updatedAt: json['updatedat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coach_id': coachId,
      'title': title,
      'description': description,
      'start_time': startDate.toIso8601String(),
      'end_time': endDate?.toIso8601String(),
      'location': location,
      'createdat': createdAt,
      'updatedat': updatedAt,
    };
  }
}
