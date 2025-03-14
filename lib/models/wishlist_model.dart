class WishlistModel {
  final String id;
  final String courseId;
  final int userId;
  final DateTime? createdAt;

  WishlistModel({
    required this.id,
    required this.courseId,
    required this.userId,
    this.createdAt,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      id: json['id'].toString(),
      courseId: json['course_id'].toString(),
      userId: json['user_id'] is String
          ? int.parse(json['user_id'])
          : json['user_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  WishlistModel copyWith({
    String? id,
    String? courseId,
    int? userId,
    DateTime? createdAt,
  }) {
    return WishlistModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
