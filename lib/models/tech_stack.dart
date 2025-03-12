class TechStack {
  final int id;
  final String tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  TechStack({
    required this.id,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TechStack.fromJson(Map<String, dynamic> json) {
    return TechStack(
      id: json['id'] as int,
      tags: json['tags'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
