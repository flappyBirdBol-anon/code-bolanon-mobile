class CompletedLessonModel {
  final int id;
  final int lessonId;
  final String registrationId;
  final bool isCompleted;
  final String? createdAt;
  final String? updatedAt;

  CompletedLessonModel({
    required this.id,
    required this.lessonId,
    required this.registrationId,
    this.isCompleted = true,
    this.createdAt,
    this.updatedAt,
  });

  factory CompletedLessonModel.fromJson(Map<String, dynamic> json) {
    // The presence of a record in the completed_lessons table means it's completed
    // We'll default to true, but still parse the field if present
    bool parsedIsCompleted = true;

    // Handle isCompleted field if present (but usually not needed)
    if (json.containsKey('is_completed')) {
      if (json['is_completed'] is bool) {
        parsedIsCompleted = json['is_completed'];
      } else if (json['is_completed'] is int) {
        parsedIsCompleted = json['is_completed'] == 1;
      } else if (json['is_completed'] is String) {
        parsedIsCompleted = json['is_completed'].toLowerCase() == 'true' ||
            json['is_completed'] == '1';
      }
    }

    return CompletedLessonModel(
      id: json['id'] ?? 0,
      lessonId: json['lesson_id'] ?? 0,
      registrationId: json['registration_id']?.toString() ?? '0',
      isCompleted: parsedIsCompleted,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'registration_id': registrationId,
      'is_completed': isCompleted,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  CompletedLessonModel copyWith({
    int? id,
    int? lessonId,
    String? registrationId, // Changed from int? userId
    bool? isCompleted,
    String? createdAt,
    String? updatedAt,
  }) {
    return CompletedLessonModel(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      registrationId: registrationId ?? this.registrationId,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
