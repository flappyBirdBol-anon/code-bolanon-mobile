import 'dart:convert';

class StacksModel {
  final String id;
  final String stack;

  StacksModel({
    required this.id,
    required this.stack,
  });

  factory StacksModel.fromJson(Map<String, dynamic> json) {
    return StacksModel(
      id: json['id'].toString(),
      stack: json['tags'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tags': stack,
    };
  }

  StacksModel copyWith({
    String? id,
    String? stack,
  }) {
    return StacksModel(
      id: id ?? this.id,
      stack: stack ?? this.stack,
    );
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class TechStackModel {
  final int id;
  final String tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TechStackModel({
    required this.id,
    required this.tags,
    this.createdAt,
    this.updatedAt,
  });

  factory TechStackModel.fromJson(Map<String, dynamic> json) {
    return TechStackModel(
      id: json['id'],
      tags: json['tags'],
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
      'id': id.toInt(),
      'tags': tags,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
