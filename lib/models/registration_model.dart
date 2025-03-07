import 'package:code_bolanon/models/completed_lessons.dart';

class RegistrationModel {
  final int id;
  final int? rating;
  final String? feedback;
  final bool isReported;
  final String? reportedReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int courseId;
  final int userId;
  final CompletedLessons? completedLessons;

  RegistrationModel({
    required this.id,
    this.rating,
    this.feedback,
    required this.isReported,
    this.reportedReason,
    required this.createdAt,
    required this.updatedAt,
    required this.courseId,
    required this.userId,
    this.completedLessons,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      id: json['id'],
      rating: json['rating'],
      feedback: json['feedback'],
      isReported: json['is_reported'],
      reportedReason: json['reported_reason'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      courseId: json['course_id'],
      userId: json['user_id'],
      completedLessons: json['completed_lessons'] != null
          ? CompletedLessons.fromJson(json['completed_lessons'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'feedback': feedback,
      'is_reported': isReported,
      'reported_reason': reportedReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'course_id': courseId,
      'user_id': userId,
      'completed_lessons': completedLessons?.toJson(),
    };
  }

  RegistrationModel copyWith({
    int? id,
    int? rating,
    String? feedback,
    bool? isReported,
    String? reportedReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? courseId,
    int? userId,
    CompletedLessons? completedLessons,
  }) {
    return RegistrationModel(
      id: id ?? this.id,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      isReported: isReported ?? this.isReported,
      reportedReason: reportedReason ?? this.reportedReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      courseId: courseId ?? this.courseId,
      userId: userId ?? this.userId,
      completedLessons: completedLessons ?? this.completedLessons,
    );
  }
}
