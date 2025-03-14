class UserTagsModel {
  final int? id;
  final String stack;

  UserTagsModel({
    this.id,
    required this.stack,
  });

  factory UserTagsModel.fromJson(Map<String, dynamic> json) {
    return UserTagsModel(
      id: json['id'],
      stack: json['tags'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tags': stack,
    };
  }

  UserTagsModel copyWith({
    int? id,
    String? stack,
  }) {
    return UserTagsModel(
      id: id ?? this.id,
      stack: stack ?? this.stack,
    );
  }
}
