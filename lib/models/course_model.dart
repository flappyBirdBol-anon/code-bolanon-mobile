// lib/models/course.dart
import 'package:code_bolanon/models/registration_model.dart';

class CourseModel {
  final String id;
  final String title;
  final double price;
  final String description;
  final String thumbnail;
  final bool isActive;
  final int studentsEnrolled;
  final double rating;
  final int lessons;
  final int reviews;
  final RegistrationModel? registration;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CourseModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.thumbnail,
    this.isActive = true,
    this.studentsEnrolled = 0,
    this.rating = 0.0,
    this.lessons = 16,
    this.reviews = 4,
    this.registration,
    this.createdAt,
    this.updatedAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      isActive: json['is_active'] ?? true,
      studentsEnrolled: json['students_enrolled'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      price: double.tryParse(json['price'] ?? 0.00) ?? 0.00,
      registration: json['registration'] != null
          ? RegistrationModel.fromJson(json['registration'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price.toString(),
      'thumbnail': thumbnail,
      'is_active': isActive ? '1' : '0',
      'students_enrolled': studentsEnrolled.toString(),
      'registration': registration?.toJson(),
    };
  }

  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnail,
    bool? isActive,
    int? studentsEnrolled,
    double? rating,
    double? price,
    RegistrationModel? registration,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      isActive: isActive ?? this.isActive,
      studentsEnrolled: studentsEnrolled ?? this.studentsEnrolled,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      registration: registration ?? this.registration,
    );
  }
}
