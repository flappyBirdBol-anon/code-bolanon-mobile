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
    this.isActive = true,
    this.studentsEnrolled = 0,
    this.rating = 0.0,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      isActive: json['is_active'] ?? true,
      studentsEnrolled: json['students_enrolled'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      price: int.tryParse(json['price']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price.toString(),
      'is_active': isActive ? '1' : '0',
    };
  }

  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnail,
    bool? isActive,
    int? studentsEnrolled,
    double? rating,
    int? price,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      isActive: isActive ?? this.isActive,
      studentsEnrolled: studentsEnrolled ?? this.studentsEnrolled,
      rating: rating ?? this.rating,
      price: price ?? this.price,
    );
  }
}
