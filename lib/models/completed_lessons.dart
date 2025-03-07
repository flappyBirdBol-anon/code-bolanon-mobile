class CompletedLessons {
  final int id;
  final bool isCompleted;
  final int lessonId;
  final int registrationId;

  CompletedLessons({
    required this.id,
    required this.isCompleted,
    required this.lessonId,
    required this.registrationId,
  });

  factory CompletedLessons.fromJson(Map<String, dynamic> json) {
    return CompletedLessons(
      id: json['id'],
      isCompleted: json['is_completed'],
      lessonId: json['lesson_id'],
      registrationId: json['registration_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_completed': isCompleted,
      'lesson_id': lessonId,
      'registration_id': registrationId,
    };
  }

  CompletedLessons copyWith({
    int? id,
    bool? isCompleted,
    int? lessonId,
    int? registrationId,
  }) {
    return CompletedLessons(
      id: id ?? this.id,
      isCompleted: isCompleted ?? this.isCompleted,
      lessonId: lessonId ?? this.lessonId,
      registrationId: registrationId ?? this.registrationId,
    );
  }
}
