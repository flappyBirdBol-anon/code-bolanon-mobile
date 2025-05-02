import 'dart:convert';

import 'package:code_bolanon/models/completed_lessons.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/models/lessons_model.dart';

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

  // New fields to handle nested data
  final CourseModel? course;
  final ProgressInfo? progress;
  final List<Lesson>? lessons;
  final List<CompletedLesson>? completedLessonsList;

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
    this.course,
    this.progress,
    this.lessons,
    this.completedLessonsList,
    this.userFirstName,
    this.userLastName,
    this.userProfilePicture,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    try {
      print(
          'RegistrationModel.fromJson called with keys: ${json.keys.join(', ')}');

      // Handle id field
      String id;
      try {
        id = json['id'].toString();
      } catch (e) {
        print('Error parsing id: $e');
        throw Exception('Invalid or missing id');
      }

      // Handle course_id field
      String courseId;
      try {
        courseId = json['course_id'].toString();
      } catch (e) {
        print('Error parsing course_id: $e');
        throw Exception('Invalid or missing course_id');
      }

      // Handle user_id field
      String userId;
      try {
        userId = json['user_id'].toString();
      } catch (e) {
        print('Error parsing user_id: $e');
        throw Exception('Invalid or missing user_id');
      }

      // Handle course data if present
      CourseModel? courseData;
      if (json['course'] != null) {
        try {
          courseData = CourseModel.fromJson(json['course']);
          print(
              'Successfully parsed course data for course ID: ${courseData.id}');
        } catch (e) {
          print('Error parsing course data: $e');
          // Don't throw, just leave courseData as null
        }
      }

      // Handle progress data if present
      ProgressInfo? progressData;
      if (json['progress'] != null) {
        try {
          progressData = ProgressInfo.fromJson(json['progress']);
          print(
              'Successfully parsed progress data: ${progressData.percentage}%');
        } catch (e) {
          print('Error parsing progress data: $e');
          // Don't throw, just leave progressData as null
        }
      }

      // Handle lessons list if present
      List<Lesson>? lessonsList;
      if (json['lessons'] != null) {
        try {
          lessonsList = (json['lessons'] as List)
              .map((lessonJson) => Lesson.fromJson(lessonJson))
              .toList();
          print('Successfully parsed ${lessonsList.length} lessons');
        } catch (e) {
          print('Error parsing lessons list: $e');
          // Don't throw, just leave lessonsList as null
        }
      }

      // Handle completed lessons list if present
      List<CompletedLesson>? completedList;
      if (json['completed_lessons'] != null) {
        try {
          completedList = (json['completed_lessons'] as List)
              .map((lessonJson) => CompletedLesson.fromJson(lessonJson))
              .toList();
          print(
              'Successfully parsed ${completedList.length} completed lessons');
        } catch (e) {
          print('Error parsing completed lessons list: $e');
          // Don't throw, just leave completedList as null
        }
      }

      // Create a CompletedLessons object for backward compatibility
      CompletedLessons? legacyCompletedLessons;
      if (progressData != null &&
          completedList != null &&
          completedList.isNotEmpty) {
        try {
          // Use the first completed lesson for the legacy object
          legacyCompletedLessons = CompletedLessons(
            id: int.parse(completedList[0].id),
            isCompleted: progressData.percentage == 100,
            lessonId: progressData.completedCount,
            registrationId: int.parse(id),
          );
          print('Created legacy completedLessons object');
        } catch (e) {
          print('Error creating legacy completedLessons: $e');
          // Don't throw, just leave legacyCompletedLessons as null
        }
      }

      // Handle dates
      DateTime createdAt;
      try {
        createdAt = json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now();
      } catch (e) {
        print('Error parsing created_at: $e');
        createdAt = DateTime.now();
      }

      DateTime updatedAt;
      try {
        updatedAt = json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : DateTime.now();
      } catch (e) {
        print('Error parsing updated_at: $e');
        updatedAt = DateTime.now();
      }

      final registration = RegistrationModel(
        id: id,
        courseId: courseId,
        userId: userId,
        rating: json['rating'],
        feedback: json['feedback'],
        isReported: json['is_reported'] is int
            ? json['is_reported'] == 1
            : json['is_reported'] == true,
        reportedReason: json['report_reason'],
        createdAt: createdAt,
        updatedAt: updatedAt,
        // Use the compatibility object we created, or try to parse from JSON if it exists
        completedLessons: legacyCompletedLessons ??
            (json['completed_lessons'] != null &&
                    json['completed_lessons'] is Map<String, dynamic>
                ? CompletedLessons.fromJson(json['completed_lessons'])
                : null),
        course: courseData,
        progress: progressData,
        lessons: lessonsList,
        completedLessonsList: completedList,
        // Parse user information
        userFirstName: json['user_first_name'],
        userLastName: json['user_last_name'],
        userProfilePicture: json['user_profile_picture'],
      );

      print('Successfully created RegistrationModel for ID: $id');
      return registration;
    } catch (e, stackTrace) {
      print('Error parsing RegistrationModel: $e');
      print('StackTrace: $stackTrace');
      print('Problematic JSON: $json');
      rethrow;
    }
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
      'course': course?.toJson(),
      'progress': progress?.toJson(),
      'lessons': lessons?.map((lesson) => lesson.toJson()).toList(),
      'completed_lessons_list':
          completedLessonsList?.map((item) => item.toJson()).toList(),
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
    CourseModel? course,
    ProgressInfo? progress,
    List<Lesson>? lessons,
    List<CompletedLesson>? completedLessonsList,
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
      course: course ?? this.course,
      progress: progress ?? this.progress,
      lessons: lessons ?? this.lessons,
      completedLessonsList: completedLessonsList ?? this.completedLessonsList,
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

// New class for progress information
class ProgressInfo {
  final int totalLessons;
  final int completedCount;
  final int percentage;

  ProgressInfo({
    required this.totalLessons,
    required this.completedCount,
    required this.percentage,
  });

  factory ProgressInfo.fromJson(Map<String, dynamic> json) {
    return ProgressInfo(
      totalLessons: json['total_lessons'] ?? 0,
      completedCount: json['completed_count'] ?? 0,
      percentage: json['percentage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_lessons': totalLessons,
      'completed_count': completedCount,
      'percentage': percentage,
    };
  }
}

// New class for completed lesson entries
class CompletedLesson {
  final String id;
  final String lessonId;
  final String registrationId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Lesson? lesson;

  CompletedLesson({
    required this.id,
    required this.lessonId,
    required this.registrationId,
    required this.createdAt,
    required this.updatedAt,
    this.lesson,
  });

  factory CompletedLesson.fromJson(Map<String, dynamic> json) {
    return CompletedLesson(
      id: json['id'].toString(),
      lessonId: json['lesson_id'].toString(),
      registrationId: json['registration_id'].toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      lesson: json['lesson'] != null ? Lesson.fromJson(json['lesson']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'registration_id': registrationId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'lesson': lesson?.toJson(),
    };
  }
}
