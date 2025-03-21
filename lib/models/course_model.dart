// lib/models/course.dart
import 'dart:convert';

import 'package:code_bolanon/models/registration_model.dart';
import 'package:code_bolanon/models/wishlist_model.dart';

class CourseModel {
  final String id;
  final String title;
  final double price;
  final String description;
  final String thumbnail;
  final String? imageUrl;
  final bool isActive;
  final int studentsEnrolled;
  final double rating;
  final int lessons;
  final int reviews;
  final RegistrationModel? registration;
  final WishlistModel? wishlist;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? lessonCount;
  final String? author;
  final String? author_image;
  // New fields
  final List<String> learningExpectations;
  final List<String> requirements;
  final List<String> stacks;
  final String level; // beginner, intermediate, advanced
  final String duration; // e.g. "2 months"
  final List<int> techStackIds; // New field for tech stack IDs
  final List<RegistrationModel> registrations; // Add registrations list

  CourseModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.thumbnail,
    this.imageUrl,
    this.isActive = true,
    this.studentsEnrolled = 0,
    this.rating = 0.0,
    this.lessons = 16,
    this.reviews = 4,
    this.registration,
    this.wishlist,
    this.createdAt,
    this.updatedAt,
    this.lessonCount,
    this.author,
    this.author_image,
    this.learningExpectations = const [],
    this.requirements = const [],
    this.stacks = const [],
    this.level = 'Beginner',
    this.duration = 'N/A',
    this.techStackIds = const [], // Default empty list
    this.registrations = const [], // Default empty list
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    // Parse registrations from API response
    List<RegistrationModel> registrationsData = [];
    if (json['registrations'] != null) {
      registrationsData = (json['registrations'] as List).map((regJson) {
        // Create a modified map that includes user info directly
        final Map<String, dynamic> modifiedReg = {...regJson};
        if (regJson['user'] != null) {
          modifiedReg['user_first_name'] = regJson['user']['first_name'];
          modifiedReg['user_last_name'] = regJson['user']['last_name'];
          modifiedReg['user_profile_picture'] =
              regJson['user']['profile_picture'];
        }
        return RegistrationModel.fromJson(modifiedReg);
      }).toList();
    }

    return CourseModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnail:
          json['thumbnail'] ?? json['image_url'] ?? '', // Try both fields
      imageUrl: json['image_url'] ?? json['thumbnail'] ?? '', // Try both fields
      isActive: json['is_active'] ?? true,
      studentsEnrolled: json['learners_enrolled'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      price: double.tryParse("${json['price'] ?? 0.00}") ?? 0.00,
      lessons: json['lessons'] ?? 16,
      reviews: json['reviews'] ?? 4,
      registration: json['registration'] != null
          ? RegistrationModel.fromJson(json['registration'])
          : null,
      wishlist: json['wishlist'] != null
          ? WishlistModel.fromJson(json['wishlist'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      lessonCount: json['lessons_count'],
      author: json['author'],
      author_image: json['author_image'],
      // New fields
      learningExpectations: json['learning_expectations'] != null
          ? List<String>.from(json['learning_expectations'])
          : [],
      requirements: json['requirements'] != null
          ? List<String>.from(json['requirements'])
          : [],
      stacks: json['stacks'] != null ? List<String>.from(json['stacks']) : [],
      level: json['level'] ?? 'Beginner',
      duration: json['duration'] ?? '4 weeks',
      techStackIds: json['selected_stacks'] != null
          ? List<int>.from(json['selected_stacks'])
          : [],
      registrations: registrationsData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price.toString(),
      'thumbnail': thumbnail,
      'image_url': imageUrl,
      'is_active': isActive ? '1' : '0',
      'students_enrolled': studentsEnrolled.toString(),
      'registration': registration?.toJson(),
      'wishlist': wishlist?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      // New fields
      'learning_expectations': learningExpectations,
      'requirements': requirements,
      // 'stacks': stacks,
      'level': level,
      'duration': duration,
      'tech_stack_ids': techStackIds,
    };
  }

  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnail,
    String? imageUrl,
    bool? isActive,
    int? studentsEnrolled,
    double? rating,
    double? price,
    RegistrationModel? registration,
    WishlistModel? wishlist,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? lessonCount,
    String? author,
    List<String>? learningExpectations,
    List<String>? requirements,
    List<String>? stacks,
    String? level,
    String? duration,
    List<int>? techStackIds,
    List<RegistrationModel>? registrations,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      studentsEnrolled: studentsEnrolled ?? this.studentsEnrolled,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      registration: registration ?? this.registration,
      wishlist: wishlist ?? this.wishlist,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lessonCount: lessonCount ?? this.lessonCount,
      author: author ?? this.author,
      learningExpectations: learningExpectations ?? this.learningExpectations,
      requirements: requirements ?? this.requirements,
      stacks: stacks ?? this.stacks,
      level: level ?? this.level,
      duration: duration ?? this.duration,
      techStackIds: techStackIds ?? this.techStackIds,
      registrations: registrations ?? this.registrations,
    );
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
