import 'dart:convert';

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
      'id': id,
      'tags': tags,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
