import 'package:code_bolanon/models/selected_stack_model.dart';

class UserModel {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? profileImage;
  final String? specialization;
  final String? organization;
  final int? courseCount;
  final List<SelectedStackModel>? stacks;

  UserModel(
      {this.id,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.role,
      this.profileImage,
      this.specialization,
      this.organization,
      this.courseCount,
      this.stacks});
  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      profileImage: json['profile_picture'],
      specialization: json['specialization'],
      organization: json['organization'],
      courseCount: json['course_count'],
      stacks: json['stacks'] != null
          ? (json['stacks'] as List)
              .map((stack) => SelectedStackModel.fromJson(stack))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'role': role,
      'profile_image': profileImage,
      'specialization': specialization,
      'organization': organization
    };
  }

  UserModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    String? profileImage,
    String? specialization,
    String? organization,
    List<SelectedStackModel>? stacks,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      specialization: specialization ?? this.specialization,
      organization: organization ?? this.organization,
      stacks: stacks ?? this.stacks,
    );
  }
}
