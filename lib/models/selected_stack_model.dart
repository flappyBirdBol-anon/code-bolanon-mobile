import 'dart:convert';

class StackInfo {
  final int id;
  final String tags;
  final String? createdAt;
  final String? updatedAt;

  StackInfo({
    required this.id,
    required this.tags,
    this.createdAt,
    this.updatedAt,
  });

  factory StackInfo.fromJson(Map<String, dynamic> json) {
    return StackInfo(
      id: json['id'] ?? 0,
      tags: json['tags'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tags': tags,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class SelectedStackModel {
  final int id;
  final int stackId;
  final int? userId;
  final int? courseId;
  final String? createdAt;
  final String? updatedAt;
  final StackInfo? stack;

  SelectedStackModel({
    required this.id,
    required this.stackId,
    this.userId,
    this.courseId,
    this.createdAt,
    this.updatedAt,
    this.stack,
  });

  factory SelectedStackModel.fromJson(Map<String, dynamic> json) {
    // If JSON has the structure from your example (with direct 'tags' property)
    if (json.containsKey('tags')) {
      return SelectedStackModel(
        id: json['id'] ?? 0,
        stackId:
            json['id'] ?? 0, // Use the same id if stack_id is not available
        userId: json['pivot']?['user_id'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        // Create a StackInfo from the current object
        stack: StackInfo(
          id: json['id'] ?? 0,
          tags: json['tags'] ?? '',
          createdAt: json['created_at'],
          updatedAt: json['updated_at'],
        ),
      );
    }
    // Use the original implementation for the expected format
    else {
      return SelectedStackModel(
        id: json['id'] ?? 0,
        stackId: json['stack_id'] ?? 0,
        userId: json['user_id'],
        courseId: json['course_id'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        stack: json['stack'] != null ? StackInfo.fromJson(json['stack']) : null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stack_id': stackId,
      'user_id': userId,
      'course_id': courseId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'stack': stack?.toJson(),
    };
  }

  SelectedStackModel copyWith({
    int? id,
    int? stackId,
    int? userId,
    int? courseId,
    String? createdAt,
    String? updatedAt,
    StackInfo? stack,
  }) {
    return SelectedStackModel(
      id: id ?? this.id,
      stackId: stackId ?? this.stackId,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stack: stack ?? this.stack,
    );
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
