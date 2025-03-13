import 'dart:convert';

import 'package:code_bolanon/models/completed_lessons.dart';

class RegistrationModel {
  final String id;
  final String courseId; // Changed to String to match the expected type
  final String userId;
  final int? rating;
  final String? feedback;
  final bool isReported;
  final String? reportedReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CompletedLessons? completedLessons;

  RegistrationModel({
    required this.id,
    required this.courseId,
    required this.userId,
    this.rating,
    this.feedback,
    required this.isReported,
    this.reportedReason,
    required this.createdAt,
    required this.updatedAt,
    this.completedLessons,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      id: json['id'].toString(),
      courseId: json['course_id'].toString(), // Convert to String
      userId: json['user_id'].toString(),
      rating: json['rating'],
      feedback: json['feedback'],
      isReported: json['is_reported'] is int
          ? json['is_reported'] == 1
          : json['is_reported'] as bool,
      reportedReason: json['reported_reason'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      completedLessons: json['completed_lessons'] != null
          ? CompletedLessons.fromJson(json['completed_lessons'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'user_id': userId,
      'rating': rating,
      'feedback': feedback,
      'is_reported': isReported,
      'reported_reason': reportedReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'completed_lessons': completedLessons?.toJson(),
    };
  }

  RegistrationModel copyWith({
    String? id,
    String? courseId,
    String? userId,
    int? rating,
    String? feedback,
    bool? isReported,
    String? reportedReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    CompletedLessons? completedLessons,
  }) {
    return RegistrationModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      isReported: isReported ?? this.isReported,
      reportedReason: reportedReason ?? this.reportedReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedLessons: completedLessons ?? this.completedLessons,
    );
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
