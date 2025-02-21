// lib/models/course.dart
class Course {
  final String id;
  final String title;
  final int price;
  final String description;
  final String thumbnail;
  final bool isActive;
  final int studentsEnrolled;
  final double rating;

  Course({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.thumbnail,
    required this.isActive,
    required this.studentsEnrolled,
    required this.rating,
  });
}
