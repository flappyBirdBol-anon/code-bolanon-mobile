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

  // User information fields
  final String? userFirstName;
  final String? userLastName;
  final String? userProfilePicture;

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
    this.userFirstName,
    this.userLastName,
    this.userProfilePicture,
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
          : json['is_reported'] == true,
      reportedReason: json['report_reason'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      completedLessons: json['completed_lessons'] != null
          ? CompletedLessons.fromJson(json['completed_lessons'])
          : null,
      // Parse user information
      userFirstName: json['user_first_name'],
      userLastName: json['user_last_name'],
      userProfilePicture: json['user_profile_picture'],
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
      'user_first_name': userFirstName,
      'user_last_name': userLastName,
      'user_profile_picture': userProfilePicture,
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
    String? userFirstName,
    String? userLastName,
    String? userProfilePicture,
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
      userFirstName: userFirstName ?? this.userFirstName,
      userLastName: userLastName ?? this.userLastName,
      userProfilePicture: userProfilePicture ?? this.userProfilePicture,
    );
  }

  // Helper property to get full name
  String get userFullName {
    if (userFirstName != null && userLastName != null) {
      return '$userFirstName $userLastName';
    } else if (userFirstName != null) {
      return userFirstName!;
    } else if (userLastName != null) {
      return userLastName!;
    } else {
      return 'Anonymous User';
    }
  }

  // Helper method to check if this review is worth displaying
  bool get hasReview =>
      rating != null && feedback != null && feedback!.isNotEmpty;

  // Helper method to check if this report is worth displaying
  bool get hasReport =>
      isReported && reportedReason != null && reportedReason!.isNotEmpty;

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
